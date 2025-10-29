package kopo.poly.service;

import kopo.poly.dto.UserDTO;

import java.util.List;

/**
 * 랭킹 관련 서비스 인터페이스
 *
 * - 점수 업데이트
 * - 상위 랭킹 조회 (TOP3, TOP5)
 * - 전체 랭킹 조회
 * - 특정 유저 조회
 * - 주간 초기화
 */
public interface IRankingService {

    // ⭐ 추가: 지도에서 받은 거리(m)를 적립 처리
    void addRide(String userId, String userName, double distanceMeters);
    /**
     * 사용자 점수를 업데이트 (거리 기반 → 점수/탄소 절감 계산 포함)
     *
     * @param pDTO 사용자 정보 (거리 포함)
     */
    void updateScore(UserDTO pDTO);

    /**
     * 상위 5명 랭킹 조회
     *
     * @return UserDTO 리스트
     */
    List<UserDTO> getTop5();

    /**
     * 상위 3명 랭킹 조회
     *
     * @return UserDTO 리스트
     */
    List<UserDTO> getTop3();

    /**
     * 주간 랭킹 리셋
     * (매주 월요일 00시 기준 실행 예정)
     */
    void resetWeekly();

    /**
     * 전체 랭킹 조회
     *
     * @return UserDTO 리스트
     */
    List<UserDTO> getAllRanking();

    /**
     * 사용자명으로 특정 유저 조회
     *
     * @param name 사용자 이름
     * @return UserDTO
     */
    UserDTO getUserByName(String name);
}