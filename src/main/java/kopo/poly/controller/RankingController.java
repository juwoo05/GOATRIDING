package kopo.poly.controller;

import kopo.poly.dto.UserDTO;
import kopo.poly.service.IRankingService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * REST API 전용 랭킹 컨트롤러
 * - POST/GET 방식으로 클라이언트와 JSON 데이터 통신
 * - 기본 경로: /api/ranking
 */
@RestController // 데이터를 반환하는 REST 컨트롤러
@RequiredArgsConstructor
@RequestMapping("/api/ranking") // 모든 메서드 앞에 /api/ranking 자동으로 붙음
public class RankingController {

    private final IRankingService rankingService;

    /**
     * ✅ 1. 점수 업데이트 (POST 방식, JSON Body)
     * 예: POST /api/ranking/update
     */
    @PostMapping("/update")
    public ResponseEntity<String> update(@RequestBody UserDTO pDTO) {
        rankingService.updateScore(pDTO);
        return ResponseEntity.ok("✅ 점수 업데이트 완료 (POST)");
    }

    /**
     * ✅ 2. 점수 업데이트 (GET 방식, 쿼리 파라미터로 테스트용)
     * 예: GET /api/ranking/update-test?username=홍길동&distance=10.5
     */
    @GetMapping("/update-test")
    public ResponseEntity<String> updateByParam(
            @RequestParam("username") String username,
            @RequestParam("distance") double distance) {

        UserDTO pDTO = new UserDTO();
        pDTO.setName(username);
        pDTO.setDistance(distance);

        rankingService.updateScore(pDTO);
        return ResponseEntity.ok("✅ 점수 업데이트 완료 (GET 테스트용)");
    }

    /**
     * ✅ 3. 상위 5명 랭킹 조회
     * 예: GET /api/ranking/top5
     */
    @GetMapping("/top5")
    public ResponseEntity<List<UserDTO>> getTop5() {
        return ResponseEntity.ok(rankingService.getTop5());
    }
}