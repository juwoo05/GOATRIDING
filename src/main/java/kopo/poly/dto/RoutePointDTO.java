package kopo.poly.dto;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter @Setter
public class RoutePointDTO {
    private Long routeId;           // FK
    private Integer seq;            // 포인트 순번 (nullable wrapper 권장)
    private Double lat;             // 위도 (nullable wrapper)
    private Double lng;             // 경도 (nullable wrapper)
    private BigDecimal elev;        // 고도 -> DB의 ELEV_M, XML #{p.elev}
    private LocalDateTime tm;       // DB의 CREATED_AT와 매핑
}
