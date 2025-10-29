package kopo.poly.dto;

import lombok.Getter; import lombok.Setter;

@Getter @Setter
public class RouteDTO {
    private Long routeId;
    private String name;
    private String srcFilename;
    private Double distM;
    private String fileName;
    private Integer durationSec;
    private Double startLat, startLng;
    private Double endLat, endLng;
    private java.math.BigDecimal distKm;
    private Integer durationMin;
    private String regDt; // 목록 응답용(포맷 문자열)
}
