package kopo.poly.service.impl;

import kopo.poly.dto.RouteDTO;
import kopo.poly.dto.RoutePointDTO;
import kopo.poly.mapper.IRouteMapper;
import kopo.poly.service.IRouteService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLStreamConstants;
import javax.xml.stream.XMLStreamReader;
import java.io.InputStream;
import java.math.BigDecimal;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class RouteService implements IRouteService {

    private final IRouteMapper routeMapper;

    /** GPX 업로드 (단일 진입점) */
    @Transactional
    @Override
    public Long uploadGpx(String name, MultipartFile file) throws Exception {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("GPX 파일이 비어 있습니다.");
        }

        // 1) GPX 파싱
        List<RoutePointDTO> points;
        try (InputStream in = file.getInputStream()) {
            points = parseGpx(in);
        }
        if (points.isEmpty()) {
            throw new IllegalArgumentException("GPX에서 trkpt를 찾지 못했습니다.");
        }

        // 2) DB 스케일(DECIMAL(10,7))에 맞춰 반올림 + 연속 동일 좌표 제거
        points = dedupeConsecutiveRounded(points, 7);

        // 3) SEQ 재부여 (1..N)
        for (int i = 0; i < points.size(); i++) {
            points.get(i).setSeq(i + 1);
        }

        // 4) 요약값 계산
        Double distKm = calcDistanceKm(points);
        Integer durationMin = estimateDurationMin(points);

        // 5) 라우트 헤더 저장
        RouteDTO route = new RouteDTO();
        String original = file.getOriginalFilename();
        route.setName((name != null && !name.isBlank()) ? name
                : (original != null ? original : "GPX Route"));
        route.setFileName(original);
        if (distKm != null) route.setDistKm(BigDecimal.valueOf(distKm));
        route.setDurationMin(durationMin);

        routeMapper.insertRoute(route);
        Long routeId = route.getRouteId();
        if (routeId == null) {
            throw new IllegalStateException("routeId가 null 입니다. RouteMapper.xml의 useGeneratedKeys 설정을 확인하세요.");
        }

        // 6) 포인트 대량 저장 (청크 분할)
        bulkInsertPointsChunked(routeId, points, 800);

        return routeId;
    }

    @Override
    public List<RouteDTO> listRoutes() {
        return routeMapper.listRoutes();
    }

    @Override
    public List<RoutePointDTO> getRoutePoints(Long routeId) {
        return routeMapper.getRoutePoints(routeId);
    }

    /* ================== 내부 유틸 ================== */

    private void bulkInsertPointsChunked(Long routeId, List<RoutePointDTO> list, int chunk) {
        if (list == null || list.isEmpty()) return;

        for (int i = 0; i < list.size(); i += chunk) {
            int j = Math.min(list.size(), i + chunk);
            List<RoutePointDTO> sub = list.subList(i, j);
            for (RoutePointDTO p : sub) p.setRouteId(routeId);
            routeMapper.bulkInsertPoints(routeId, sub);
        }
    }

    private List<RoutePointDTO> parseGpx(InputStream in) throws Exception {
        List<RoutePointDTO> out = new ArrayList<>();
        XMLInputFactory f = XMLInputFactory.newInstance();
        XMLStreamReader r = f.createXMLStreamReader(in, "UTF-8");

        RoutePointDTO cur = null;
        String current = null;

        while (r.hasNext()) {
            int ev = r.next();

            if (ev == XMLStreamConstants.START_ELEMENT) {
                current = r.getLocalName();
                if ("trkpt".equalsIgnoreCase(current)) {
                    cur = new RoutePointDTO();
                    String lat = r.getAttributeValue(null, "lat");
                    String lon = r.getAttributeValue(null, "lon");
                    if (lat != null) cur.setLat(Double.valueOf(lat));
                    if (lon != null) cur.setLng(Double.valueOf(lon));
                }
            } else if (ev == XMLStreamConstants.CHARACTERS) {
                if (cur == null || current == null) continue;
                String txt = r.getText();
                if (txt == null || (txt = txt.trim()).isEmpty()) continue;

                if ("ele".equalsIgnoreCase(current)) {
                    try {
                        cur.setElev(new BigDecimal(txt));
                    } catch (Exception ignore) {}
                } else if ("time".equalsIgnoreCase(current)) {
                    cur.setTm(parseIsoToLocalDateTime(txt)); // LocalDateTime으로 통일
                }
            } else if (ev == XMLStreamConstants.END_ELEMENT) {
                String name = r.getLocalName();
                if ("trkpt".equalsIgnoreCase(name)) {
                    if (cur != null && cur.getLat() != null && cur.getLng() != null) {
                        out.add(cur);
                    }
                    cur = null;
                }
                current = null;
            }
        }
        r.close();
        return out;
    }

    private static LocalDateTime parseIsoToLocalDateTime(String iso) {
        try {
            return OffsetDateTime.parse(iso, DateTimeFormatter.ISO_OFFSET_DATE_TIME).toLocalDateTime();
        } catch (Exception ignore) {}
        try {
            return LocalDateTime.parse(iso);
        } catch (Exception ignore) {}
        return null;
    }

    private static double haversineMeters(double lat1, double lon1, double lat2, double lon2) {
        final double R = 6371000.0;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat/2) * Math.sin(dLat/2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon/2) * Math.sin(dLon/2);
        return 2 * R * Math.asin(Math.sqrt(a));
    }

    private Double calcDistanceKm(List<RoutePointDTO> pts) {
        if (pts == null || pts.size() < 2) return null;
        double sum = 0;
        for (int i = 1; i < pts.size(); i++) {
            RoutePointDTO a = pts.get(i - 1), b = pts.get(i);
            if (a.getLat() == null || a.getLng() == null || b.getLat() == null || b.getLng() == null) continue;
            sum += haversineMeters(a.getLat(), a.getLng(), b.getLat(), b.getLng());
        }
        return sum / 1000.0;
    }

    private Integer estimateDurationMin(List<RoutePointDTO> pts) {
        LocalDateTime start = null, end = null;
        for (RoutePointDTO p : pts) {
            if (start == null && p.getTm() != null) start = p.getTm();
            if (p.getTm() != null) end = p.getTm();
        }
        if (start == null || end == null) return null;
        long min = Math.abs(Duration.between(start, end).toMinutes());
        return (int) min;
    }

    /* ====== 반올림 + 연속중복 제거 ====== */

    private static double round(double v, int scale) {
        return new java.math.BigDecimal(v)
                .setScale(scale, java.math.RoundingMode.HALF_UP)
                .doubleValue();
    }

    /**
     * DB 컬럼 DECIMAL(10,7)에 맞춰 lat/lng을 반올림한 뒤,
     * '연속'으로 동일한 좌표는 제거한다.
     */
    private static List<RoutePointDTO> dedupeConsecutiveRounded(List<RoutePointDTO> src, int scale) {
        if (src == null || src.isEmpty()) return src;
        List<RoutePointDTO> out = new ArrayList<>(src.size());
        Double prevLat = null, prevLng = null;
        for (RoutePointDTO p : src) {
            if (p.getLat() == null || p.getLng() == null) continue;
            double lat = round(p.getLat(), scale);
            double lng = round(p.getLng(), scale);

            // 반올림된 값으로 업데이트 (DB와 동일 스케일)
            p.setLat(lat);
            p.setLng(lng);

            if (prevLat == null || Double.doubleToLongBits(lat) != Double.doubleToLongBits(prevLat)
                    || Double.doubleToLongBits(lng) != Double.doubleToLongBits(prevLng)) {
                out.add(p);
                prevLat = lat;
                prevLng = lng;
            }
        }
        return out;
    }
}
