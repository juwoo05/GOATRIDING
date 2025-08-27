package kopo.poly.service.impl;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import kopo.poly.dto.HotspotDTO;
import kopo.poly.repository.WarnSpotMapper;
import kopo.poly.repository.row.WarnSpotRow;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.util.UriComponentsBuilder;

import java.net.URI;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.List;

@Service
public class KoroadHotspotService {

    @Value("${koroad.serviceKey}")
    private String serviceKey;

    @Value("${koroad.apiBasePrimary:https://apis.data.go.kr/B552061/AccidentRiskArea/getRestBicycleAccidentArea}")
    private String apiBasePrimary;
    @Value("${koroad.apiBaseFallback:https://opendata.koroad.or.kr/api/selectBicycleDataSet.do}")
    private String apiBaseFallback;

    private final ObjectMapper om = new ObjectMapper();
    private final RestTemplate rest = new RestTemplate();
    private final WarnSpotMapper warnSpotMapper;           // ★ DB 연동

    public KoroadHotspotService(WarnSpotMapper warnSpotMapper) {
        this.warnSpotMapper = warnSpotMapper;
    }

    /* ================== API 호출 (기존) ================== */

    public List<HotspotDTO> fetchBicycleHotspots(int year, int siDo, int guGun, int pageNo, int rows) {
        String skey = ensureEncoded(serviceKey);

        // 1차: 공공데이터포털
        String body = callJson(apiBasePrimary, skey, year, siDo, guGun, pageNo, rows, "type");
        if (looksLikeHtmlOrXml(body)) { // 2차: koroad 백업
            body = callJson(apiBaseFallback, skey, year, siDo, guGun, pageNo, rows, "type");
            if (looksLikeHtmlOrXml(body)) {
                body = callJson(apiBaseFallback, skey, year, siDo, guGun, pageNo, rows, "resultType");
            }
        }
        if (looksLikeHtmlOrXml(body)) throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "KoROAD JSON 아님: " + trim(body));

        try {
            JsonNode root = om.readTree(body);
            JsonNode items = root.path("items").path("item");
            if (!items.isArray() || items.isEmpty()) {
                JsonNode data = root.path("data");
                if (data.isArray()) items = data;
            }

            List<HotspotDTO> out = new ArrayList<>();
            if (!items.isArray()) return out;

            for (JsonNode it : items) {
                String name = text(it, "spot_nm", "지점명");
                int incidents = parseInt(text(it, "occrrnc_cnt", "occrnc_cnt", "사고건수"));
                double lat = parseDouble(text(it, "la_crd", "lat", "위도"));
                double lng = parseDouble(text(it, "lo_crd", "lng", "경도"));
                if (!Double.isFinite(lat) || !Double.isFinite(lng)) continue;

                String risk = incidents >= 4 ? "high" : (incidents >= 2 ? "medium" : "low");
                String desc = (name != null ? name : "지점") + " | 사고건수 " + incidents;

                // GeoJSON이 응답에 있으면 꺼내 쓰고, 없으면 null
                String geom = text(it, "geom_json", "geometry", "geom"); // 데이터셋에 따라 다름
                out.add(new HotspotDTO(name != null ? name : "지점", lat, lng, risk, desc, incidents, geom));
            }
            return out;

        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "KoROAD 파싱 실패: " + e.getMessage(), e);
        }
    }

    private String callJson(String base, String skey, int year, int siDo, int guGun, int pageNo, int rows, String typeKey) {
        URI uri = UriComponentsBuilder.fromUriString(base)
                .queryParam("serviceKey", skey)
                .queryParam("searchYearCd", year)
                .queryParam("siDo", siDo)
                .queryParam("guGun", guGun)
                .queryParam(typeKey, "json")
                .queryParam("numOfRows", rows)
                .queryParam("pageNo", pageNo)
                .build(true).toUri();
        try {
            HttpHeaders h = new HttpHeaders();
            h.set(HttpHeaders.ACCEPT, "application/json");
            h.set(HttpHeaders.USER_AGENT, "Mozilla/5.0 (KoroadHotspotService)");
            ResponseEntity<String> res = rest.exchange(uri, HttpMethod.GET, new HttpEntity<>(h), String.class);
            return res.getBody() == null ? "" : res.getBody();
        } catch (HttpStatusCodeException ex) {
            String b = ex.getResponseBodyAsString();
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY,
                    "KoROAD HTTP " + ex.getRawStatusCode() + " : " + trim(b), ex);
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "KoROAD 호출 실패: " + e.getMessage(), e);
        }
    }

    /* ================== ★ DB 동기화/조회 추가 ================== */

    // ★ API → DB 저장(upsert). 리턴: 반영 건수(INSERT=1, UPDATE=2로 합산됨)
    public int syncBicycleHotspotsToDb(int year, int siDo, int guGun, int pageNo, int rows) {
        List<HotspotDTO> list = fetchBicycleHotspots(year, siDo, guGun, pageNo, rows);
        int affected = 0;
        for (HotspotDTO h : list) {
            WarnSpotRow r = new WarnSpotRow();
            r.setSpotNm(h.getName());
            r.setOccrrncCnt(h.getIncidents());
            r.setLaCrd(h.getLat());
            r.setLoCrd(h.getLng());
            r.setGeomJson(h.getGeomJson());
            r.setSrcHash(srcHash(h));                 // ★ 중복 방지 키
            affected += warnSpotMapper.upsert(r);
        }
        return affected;
    }

    // ★ DB에서 반경 조회 → 프런트로 내려줄 DTO로 변환
    public List<HotspotDTO> fetchNearbyFromDb(double centerLat, double centerLng, int radiusM, int limit) {
        double latDelta = radiusM / 111_000d;
        double lngDelta = radiusM / (111_320d * Math.cos(Math.toRadians(centerLat)));
        double minLat = centerLat - latDelta, maxLat = centerLat + latDelta;
        double minLng = centerLng - lngDelta, maxLng = centerLng + lngDelta;

        List<WarnSpotRow> rows = warnSpotMapper.selectWithinBounds(minLat, maxLat, minLng, maxLng, limit);
        List<HotspotDTO> out = new ArrayList<>();
        for (WarnSpotRow r : rows) {
            if (r.getLaCrd() == null || r.getLoCrd() == null) continue;
            int incidents = r.getOccrrncCnt() == null ? 0 : r.getOccrrncCnt();
            String risk = incidents >= 4 ? "high" : (incidents >= 2 ? "medium" : "low");
            String name = (r.getSpotNm() == null || r.getSpotNm().isBlank()) ? "지점" : r.getSpotNm();
            String desc = name + " | 사고건수 " + incidents;
            out.add(new HotspotDTO(name, r.getLaCrd(), r.getLoCrd(), risk, desc, incidents, r.getGeomJson()));
        }
        return out;
    }

    /* ================== 유틸 ================== */

    private String ensureEncoded(String key) {
        if (key == null) return "";
        return key.contains("%") ? key : URLEncoder.encode(key, StandardCharsets.UTF_8);
    }
    private boolean looksLikeHtmlOrXml(String s) {
        if (s == null) return false;
        String t = s.trim().toLowerCase();
        return t.startsWith("<!doctype html") || t.contains("<html") || (t.startsWith("<") && t.contains("xml"));
    }
    private String trim(String s) {
        if (s == null) return "";
        s = s.replaceAll("\\s+"," ").trim();
        return s.length()>300 ? s.substring(0,300) + " …" : s;
    }
    private String text(JsonNode n, String... keys) {
        for (String k : keys) {
            JsonNode v = n.path(k);
            if (!v.isMissingNode() && !v.isNull()) return v.asText();
        }
        return null;
    }
    private int parseInt(String s) { try { return s==null?0:Integer.parseInt(s.trim()); } catch(Exception e){ return 0; } }
    private double parseDouble(String s) { try { return s==null?Double.NaN:Double.parseDouble(s.trim()); } catch(Exception e){ return Double.NaN; } }

    private String srcHash(HotspotDTO h) {
        try {
            String base = (h.getName()==null?"":h.getName().trim()) + "|" +
                    String.format("%.6f|%.6f", h.getLat(), h.getLng()) + "|" +
                    (h.getGeomJson()==null?"":h.getGeomJson().trim());
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] d = md.digest(base.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : d) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            return String.valueOf((h.getName()+"|"+h.getLat()+"|"+h.getLng()).hashCode());
        }
    }
}
