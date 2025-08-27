package kopo.poly.dto;

import lombok.*;

@Getter @Setter
@AllArgsConstructor @NoArgsConstructor
public class HotspotDTO {
    private String name;        // spot_nm
    private double lat;         // la_crd
    private double lng;         // lo_crd
    private String riskLevel;   // high/medium/low
    private String description; // "지점명 | 사고건수 n"
    private int incidents;      // occrrnc_cnt
    private String geomJson;    // ★ GeoJSON(Polygon/MultiPolygon) 원문(없으면 null)
}
