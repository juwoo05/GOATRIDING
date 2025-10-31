package kopo.poly.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.sql.Date;

@Mapper
public interface IRankBadgeMapper {

    int countAchievements(@Param("userId") String userId);

    int countWeeklyChallenges(@Param("userId") String userId,
                              @Param("periodStart") Date periodStart);

    void updateUserRankBadges(@Param("userId") String userId,
                              @Param("achievements") int achievements,
                              @Param("challenges") int challenges);
}
