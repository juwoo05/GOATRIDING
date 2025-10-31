package kopo.poly.mapper;

import kopo.poly.dto.UserAchievementView;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface IAchievementMapper {

    // 화면 조회: 단위별 progress/target/unlocked 계산해서 내려줌
    List<UserAchievementView> selectUserAchievements(@Param("userId") String userId);

    // 회원가입 초기화용 (마스터)
    List<UserAchievementView> getAllAchievements();

    // UA 초기 레코드 생성
    void insertUserAchievement(@Param("userId") String userId,
                               @Param("achievementId") Long achievementId,
                               @Param("progress") double progress);

    // km 증가분 (ID 기반)
    void upsertDistanceById(@Param("userId") String userId,
                            @Param("achievementId") Long achievementId,
                            @Param("deltaKm") double deltaKm);

    // km 증가분 (제목/코드 기반)
    void upsertDistanceByCode(@Param("userId") String userId,
                              @Param("code") String code,
                              @Param("deltaKm") double deltaKm);

    // kg 증가분 (ID 기반)
    void upsertCarbonById(@Param("userId") String userId,
                          @Param("achievementId") Long achievementId,
                          @Param("deltaKg") double deltaKg);

    // kg 증가분 (제목/코드 기반) — XML은 title 파라미터명 사용
    void upsertCarbonByCode(@Param("userId") String userId,
                            @Param("title") String title,
                            @Param("deltaKg") double deltaKg);

    // USER_RANK 누적(distance, carbon_saved)로 UA 진행도 백필
    void backfillProgressFromRank(@Param("userId") String userId);
}
