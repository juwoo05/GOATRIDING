package kopo.poly.mapper;

import kopo.poly.dto.UserDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface IRankingMapper {

    // 단일 조회 (user_id 기준) – 새로 추가
    UserDTO getUserById(@Param("userId") String userId);

    // 단일 조회 (user_name 기준) – 기존 유지
    UserDTO getUserByName(@Param("name") String name);

    // 신규 사용자 삽입
    void insertUser(UserDTO pDTO);

    // ⭐ 누적 업데이트 (points / distance / carbon_saved) — WHERE user_id=?
    void updateScore(UserDTO pDTO);

    // 랭킹 조회
    List<UserDTO> getTop5();
    List<UserDTO> getTop3();
    List<UserDTO> getAllRanking();

    // 주간 리셋(쓰고 있으면 유지)
    void resetWeekly();

    // 집계 (필요 시 사용) — userId가 숫자 PK면 Long, 문자열이면 String으로 맞춰도 됨
    int getAchievementCount(@Param("userId") Long userId);
    int getChallengeCount(@Param("userId") Long userId);
}
