package kopo.poly.mapper;

import kopo.poly.dto.UserDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface IRankingMapper {

    UserDTO getUserByName(String name); // 사용자 단일 조회

    void insertUser(UserDTO pDTO); // 사용자 최초 삽입

    void updateScore(UserDTO pDTO); // 점수/거리 업데이트

    List<UserDTO> getTop5(); // 상위 5명 조회

    void resetWeekly(); // 점수 초기화
}