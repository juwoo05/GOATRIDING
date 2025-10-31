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
    public List<UserAchievementView> getUserAchievements(String userId) {
        log.debug("[Ach][select] userId={}", userId);
        List<UserAchievementView> list = achievementMapper.selectUserAchievements(userId);
        if (!list.isEmpty()) {
            var a0 = list.get(0);
            log.debug("[Ach][select][size={}] first={id={}, title={}, unit={}, progress={}, target={}, unlocked={}}",
                    list.size(), a0.getId(), a0.getTitle(), a0.getUnit(),
                    a0.getProgress(), a0.getTarget(), a0.getUnlocked());
        } else {
            log.debug("[Ach][select] empty");
        }
        return list;
    }

    @Override
    public void applyDistanceKm(String userId, long achievementId, double deltaKm) {
        log.debug("[Ach][km+][before] userId={}, achievementId={}, deltaKm={}", userId, achievementId, deltaKm);
        achievementMapper.upsertDistanceById(userId, achievementId, deltaKm);
        log.debug("[Ach][km+][after] userId={}, achievementId={}", userId, achievementId);
    }

    @Override
    public void applyCarbonKgByTitle(String userId, String title, double deltaKg) {
        log.debug("[Ach][kg+][before] userId={}, title='{}', deltaKg={}", userId, title, deltaKg);
        // XML 파라미터명과 일치: title
        achievementMapper.upsertCarbonByCode(userId, title, deltaKg);
        log.debug("[Ach][kg+][after] userId={}, title='{}'", userId, title);
    }

    @Override
    public void backfillFromRank(String userId) {
        log.debug("[Ach][backfill][start] userId={}", userId);
        achievementMapper.backfillProgressFromRank(userId);
        log.debug("[Ach][backfill][done] userId={}", userId);
    }
}
