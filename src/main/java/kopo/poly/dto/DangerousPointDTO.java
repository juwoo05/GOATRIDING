package kopo.poly.dto;

import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
public class DangerousPointDTO {

    private String spot_nm; //지점명

    private int occrrnc_cnt; //사고건수

    private int caslt_cnt; //사상자수

    private int dth_dnv_cnt; //사망자수

    private int se_dnv_cnt; //중상자수

    private int sl_dnv_cnt; //경상자수

    private double lo_crd; //경도

    private double la_crd; //위도

    private String geom_json; //다발지역폴리곤

}
