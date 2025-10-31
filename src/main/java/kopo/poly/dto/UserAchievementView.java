package kopo.poly.dto;

import lombok.Data;

@Data
public class UserAchievementView {
    private Long id;
    private String title;
    private String description;
    private String icon;
    private String rarity;
    private Integer unlocked;   // 0/1
    private String unlockedAt;

    private Double progress;    // DECIMAL(10,3) 매핑
    private Double target;      // a.GOAL_VALUE 기준
    private String unit;        // a.UNIT (km, kg 등)
}