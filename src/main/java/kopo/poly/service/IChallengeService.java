package kopo.poly.service;

import kopo.poly.dto.UserChallengeView;

import java.sql.Date;
import java.util.List;

public interface IChallengeService {
    // 화면용: 이번 주(월요일 시작) 기준
    List<UserChallengeView> getUserChallenges(String userId);

    // 특정 주(월요일 시작일 명시) 기준
    List<UserChallengeView> getWeekly(String userId, Date periodStart);

    // 주행 증분 반영(랭킹 적립 시 함께 호출)
    void addRideTick(String userId, double addedKm, double addedKg);
}
