package kopo.poly.controller;

import jakarta.servlet.http.HttpSession;
import kopo.poly.dto.UserAchievementView;
import kopo.poly.dto.UserChallengeView;
import kopo.poly.dto.UserDTO;
import kopo.poly.dto.UserMyPageDTO;
import kopo.poly.service.IAchievementService;
import kopo.poly.service.IChallengeService;
import kopo.poly.service.IRankingService;
import kopo.poly.service.IUserMyPageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.List;

/**
 * 랭킹 페이지 컨트롤러
 *
 * 역할:
 *  - 서비스에서 랭킹/업적/도전과제/프로필 정보를 가져와 JSP(Model)에 심어준다.
 *  - 세션의 로그인 사용자(SS_USER_ID, SS_USER_NAME)와 랭킹 리스트를 비교해
 *    현재 사용자를 강조할 수 있도록 currentUser 플래그를 세팅한다.
 *  - header.jsp에서 쓸 수 있도록 로그인 유저의 myPage 정보(프로필 이미지 등)도 모델에 담는다.
 */
@Controller
@RequiredArgsConstructor
@Slf4j
public class RankingPageController {

    // 랭킹/업적/도전과제/마이페이지 조회에 필요한 서비스들 주입
    private final IRankingService rankingService;
    private final IAchievementService achievementService; // ✅ 업적 서비스
    private final IChallengeService challengeService;     // ✅ 도전과제 서비스
    private final IUserMyPageService myPageService;       // ✅ 마이페이지(프로필) 서비스

    /**
     * GET /rank/ranking
     * 랭킹 페이지 진입 시 필요한 모든 데이터를 로드해 모델에 담는다.
     */
    @GetMapping("/rank/ranking")
    public String rankingPage(HttpSession session, Model model) throws Exception {

        // 1) 전체 랭킹 목록 조회 → JSP에서 랭킹 리스트 렌더링
        List<UserDTO> rankingUsers = rankingService.getAllRanking();
        model.addAttribute("rankingUsers", rankingUsers);

        // 2) 세션에서 로그인 사용자 식별자 꺼내오기
        String ssUserId = (String) session.getAttribute("SS_USER_ID");
        String ssUserName = (String) session.getAttribute("SS_USER_NAME");

        // 2-1) 랭킹 리스트 중 현재 로그인 사용자 행을 찾아 currentUser=true 설정
        //      (userId, userName 두 경우 모두 비교. DB/세션 구조에 맞게 하나만 써도 무방)
        if (ssUserId != null || ssUserName != null) {
            for (UserDTO u : rankingUsers) {
                // userId 비교
                if (u.getUserId() != null && u.getUserId().equals(ssUserId)) {
                    u.setCurrentUser(true);
                }
                // userName 비교
                if (u.getUserName() != null && u.getUserName().equals(ssUserName)) {
                    u.setCurrentUser(true);
                }
            }
        }

        // (모델에 같은 키로 다시 넣는 것은 중복이지만, 안전하게 유지)
        model.addAttribute("rankingUsers", rankingUsers);

        // 3) 현재 사용자 업적/도전과제 조회
        //    - 임시로 ssUserId가 없으면 "user1"을 기본값으로 사용 (TODO: 로그인 강제 시 제거)
        String currentUserId = ssUserId != null ? ssUserId : "user1";

        // 업적 리스트
        List<UserAchievementView> achievements = achievementService.getUserAchievements(currentUserId);
        model.addAttribute("achievements", achievements);

        // 도전과제 리스트
        List<UserChallengeView> challenges = challengeService.getUserChallenges(currentUserId);
        model.addAttribute("challenges", challenges);

        // 4) header.jsp에서 사용할 현재 로그인 유저의 마이페이지 정보(프로필 이미지 포함) 제공
        if (ssUserId != null) {
            UserMyPageDTO user = myPageService.getMyPage(ssUserId);
            model.addAttribute("user", user); // JSP에서 ${user.profileImageUrl} 등으로 사용
        }

        // 디버깅 로그
        log.info("achievements={}", achievements);
        log.info("challenges={}", challenges);
        log.info("[Ranking][Achievements] size={}", achievements.size());
        if (!achievements.isEmpty()) {
            var a0 = achievements.get(0);
            log.info("[Ranking][Achievements][0] id={}, title={}, unit={}, progress={}, target={}, unlocked={}",
                    a0.getId(), a0.getTitle(), a0.getUnit(), a0.getProgress(), a0.getTarget(), a0.getUnlocked());
        }

        // rank/ranking.jsp 로 포워딩
        return "rank/ranking";
    }
}
