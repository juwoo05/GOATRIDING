package kopo.poly.mapper;

import kopo.poly.dto.UserDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.sql.Date;
import java.util.List;

@Mapper
public interface IRankingMapper {

    // 단일 조회
    UserDTO getUserById(@Param("userId") String userId);
    UserDTO getUserByName(@Param("name") String name);

    // 신규 사용자 생성
    void insertUser(UserDTO pDTO);

    // 점수/거리/탄소 누적
    void updateScore(UserDTO pDTO);

    // 랭킹 조회
    List<UserDTO> getTop5();
    List<UserDTO> getTop3();
    List<UserDTO> getAllRanking();

    // 주간 리셋
    void resetWeekly();

    // ✅ USER_RANK의 achievements/challenges 집계 반영
    int updateBadgeCounts(@Param("userId") String userId,
                          @Param("periodStart") Date periodStart);

    // (옵션) 개별 카운트가 필요하면 사용
    Integer getAchievementCount(@Param("userId") String userId);
    Integer getChallengeCount(@Param("userId") String userId,
                              @Param("periodStart") Date periodStart);
}