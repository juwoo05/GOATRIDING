package kopo.poly.service.impl;

import kopo.poly.mapper.IOnboardMapper;
import kopo.poly.service.IOnboardService;
import kopo.poly.service.IRankBadgeService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Date;
import java.time.DayOfWeek;
import java.time.LocalDate;

@Slf4j
@Service
@RequiredArgsConstructor
public class OnboardService implements IOnboardService {

    private final IOnboardMapper onboardMapper;
    private final IRankBadgeService rankBadgeService; // USER_RANK의 카운트 최종 보정용(있으면)

    @Override
    @Transactional
    public void onUserSignup(String userId, String userName) {
        // 1) USER_RANK 1행 보장
        int r1 = onboardMapper.insertUserRankIfAbsent(userId, userName);

        // 2) 업적 전부 시드 (목표값 셋업)
        int r2 = onboardMapper.initAllAchievements(userId);

        // 3) 이번 주 주간 챌린지 시드
        Date monday = mondayOfThisWeek();
        int r3 = onboardMapper.initWeeklyChallenges(userId, monday);

        log.info("[Onboard] userId={} rankRow={} achSeed={} chSeed={}, weekStart={}",
                userId, r1, r2, r3, monday);

        // 4) 최종 카운트(ACHIEVEMENTS/CHALLENGES)를 USER_RANK에 반영 (0일 수 있음)
        try {
            rankBadgeService.recalcBadgeCounts(userId);
        } catch (Exception e) {
            log.warn("[Onboard] recalcBadgeCounts failed: {}", e.getMessage());
        }
    }

    private static Date mondayOfThisWeek() {
        LocalDate today = LocalDate.now(); // MON=1..SUN=7
        int dow = today.getDayOfWeek().getValue();
        LocalDate monday = today.minusDays((dow - DayOfWeek.MONDAY.getValue() + 7) % 7);
        return Date.valueOf(monday);
    }
}
