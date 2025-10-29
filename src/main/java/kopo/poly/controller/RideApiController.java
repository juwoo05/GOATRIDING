package kopo.poly.controller;

import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Positive;
import kopo.poly.dto.UserDTO;
import kopo.poly.service.IRankingService;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/rank")
@Validated
public class RideApiController {

    private final IRankingService rankingService;

    @PostMapping("/ride")
    public ResponseEntity<RideResult> addRide(
            HttpSession session,
            @RequestBody @Valid RideRequest req
    ) {
        String userId   = (String) session.getAttribute("SS_USER_ID");
        String userName = (String) session.getAttribute("SS_USER_NAME");

        log.info("[/api/rank/ride] session SS_USER_ID={}, SS_USER_NAME={}, distanceM={}",
                userId, userName, req.getDistanceM());

        // ★ SS_USER_ID가 비어있으면, 이름으로 유저를 찾아 userId 보정
        if ((userId == null || userId.isBlank()) && userName != null && !userName.isBlank()) {
            try {
                UserDTO u = rankingService.getUserByName(userName);
                if (u != null && u.getUserId() != null && !u.getUserId().isBlank()) {
                    userId = u.getUserId();
                    log.info("Resolved userId by userName: {} -> {}", userName, userId);
                }
            } catch (Exception e) {
                log.warn("getUserByName failed: {}", e.getMessage());
            }
        }

        if (userId == null || userId.isBlank()) {
            return ResponseEntity.status(401)
                    .body(new RideResult("UNAUTHORIZED", "로그인이 필요합니다(세션 없음).", 0, 0, 0));
        }

        // 적립 처리
        rankingService.addRide(userId, userName, req.getDistanceM());

        final double EMISSION_KG_PER_KM = 0.238;
        final double POINTS_PER_KG = 100.0;

        double km = req.getDistanceM() / 1000.0;
        double savedKg = km * EMISSION_KG_PER_KM;
        int addedPoints = (int) Math.round(savedKg * POINTS_PER_KG);

        return ResponseEntity.ok(new RideResult("OK", "적립 완료", km, savedKg, addedPoints));
    }

    @Data
    public static class RideRequest {
        @Positive(message = "distanceM는 0보다 커야 합니다.")
        private double distanceM;
        private String source;
    }

    @Data @AllArgsConstructor
    public static class RideResult {
        private String code;
        private String msg;
        private double addedKm;
        private double savedKg;
        private int addedPoints;
    }

    // ★ 빠른 진단용 엔드포인트(필요 시 잠깐만 열었다 닫으세요)
    @GetMapping("/debug/session")
    public ResponseEntity<String> sessionDebug(HttpSession session) {
        String userId   = (String) session.getAttribute("SS_USER_ID");
        String userName = (String) session.getAttribute("SS_USER_NAME");
        return ResponseEntity.ok("SS_USER_ID=" + userId + ", SS_USER_NAME=" + userName);
    }
}