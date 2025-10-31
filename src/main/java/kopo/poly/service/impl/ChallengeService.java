package kopo.poly.service.impl;

import kopo.poly.dto.UserChallengeView;
import kopo.poly.mapper.IChallengeMapper;
import kopo.poly.service.IChallengeService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.sql.Date;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class ChallengeService implements IChallengeService {

    private final IChallengeMapper challengeMapper;

    /** 화면용: 이번 주 기준 조회 + 없으면 시드 */
    @Override
    public List<UserChallengeView> getUserChallenges(String userId) {
        Date periodStart = mondayOfThisWeek();
        log.info("[Challenge][getUserChallenges] userId={}, periodStart={}", userId, periodStart);

        // 이번 주 레코드가 없으면 생성 (있으면 ON DUPLICATE로 스킵)
        challengeMapper.initUserWeeklyChallenges(userId, periodStart);

        // 조회
        List<UserChallengeView> list =
                challengeMapper.selectUserWeeklyChallenges(userId, periodStart);

        log.info("[Challenge][result] size={}, first={}",
                (list == null ? 0 : list.size()),
                (list != null && !list.isEmpty() ? list.get(0) : null));
        return list;
    }

    /** 특정 주 기준 조회 (필요 시 유지) */
    @Override
    public List<UserChallengeView> getWeekly(String userId, Date weekStart) {
        log.info("[Challenge][getWeekly] userId={}, periodStart={}", userId, weekStart);
        return challengeMapper.selectUserWeeklyChallenges(userId, weekStart);
    }

    /** 주행 증분을 주간 챌린지에 반영 (RankingService 등에서 호출 가능) */
    @Override
    public void addRideTick(String userId, double addedKm, double addedKg) {
        Date periodStart = mondayOfThisWeek();
        log.info("[Challenge][addRideTick] userId={}, periodStart={}, +km={}, +kg={}",
                userId, periodStart, addedKm, addedKg);

        if (addedKm > 0) {
            challengeMapper.upsertWeeklyDistanceAll(userId, periodStart, addedKm);
        }
        if (addedKg > 0) {
            // kg 단위 챌린지를 사용하는 경우
            challengeMapper.upsertWeeklyCarbonAll(userId, periodStart, addedKg);
        }
    }

    /** 이번 주 월요일(로컬) 00:00을 java.sql.Date로 */
    private static Date mondayOfThisWeek() {
        LocalDate today = LocalDate.now(); // ISO: MON=1..SUN=7
        int dow = today.getDayOfWeek().getValue();
        LocalDate monday = today.minusDays((dow - DayOfWeek.MONDAY.getValue() + 7) % 7);
        return Date.valueOf(monday);
    }
}
