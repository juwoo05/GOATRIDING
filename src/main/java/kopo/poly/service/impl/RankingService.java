package kopo.poly.service.impl;

import kopo.poly.dto.UserDTO;
import kopo.poly.mapper.IRankingMapper;
import kopo.poly.service.IRankingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class RankingService implements IRankingService {

    private final IRankingMapper rankingMapper;

    // 산식 상수
    private static final double EMISSION_KG_PER_KM = 0.238; // 120 g/km
    private static final double POINTS_PER_KG = 100.0;      // 1kg = 100pt

    @Override
    public void updateScore(UserDTO pDTO) {
        rankingMapper.updateScore(pDTO);
    }

    @Override
    public List<UserDTO> getTop5() { return rankingMapper.getTop5(); }

    @Override
    public List<UserDTO> getTop3() { return rankingMapper.getTop3(); }

    @Override
    public void resetWeekly() { /* 배치에서 사용 시 구현 */ }

    @Override
    public List<UserDTO> getAllRanking() { return rankingMapper.getAllRanking(); }

    @Override
    public UserDTO getUserByName(String name) { return rankingMapper.getUserByName(name); }

    // ⭐ 컨트롤러에서 호출하는 메서드 (시그니처 반드시 동일!)
    @Override
    @Transactional
    public void addRide(String userId, String userName, double distanceMeters) {
        if (userId == null || userId.isBlank()) {
            throw new IllegalArgumentException("userId가 필요합니다.");
        }
        if (distanceMeters <= 0) {
            throw new IllegalArgumentException("distanceMeters는 양수여야 합니다.");
        }

        // 유저 없으면 생성
        UserDTO found = rankingMapper.getUserById(userId);
        if (found == null) {
            UserDTO newbie = new UserDTO();
            newbie.setUserId(userId);
            newbie.setUserName(userName != null ? userName : userId);
            rankingMapper.insertUser(newbie);
        }

        // km/절감/포인트 계산
        double km = distanceMeters / 1000.0;
        double savedKg = km * EMISSION_KG_PER_KM;
        int addPoints = (int) Math.round(savedKg * POINTS_PER_KG);

        // 누적 업데이트
        UserDTO delta = new UserDTO();
        delta.setUserId(userId);
        delta.setDistance(round(km, 3));         // 누적 km
        delta.setCarbonSaved(round(savedKg, 3)); // 누적 kg
        delta.setPoints(addPoints);              // 누적 포인트

        rankingMapper.updateScore(delta);

        log.info("[addRide] userId={}, +{}km, +{}kgCO2, +{}pt",
                userId, km, savedKg, addPoints);
    }

    private static double round(double v, int scale) {
        return BigDecimal.valueOf(v).setScale(scale, RoundingMode.HALF_UP).doubleValue();
    }
}
