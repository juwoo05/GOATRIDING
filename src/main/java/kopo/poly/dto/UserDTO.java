package kopo.poly.dto;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;

@Data
@Getter
@Setter

public class UserDTO {

    private String name;       // 사용자 이름
    private int points;        // 누적 점수
    private double distance;   // 누적 주행 거리
    private double carbonSaved; // 탄소 절약
    private String createdAt;   // 가입 날짜
}