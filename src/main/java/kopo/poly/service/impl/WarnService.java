package kopo.poly.service.impl;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import kopo.poly.dto.DangerousDTO;
import kopo.poly.dto.DangerousPointDTO;
import kopo.poly.mapper.IWarnMapper;
import kopo.poly.service.IWarnService;
import kopo.poly.util.NetworkUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor // ✅ warnMapper 같은 final 필드 자동 생성자 주입
public class WarnService implements IWarnService {

    @Value("${warn.api.key}")
    private String apiKey;

    private final IWarnMapper warnMapper;       // ✅ Mapper 주입 (DB 저장)

    private final ObjectMapper om = new ObjectMapper(); // ✅ 재사용할 ObjectMapper

    @Override
    public DangerousDTO getDangerous(DangerousDTO pDTO) throws Exception {

        log.info("WarnService.getDangerous START");

        String searchYearCd = "2021";
        String siDo = "11"; // 서울
        String type = "json";
        String numOfRows = "1000";
        String pageNo = "1";

        // ✅ 서울특별시 구군 코드 리스트
        Map<String, String> guGunMap = Map.ofEntries(
                Map.entry("강남구", "680"),
                Map.entry("강동구", "740"),
                Map.entry("강북구", "305"),
                Map.entry("강서구", "500"),
                Map.entry("관악구", "620"),
                Map.entry("광진구", "215"),
                Map.entry("구로구", "530"),
                Map.entry("금천구", "545"),
                Map.entry("노원구", "350"),
                Map.entry("도봉구", "320"),
                Map.entry("동대문구", "230"),
                Map.entry("동작구", "590"),
                Map.entry("마포구", "440"),
                Map.entry("서대문구", "410"),
                Map.entry("서초구", "650"),
                Map.entry("성동구", "200"),
                Map.entry("성북구", "290"),
                Map.entry("송파구", "710"),
                Map.entry("양천구", "470"),
                Map.entry("영등포구", "560"),
                Map.entry("용산구", "170"),
                Map.entry("은평구", "380"),
                Map.entry("종로구", "110"),
                Map.entry("중구", "140"),
                Map.entry("중랑구", "260") // 빠진 코드도 추가
        );

        List<DangerousPointDTO> totalList = new ArrayList<>();

        for (Map.Entry<String, String> entry : guGunMap.entrySet()) {
            String guName = entry.getKey();
            String guGun = entry.getValue();

            String apiParam = String.format(
                    "?ServiceKey=%s&searchYearCd=%s&siDo=%s&guGun=%s&type=%s&numOfRows=%s&pageNo=%s",
                    apiKey, searchYearCd, siDo, guGun, type, numOfRows, pageNo
            );
            log.info("API 호출 [{} - {}] : {}", guName, guGun, apiParam);

            String json = NetworkUtil.get(IWarnService.apiURL + apiParam);
            JsonNode root = om.readTree(json);
            JsonNode items = root.path("items").path("item");

            if (items.isArray()) {
                for (JsonNode it : items) {
                    DangerousPointDTO dto = toDTO(it);
                    if (dto != null) totalList.add(dto);
                }
            } else if (!items.isMissingNode()) {
                DangerousPointDTO dto = toDTO(items);
                if (dto != null) totalList.add(dto);
            } else {
                log.warn("No items found for {}", guName);
            }
        }

        // ✅ DB 저장 (upsert)
        if (!totalList.isEmpty()) {
            warnMapper.insertList(totalList);
            log.info("saved {} rows into warn_spot (upsert)", totalList.size());
        }

        DangerousDTO dDTO = new DangerousDTO();
        dDTO.setPointsList(totalList);

        log.info("WarnService.getDangerous END");
        return dDTO;
    }


    /**
     * JsonNode 1건을 안전하게 DTO로 변환하고, src_hash를 채움.
     * - 변경 이유:
     *   1) 필드 누락/타입 오류시 NPE 대신 기본값 처리 → 파싱 견고성↑
     *   2) geom_json이 객체로 올 때를 대비해 JSON 문자열화(ObjectMapper 사용)
     *   3) 중복/변경 판단을 위한 src_hash 생성
     */
    private DangerousPointDTO toDTO(JsonNode it) {
        try {
            // ✅ 안전한 추출 (없으면 기본값 0/0.0/"")
            String spot_nm   = asText(it, "spot_nm");
            int occrrnc_cnt  = asInt(it,  "occrrnc_cnt");
            int caslt_cnt    = asInt(it,  "caslt_cnt");
            int dth_dnv_cnt  = asInt(it,  "dth_dnv_cnt");
            int se_dnv_cnt   = asInt(it,  "se_dnv_cnt");
            int sl_dnv_cnt   = asInt(it,  "sl_dnv_cnt");
            double lo_crd    = asDouble(it, "lo_crd");
            double la_crd    = asDouble(it, "la_crd");

            // ✅ geom_json: API에서 객체 형태로 오는 케이스 대비 (toString()은 자바 Map 문자열이라 위험)
            String geom_json;
            JsonNode geomNode = it.get("geom_json");
            if (geomNode == null || geomNode.isNull()) {
                geom_json = "";
            } else if (geomNode.isTextual()) {
                geom_json = geomNode.asText();
            } else {
                geom_json = om.writeValueAsString(geomNode); // ← 진짜 JSON 문자열로 직렬화
            }

            // ✅ 로그는 파라미터 바인딩 사용(문자열 + 연산 부담↓, NPE 안전)
            log.debug("spot_nm={}, occrrnc_cnt={}, caslt_cnt={}, dth_dnv_cnt={}, se_dnv_cnt={}, sl_dnv_cnt={}, lo_crd={}, la_crd={}",
                    spot_nm, occrrnc_cnt, caslt_cnt, dth_dnv_cnt, se_dnv_cnt, sl_dnv_cnt, lo_crd, la_crd);

            // ✅ DTO 생성
            DangerousPointDTO dto = new DangerousPointDTO();
            dto.setSpot_nm(spot_nm);
            dto.setOccrrnc_cnt(occrrnc_cnt);
            dto.setCaslt_cnt(caslt_cnt);
            dto.setDth_dnv_cnt(dth_dnv_cnt);
            dto.setSe_dnv_cnt(se_dnv_cnt);
            dto.setSl_dnv_cnt(sl_dnv_cnt);
            dto.setLo_crd(lo_crd);
            dto.setLa_crd(la_crd);
            dto.setGeom_json(geom_json);

            // ✅ src_hash 추가(필드가 DTO에 있어야 함) : 중복/변경 판단
            String raw = spot_nm + "|" + occrrnc_cnt + "|" + caslt_cnt + "|" + dth_dnv_cnt + "|" +
                    se_dnv_cnt + "|" + sl_dnv_cnt + "|" + lo_crd + "|" + la_crd + "|" + geom_json;
            dto.setSrc_hash(sha256(raw)); // ← DTO에 src_hash 필드 꼭 추가!

            return dto;
        } catch (Exception e) {
            // ✅ 개별 레코드 오류는 계속 진행 (전체 수집 실패 방지)
            log.warn("Skip one item due to parse error: {}", e.toString());
            return null;
        }
    }

    // ====== Json 안전 파서들 ======
    private String asText(JsonNode n, String key)   { return n.hasNonNull(key) ? n.get(key).asText()   : ""; }
    private int asInt(JsonNode n, String key)       { return n.hasNonNull(key) ? n.get(key).asInt(0)   : 0; }
    private double asDouble(JsonNode n, String key) { return n.hasNonNull(key) ? n.get(key).asDouble() : 0.0; }

    // ====== SHA-256 해시 유틸 ======
    private String sha256(String s) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] b = md.digest(s.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte x : b) sb.append(String.format("%02x", x));
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}