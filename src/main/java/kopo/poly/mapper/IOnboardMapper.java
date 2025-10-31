package kopo.poly.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.sql.Date;

@Mapper
public interface IOnboardMapper {

    // USER_RANK에 (없으면) 1행 생성
    int insertUserRankIfAbsent(@Param("userId") String userId,
                               @Param("userName") String userName);

    // USER_ACHIEVEMENT에 모든 업적 0으로 시드 (없으면)
    int initAllAchievements(@Param("userId") String userId);

    // USER_CHALLENGE에 이번 주 주간 챌린지 시드 (없으면)
    int initWeeklyChallenges(@Param("userId") String userId,
                             @Param("periodStart") Date periodStart);
}
