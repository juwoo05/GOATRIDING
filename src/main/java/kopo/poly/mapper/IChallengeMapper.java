package kopo.poly.mapper;

import kopo.poly.dto.UserChallengeView;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.sql.Date;
import java.util.List;

@Mapper
public interface IChallengeMapper {

    // 주간 챌린지 조회(화면용) - 이번 주 시작일 기준
    List<UserChallengeView> selectUserWeeklyChallenges(@Param("userId") String userId,
                                                       @Param("periodStart") Date periodStart);

    // (선택) 이번 주 초기 레코드 생성
    void initUserWeeklyChallenges(@Param("userId") String userId,
                                  @Param("periodStart") Date periodStart);

    // ✅ 타이틀 상관없이 '주간+km' 챌린지 전부에 증분 km 적용
    void upsertWeeklyDistanceAll(@Param("userId") String userId,
                                 @Param("periodStart") Date periodStart,
                                 @Param("deltaKm") double deltaKm);

    // ✅ (옵션) 타이틀 상관없이 '주간+kg' 챌린지 전부에 증분 kg 적용
    void upsertWeeklyCarbonAll(@Param("userId") String userId,
                               @Param("periodStart") Date periodStart,
                               @Param("deltaKg") double deltaKg);
}