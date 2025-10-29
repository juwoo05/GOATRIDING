package kopo.poly.dto;

import lombok.Data;

@Data
public class UserChallengeView {
    private Long challengeId;
    private String challengeType;
    private double targetValue;
    private double progressValue;
    private int completed;
}