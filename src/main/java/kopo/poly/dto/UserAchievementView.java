package kopo.poly.dto;

import lombok.Data;

@Data
public class UserAchievementView {
    private Long id;
    private String title;
    private String description;
    private String icon;       // 이모지/아이콘 코드
    private String rarity;     // common/rare/epic/legendary
    private Integer unlocked;
    private String unlockedAt; // 해금 시각
    private Integer progress;  // 진행 상황
    private Integer target;    // 목표 값
}