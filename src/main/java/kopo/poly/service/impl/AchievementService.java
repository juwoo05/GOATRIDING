package kopo.poly.service.impl;

import kopo.poly.dto.UserAchievementView;
import kopo.poly.mapper.IAchievementMapper;
import kopo.poly.service.IAchievementService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class AchievementService implements IAchievementService {

    private final IAchievementMapper achievementMapper;

    @Override
    public List<UserAchievementView> getUserAchievements(String userId) throws Exception {
        // 단순 위임(정렬/제한은 Mapper XML에서 처리)
        return achievementMapper.selectUserAchievements(userId);
    }
}