package kopo.poly.service;

import kopo.poly.dto.UserAchievementView;

import java.util.List;

public interface IAchievementService {
    /** 업적 목록 조회 (JSP 바인딩용) */
    List<UserAchievementView> getUserAchievements(String userId);

    /** 특정 업적(ID)에 km 증분 반영 */
    void applyDistanceKm(String userId, long achievementId, double deltaKm);

    /** 특정 업적(제목/코드)에 kg 증분 반영 */
    void applyCarbonKgByTitle(String userId, String title, double deltaKg);

    /** (선택) USER_RANK 누적값을 기반으로 UA 진행도 백필 */
    void backfillFromRank(String userId);
}
