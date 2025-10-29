package kopo.poly.mapper;

import kopo.poly.dto.UserAchievementView;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface IAchievementMapper {

    // 유저별 업적 조회
    List<UserAchievementView> selectUserAchievements(@Param("userId") String userId);

    // ✅ 모든 업적 조회 (회원가입 초기화용)
    List<UserAchievementView> getAllAchievements();

    // ✅ 유저별 업적 insert
    void insertUserAchievement(@Param("userId") String userId,
                               @Param("achievementId") Long achievementId,
                               @Param("progress") int progress,
                               @Param("target") int target);
}