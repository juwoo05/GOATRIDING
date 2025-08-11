package kopo.poly.service.impl;

import kopo.poly.dto.UserDTO;
import kopo.poly.mapper.IRankingMapper;
import kopo.poly.service.IRankingService;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class RankingService implements IRankingService {

    private final IRankingMapper rankingMapper;

    @Override
    public void updateScore(UserDTO pDTO) {
        // 거리 → 점수 계산
        double distance = pDTO.getDistance();
        int point   = (int)(distance * 10);  // 예: 2.3km → 23점

        // 탄소 절약량 계산
        double carbonSaved = calculateCarbonSaved(distance);

        //DTO에 값 세팅
        pDTO.setCarbonSaved(carbonSaved);
        pDTO.setPoints(point);

        // 사용자 등록 or 업데이트
        UserDTO rDTO = rankingMapper.getUserByName(pDTO.getName());

        if (rDTO == null) {
            rankingMapper.insertUser(pDTO);  // 신규 사용자
        } else {
            rankingMapper.updateScore(pDTO); // 기존 사용자 업데이트
        }
    }

    @Override
    public List<UserDTO> getTop5() {
        return rankingMapper.getTop5();
    }

    @Override
    @Scheduled(cron = "0 0 0 * * MON", zone = "Asia/Seoul") // 매주 월요일 00:00
    public void resetWeekly() {
        rankingMapper.resetWeekly();
    }

    /**
     * 거리 (km)를 입력받아 탄소 절약량(kg)을 계산
     * 반올림은 소수점 둘째 자리까지
     */

    private double calculateCarbonSaved(double distance) {
        return Math.round(distance * 0.21 * 100) / 100.0;
    }
}