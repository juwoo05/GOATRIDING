package kopo.poly.dto;

import lombok.Data;

@Data
public class UserMyPageDTO {

    // USER_INFO
    private String userId;        // 로그인 아이디
    private String userName;      // 닉네임 (변경 가능)
    private String email;         // 이메일
    private String profileImage;  // 프로필 이미지 경로
    private String regDt;         // 가입일자
    private String chgDt;         // 최근 수정일자 (옵션)

    // USER_RANK
    private int points;           // 점수
    private double distance;      // 총 달린 거리 (km)
    private double carbonSaved;   // 절약한 탄소량 (kg)
    private int level;            // 레벨
    private int achievements;     // 달성 업적 개수
    private int challenges;       // 완료한 챌린지 개수
    private String avatar;        // 아바타 (이모지/이미지)
    private String createdAt;     // 랭킹 등록일자
}
