package kopo.poly.dto;

import lombok.Data;

@Data
public class UserDTO {
    private Long id;            // USER_RANK 기본키
    private String userId;      // ✅ USER_INFO.USER_ID (FK)
    private String userName;        // 유저 이름
    private int points;         // 점수
    private double distance;    // 거리
    private double carbonSaved; // 탄소 절약량
    private String createdAt;   // 가입 날짜

    // 추가
    private int level;          // 탄소 절약량 기반 레벨
    private int achievements;   // 딴 업적 개수
    private int challenges;     // 완료한 챌린지 개수
    private String avatar;
    private boolean currentUser;
}