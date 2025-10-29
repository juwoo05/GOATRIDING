package kopo.poly.controller;

import jakarta.servlet.http.HttpSession;
import kopo.poly.dto.UserAchievementView;
import kopo.poly.dto.UserChallengeView;
import kopo.poly.dto.UserDTO;
import kopo.poly.service.IAchievementService;
import kopo.poly.service.IChallengeService;
import kopo.poly.service.IRankingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.List;

@Controller
@RequiredArgsConstructor
@Slf4j
public class RankingPageController {

    private final IRankingService rankingService;
    private final IAchievementService achievementService; // ✅ 업적 서비스 주입
    private final IChallengeService challengeService;

    @GetMapping("/rank/ranking")
    public String rankingPage(HttpSession session, Model model) throws Exception {
        // 1) 전체 랭킹
        List<UserDTO> rankingUsers = rankingService.getAllRanking();
        model.addAttribute("rankingUsers", rankingUsers);

        // 2) 세션에서 로그인 유저 확인
        String ssUserId = (String) session.getAttribute("SS_USER_ID");
        String ssUserName = (String) session.getAttribute("SS_USER_NAME");

        if (ssUserId != null || ssUserName != null) {
            for (UserDTO u : rankingUsers) {
                // userId 기준 비교 (DB 구조 따라 userName 비교로 바꿔도 됨)
                if (u.getUserId() != null && u.getUserId().equals(ssUserId)) {
                    u.setCurrentUser(true);
                }
                if (u.getUserName() != null && u.getUserName().equals(ssUserName)) {
                    u.setCurrentUser(true);
                }
            }
        }

        model.addAttribute("rankingUsers", rankingUsers);

        // 3) 현재 유저 업적 (지금은 하드코딩 → 나중에 세션 userId로 바꿔야 함)
        String currentUserId = ssUserId != null ? ssUserId : "user1";
        List<UserAchievementView> achievements = achievementService.getUserAchievements(currentUserId);
        model.addAttribute("achievements", achievements);

        // 도전과제
        List<UserChallengeView> challenges = challengeService.getUserChallenges(currentUserId);
        model.addAttribute("challenges", challenges);

        log.info("achievements={}", achievements);
        log.info("challenges={}", challenges);

        return "rank/ranking";
    }
}