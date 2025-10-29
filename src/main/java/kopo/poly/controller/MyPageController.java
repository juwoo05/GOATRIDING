package kopo.poly.controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import kopo.poly.dto.UserMyPageDTO;
import kopo.poly.infra.NcosPresignService;
import kopo.poly.service.IUserMyPageService;
import kopo.poly.util.CmmUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@RequiredArgsConstructor
@Controller
public class MyPageController {

    private final IUserMyPageService myPageService;
    private final NcosPresignService ncosPresignService;

    // 마이페이지 화면
    @GetMapping("/user/myPage")
    public String myPage(HttpSession session, Model model) throws Exception {
        String userId = (String) session.getAttribute("SS_USER_ID");
        log.info("[MyPage] session userId={}", userId);

        if (userId == null) {
            return "redirect:/user/login";
        }

        UserMyPageDTO user = myPageService.getMyPage(userId);
        log.info("[MyPage] 조회된 DTO={}", user);

        model.addAttribute("user", user);
        return "user/myPage";
    }

    // 닉네임 변경 (DTO로 전달)
    @PostMapping("/user/updateName")
    public String updateName(HttpSession session, @RequestParam String userName) throws Exception {
        String userId = (String) session.getAttribute("SS_USER_ID");
        log.info("[MyPage] updateName userId={}, userName={}", userId, userName);

        if (userId == null) return "redirect:/user/login";

        UserMyPageDTO pDTO = new UserMyPageDTO();
        pDTO.setUserId(userId);
        pDTO.setUserName(userName);

        int r = myPageService.updateUserName(pDTO);
        if (r > 0) {
            session.setAttribute("SS_USER_NAME", userName);
        }
        return "redirect:/user/myPage";
    }

    // ① Presign URL 발급 (폼데이터 contentType만 받음)
    @ResponseBody
    @PostMapping(value = "/user/profile/uploadUrl", produces = MediaType.APPLICATION_JSON_VALUE)
    public Map<String, Object> issueUploadUrl(HttpServletRequest request, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        try {
            String userId = CmmUtil.nvl((String) session.getAttribute("SS_USER_ID"));
            if (userId.isEmpty()) throw new IllegalStateException("로그인이 필요합니다.");

            String contentType = CmmUtil.nvl(request.getParameter("contentType"));
            if (contentType.isEmpty()) contentType = "application/octet-stream";

            // keyPrefix 예: user-profile/<userId>  (버킷 내부 경로는 서비스에서 조합)
            var pre = ncosPresignService.createUploadUrl("user-profile/" + userId, contentType);

            res.put("success", true);
            res.put("uploadUrl", pre.uploadUrl()); // PUT presign URL
            res.put("publicUrl", pre.publicUrl()); // 업로드 후 접근할 공개 URL
        } catch (Exception e) {
            log.error("[presign] error", e);
            res.put("success", false);
            res.put("message", e.getMessage());
        }
        return res;
    }

    // ② 업로드가 끝난 뒤 publicUrl을 DB에 저장 (JSON: {imageUrl:"..."})
    @ResponseBody
    @PostMapping(value = "/user/updateProfileImageByUrl", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    public Map<String, Object> updateProfileImageByUrl(@RequestBody Map<String, String> body, HttpSession session) throws Exception {
        Map<String, Object> res = new HashMap<>();
        String userId = (String) session.getAttribute("SS_USER_ID");
        log.info("[MyPage] updateProfileImageByUrl userId={}, body={}", userId, body);

        if (userId == null) {
            res.put("success", false);
            res.put("message", "로그인이 필요합니다.");
            return res;
        }

        String imageUrl = CmmUtil.nvl(body.get("imageUrl"));
        if (imageUrl.isEmpty()) {
            res.put("success", false);
            res.put("message", "imageUrl이 비었습니다.");
            return res;
        }

        UserMyPageDTO pDTO = new UserMyPageDTO();
        pDTO.setUserId(userId);
        pDTO.setProfileImage(imageUrl);

        int r = myPageService.updateProfileImage(pDTO);
        res.put("success", r > 0);
        if (r <= 0) res.put("message", "DB 저장 실패");
        return res;
    }
}
