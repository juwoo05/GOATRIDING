package kopo.poly.service.impl;

import kopo.poly.mapper.IRankBadgeMapper;
import kopo.poly.service.IRankBadgeService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.sql.Date;
import java.time.DayOfWeek;
import java.time.LocalDate;

@Slf4j
@Service
@RequiredArgsConstructor
public class RankBadgeService implements IRankBadgeService {

    private final IRankBadgeMapper badgeMapper;

    @Override
    public void recalcBadgeCounts(String userId) {
        Date weekStart = mondayOfThisWeek();

        int achCount = badgeMapper.countAchievements(userId);                 // USER_ACHIEVEMENT.COMPLETED=1
        int chgCount = badgeMapper.countWeeklyChallenges(userId, weekStart);  // 이번 주 USER_CHALLENGE.COMPLETED=1

        badgeMapper.updateUserRankBadges(userId, achCount, chgCount);

        log.info("[RankBadge][recalc] userId={}, achievements={}, weeklyChallenges={}, weekStart={}",
                userId, achCount, chgCount, weekStart);
    }

    private static Date mondayOfThisWeek() {
        LocalDate today = LocalDate.now();
        int dow = today.getDayOfWeek().getValue(); // MON=1..SUN=7
        LocalDate monday = today.minusDays((dow - DayOfWeek.MONDAY.getValue() + 7) % 7);
        return Date.valueOf(monday);
    }
}
