package kopo.poly.dto;

import lombok.Getter;
import lombok.Setter;

/**
 * 네가 만든 DTO를 유지하면서 최소 추가 버전
 */
@Setter
@Getter
public class DangerousPointDTO {

    private String spot_nm;   // 지점명
    private int occrrnc_cnt;  // 사고건수
    private int caslt_cnt;    // 사상자수
    private int dth_dnv_cnt;  // 사망자수
    private int se_dnv_cnt;   // 중상자수
    private int sl_dnv_cnt;   // 경상자수
    private double lo_crd;    // 경도 (※ 가능하면 BigDecimal 권장)
    private double la_crd;    // 위도 (※ 가능하면 BigDecimal 권장)
    private String geom_json; // 다발지역폴리곤

    // ✅ 추가: 중복/변경 감지용 해시
    private String src_hash;

    // ✅ 추가(선택): PK와 타임스탬프 (테이블에 있으면 매핑 가능)
    private Long id;
    private String created_at;
    private String updated_at;
}