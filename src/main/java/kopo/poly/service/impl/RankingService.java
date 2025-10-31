package kopo.poly.service.impl;

import kopo.poly.dto.UserDTO;
import kopo.poly.mapper.IAchievementMapper;
import kopo.poly.mapper.IChallengeMapper;
import kopo.poly.mapper.IRankingMapper;
import kopo.poly.service.IRankBadgeService;
import kopo.poly.service.IRankingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Date;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class RankingService implements IRankingService {

    private final IRankingMapper rankingMapper;
    private final IAchievementMapper achievementMapper;
    private final IChallengeMapper   challengeMapper;

    // ✅ 인터페이스로 의존성 주입
    private final IRankBadgeService rankBadgeService;

    private static final double EMISSION_KG_PER_KM = 0.238;
    private static final double POINTS_PER_KG      = 100.0;

    // (예시) 업적 식별자/코드
    private static final long   ACH_FIRST_10KM_ID        = 16L;
    private static final long   ACH_FIRST_100KM_ID       = 17L;
    private static final String ACH_SAVE_100KG_CO2_TITLE = "Save 100kg CO₂";

    @Override
    public void updateScore(UserDTO pDTO) { rankingMapper.updateScore(pDTO); }

    @Override
    public List<UserDTO> getTop5() { return rankingMapper.getTop5(); }

    @Override
    public List<UserDTO> getTop3() { return rankingMapper.getTop3(); }

    @Override
    public void resetWeekly() {
        rankingMapper.resetWeekly();
        log.info("[resetWeekly] 주간 랭킹 초기화 완료");
    }

    @Override
    public List<UserDTO> getAllRanking() { return rankingMapper.getAllRanking(); }

    @Override
    public UserDTO getUserByName(String name) { return rankingMapper.getUserByName(name); }

    /** 주행 적립(증분) */
    @Override
    @Transactional
    public void addRide(String userId, String userName, double distanceMeters) {
        if (userId == null || userId.isBlank()) throw new IllegalArgumentException("userId가 필요합니다.");
        if (distanceMeters <= 0) throw new IllegalArgumentException("distanceMeters는 양수여야 합니다.");

        // 1) 최초 유저 생성
        UserDTO exists = rankingMapper.getUserById(userId);
        if (exists == null) {
            UserDTO newbie = new UserDTO();
            newbie.setUserId(userId);
            newbie.setUserName(userName != null ? userName : userId);
            rankingMapper.insertUser(newbie);
            log.info("[addRide] 신규 유저 생성: userId={}, userName={}", newbie.getUserId(), newbie.getUserName());
        }

        // 2) m → km
        double km = distanceMeters / 1000.0;

        // 3) km → 절감 CO₂(kg)
        double savedKg = km * EMISSION_KG_PER_KM;

        // 4) 포인트 (정수 반올림)
        int addPoints = (int) Math.round(savedKg * POINTS_PER_KG);

        // 5) 랭킹 누적 업데이트
        UserDTO delta = new UserDTO();
        delta.setUserId(userId);
        delta.setDistance(round(km, 3));
        delta.setCarbonSaved(round(savedKg, 3));
        delta.setPoints(addPoints);
        rankingMapper.updateScore(delta);

        // 6) 업적 진행도 반영
        try {
            double addedKm = delta.getDistance();
            double addedKg = delta.getCarbonSaved();

            achievementMapper.upsertDistanceById(userId, ACH_FIRST_10KM_ID,  addedKm);
            achievementMapper.upsertDistanceById(userId, ACH_FIRST_100KM_ID, addedKm);
            achievementMapper.upsertCarbonByCode(userId, ACH_SAVE_100KG_CO2_TITLE, addedKg);

            log.info("[addRide][Achievement] applied: userId={}, +km={}, +kg={}", userId, addedKm, addedKg);
        } catch (Exception e) {
            log.warn("[addRide][Achievement] apply failed: {}", e.getMessage());
        }

        // 7) 주간 챌린지 반영
        try {
            Date weekStart = mondayOfThisWeek();
            challengeMapper.upsertWeeklyDistanceAll(userId, weekStart, delta.getDistance());
            log.info("[addRide][Challenge] weekly distance +{} km (weekStart={})", delta.getDistance(), weekStart);
        } catch (Exception e) {
            log.warn("[addRide][Challenge] apply failed: {}", e.getMessage());
        }

        // 8) ✅ USER_RANK의 업적/도전과제 개수 최신화
        try {
            rankBadgeService.recalcBadgeCounts(userId);
        } catch (Exception e) {
            log.warn("[addRide][RankBadge] update failed: {}", e.getMessage());
        }

        log.info("[addRide] userId={}, +{}km, +{}kgCO2, +{}pt",
                userId, delta.getDistance(), delta.getCarbonSaved(), delta.getPoints());
    }

    private static double round(double v, int scale) {
        return BigDecimal.valueOf(v).setScale(scale, RoundingMode.HALF_UP).doubleValue();
    }

    private static Date mondayOfThisWeek() {
        LocalDate today = LocalDate.now();                 // ISO: MON=1...SUN=7
        int dow = today.getDayOfWeek().getValue();
        LocalDate monday = today.minusDays((dow - DayOfWeek.MONDAY.getValue() + 7) % 7);
        return Date.valueOf(monday);
    }
}
