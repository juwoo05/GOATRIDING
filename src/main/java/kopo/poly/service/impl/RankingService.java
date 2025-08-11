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

        System.out.println("받은 거리 = "  + distance);
        int point = (int)(distance * 10);  // 예: 2.3km → 23점

        pDTO.setPoints(point);

        System.out.println("계산된 점수 = " + point);

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
    @Scheduled(cron = "0 0 0 * * MON") // 매주 월요일 00:00
    public void resetWeekly() {
        rankingMapper.resetWeekly();
    }
}

