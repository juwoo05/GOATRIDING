package kopo.poly.controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import kopo.poly.dto.MsgDTO;
import kopo.poly.dto.UserInfoDTO;
import kopo.poly.service.IUserInfoService;
import kopo.poly.util.CmmUtil;
import kopo.poly.util.EncryptUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.Optional;

@Slf4j
@RequestMapping(value = "/user")
@RequiredArgsConstructor
@Controller
public class UserinfoController {

    private final IUserInfoService userInfoService;


    @GetMapping(value = "searchPassword")
    public String searchPassword(HttpSession session) {
        log.info("{}.searchPassword", this.getClass().getName());

        session.setAttribute("NEW_PASSWORD", "");
        session.removeAttribute("NEW_PASSWORD");

        log.info("{}.searchPassword End!", this.getClass().getName());

        return "user/searchPassword";

    }

    @PostMapping(value = "searchPasswordProc")
    public String searchPasswordProc(HttpServletRequest request, ModelMap model, HttpSession session) throws Exception {
        log.info("{}.searchPasswordProc", this.getClass().getName());


        String email = CmmUtil.nvl(request.getParameter("email"));
        session.setAttribute("SS_EMAIL", email);

        log.info("email : {} ", email);

        UserInfoDTO pDTO = new UserInfoDTO();

        pDTO.setEmail(EncryptUtil.encAES128CBC(email));

        UserInfoDTO rDTO = Optional.ofNullable(userInfoService.searchUserIdOrPasswordProc(pDTO)).orElseGet(UserInfoDTO::new);

        model.addAttribute("rDTO", rDTO);


        log.info("{}.searchPasswordProc End!", this.getClass().getName());

        return "user/newPassword";
    }

    @ResponseBody
    @PostMapping(value = "newPasswordProc")
    public String newPasswordProc(HttpServletRequest request, ModelMap model, HttpSession session) throws Exception {

        log.info("{}.user/newPasswordProc Start!", this.getClass().getName());

        String msg;

        String email = CmmUtil.nvl((String) session.getAttribute("SS_EMAIL"));
        String password = CmmUtil.nvl(request.getParameter("password"));

        log.info("password : {}", password);

        UserInfoDTO pDTO = new UserInfoDTO();
        pDTO.setEmail(EncryptUtil.encAES128CBC(email));
        pDTO.setPassword(EncryptUtil.encHashSHA256(password));

        userInfoService.newPasswordProc(pDTO);

        msg = "비밀번호가 재설정되었습니다.";

        model.addAttribute("msg", msg);

        log.info("{}.user/newPasswordProc End!", this.getClass().getName());

        return msg;
    }

    @GetMapping(value = "searchUserId")
    public String searchUserId() {
        log.info("{}.user/searchUserId Start", this.getClass().getName());

        log.info("{}.user/searchUserId End", this.getClass().getName());

        return "user/searchUserId";

    }

    @PostMapping(value = "searchUserIdProc")
    @ResponseBody // JSON 변환해서 반환
    public UserInfoDTO searchUserIdProc(HttpServletRequest request) throws Exception {
        log.info("{}.searchUserIdProc Start", this.getClass().getName());

        String email = CmmUtil.nvl(request.getParameter("email"));

        UserInfoDTO pDTO = new UserInfoDTO();
        pDTO.setEmail(EncryptUtil.encAES128CBC(email));
        UserInfoDTO rDTO = Optional.ofNullable(userInfoService.searchUserIdOrPasswordProc(pDTO))
                .orElseGet(UserInfoDTO::new);

        log.info("결과: {}", rDTO);
        log.info("{}.searchUserIdProc End", this.getClass().getName());

        return rDTO; // JSON 으로 내려감
    }

    @GetMapping(value = "login")
    public String login() {
        log.info("{}.login Start!", this.getClass().getName());

        log.info("{}.login End!", this.getClass().getName());

        return "user/login";
    }

    @ResponseBody
    @PostMapping(value = "loginProc")
    public MsgDTO loginProc(HttpServletRequest request, HttpSession session) {
        log.info("{}.loginProc Start!", this.getClass().getName());

        int res = 0;
        String msg = "";
        MsgDTO dto;

        UserInfoDTO pDTO;

        try {

            String userId = CmmUtil.nvl(request.getParameter("userId"));
            String password = CmmUtil.nvl(request.getParameter("password"));

            log.info("userId: {} / password: {}", userId, password);

            pDTO = new UserInfoDTO();

            pDTO.setUserId(userId);

            pDTO.setPassword(EncryptUtil.encHashSHA256(password));

            UserInfoDTO rDTO = userInfoService.getLogin(pDTO);

            if (!CmmUtil.nvl(rDTO.getUserId()).isEmpty()) {
                res = 1;

                msg = "로그인이 성공했습니다.";

                session.setAttribute("SS_USER_ID", userId);
                session.setAttribute("SS_USER_NAME", CmmUtil.nvl(rDTO.getUserName()));
                session.setAttribute("SS_EMAIL", CmmUtil.nvl(rDTO.getEmail()));
            } else {
                msg = "아이디와 비밀번호가 올바르지 않습니다.";

            }
        } catch (Exception e) {

            msg = "시스템 문제로 로그인이 실패했습니다";
            res = 2;
            log.info(e.toString());

        } finally {

            dto = new MsgDTO();
            dto.setResult(res);
            dto.setMsg(msg);

            log.info("{}.loginProc End", this.getClass().getName());
        }

        return dto;
    }


    @GetMapping(value = "loginResult")
    public String loginSuccess() {
        log.info("{}.loginResult Start!", this.getClass().getName());

        log.info("{}.loginResult End!", this.getClass().getName());

        return "user/loginResult";
    }


    @GetMapping(value = "userRegForm")
    public String userRegForm() {
        log.info("{}.user/userRegForm", this.getClass().getName());

        return "/user/userRegForm";
    }

    @ResponseBody
    @PostMapping(value = "getUserIdExists")
    public UserInfoDTO getUserExists(HttpServletRequest request) throws Exception {
        log.info("{}.getUserExists", this.getClass().getName());

        String userId = CmmUtil.nvl(request.getParameter("userId"));

        log.info("userId : {}", userId);

        UserInfoDTO pDTO = new UserInfoDTO();
        pDTO.setUserId(userId);

        UserInfoDTO rDTO = Optional.ofNullable(userInfoService.getUserIdExists(pDTO)).orElseGet(UserInfoDTO::new);

        log.info("{}.getUserIdExists End!", this.getClass().getName());

        return rDTO;
    }

    @ResponseBody
    @PostMapping(value = "getEmailExists")
    public UserInfoDTO getEmailExists(HttpServletRequest request) throws Exception {

        log.info("{}.getEmailExists Start!", this.getClass().getName());

        String email = CmmUtil.nvl(request.getParameter("email"));

        log.info("email : {}", email);

        UserInfoDTO pDTO = new UserInfoDTO();
        pDTO.setEmail(EncryptUtil.encAES128CBC(email));

        UserInfoDTO rDTO = Optional.ofNullable(userInfoService.getEmailExists(pDTO)).orElseGet(UserInfoDTO::new);

        log.info("{}.getUserIdExists End!", this.getClass().getName());

        return rDTO;
    }

    @ResponseBody
    @PostMapping(value = "getUserIdByEmail")
    public UserInfoDTO getUserIdByEmail(HttpServletRequest request) throws Exception {

        log.info("{}.getUserIdByEmail Start!", this.getClass().getName());

        String email = CmmUtil.nvl(request.getParameter("email"));

        log.info("email : {}", email);

        UserInfoDTO pDTO = new UserInfoDTO();
        pDTO.setEmail(EncryptUtil.encAES128CBC(email));

        UserInfoDTO rDTO = Optional.ofNullable(userInfoService.getUserIdByEmail(pDTO)).orElseGet(UserInfoDTO::new);

        log.info("{}.getUserIdExists End!", this.getClass().getName());

        return rDTO;
    }

    @ResponseBody
    @PostMapping(value = "insertUserInfo")
    public MsgDTO insertUserInfo(HttpServletRequest request) throws Exception {

        log.info("{}.insertUserINfo", this.getClass().getName());

        int res = 0;
        String msg = "";
        MsgDTO dto;

        UserInfoDTO pDTO;

        try {
            String userId = CmmUtil.nvl(request.getParameter("userId"));
            String userName = CmmUtil.nvl(request.getParameter("userName"));
            String password = EncryptUtil.encHashSHA256(request.getParameter("password"));
            String email = EncryptUtil.encAES128CBC(request.getParameter("email"));
            String addr1 = CmmUtil.nvl(request.getParameter("addr1"));
            String addr2 = CmmUtil.nvl(request.getParameter("addr2"));

            log.info("userId : " + userId);
            log.info("userName : " + userName);
            log.info("password : " + password);
            log.info("email : " + email);
            log.info("addr1 : " + addr1);
            log.info("addr2 : " + addr2);

            pDTO = new UserInfoDTO();

            pDTO.setUserId(userId);
            pDTO.setUserName(userName);

            pDTO.setPassword(password);

            pDTO.setEmail(email);
            pDTO.setAddr1(addr1);
            pDTO.setAddr2(addr2);

            res = userInfoService.insertUserInfo(pDTO);

            log.info("회원가입 결과(res) : " + res);

            if (res == 1) {
                msg = "회원가입되었습니다.";
            } else if (res == 2) {
                msg = "이미 가입된 아이디입니다.";
            } else {
                msg = "오류로 인해 회원가입이 실패하였습니다.";
            }

        } catch (Exception e) {
            msg = "실패하였습니다. : " + e;
            log.info(e.toString());
        } finally {
            dto = new MsgDTO();
            dto.setResult(res);
            dto.setMsg(msg);

            log.info("{}.insertUserInfo End!", this.getClass().getName());

        }
        return dto;
    }

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        log.info("{}.Logout Start!", this.getClass().getName());

        log.info("로그아웃 요청 발생");
        session.invalidate(); // 세션 무효화

        log.info("{}.Logout End!", this.getClass().getName());

        return "redirect:/";  // 메인 페이지로 리다이렉트

    }

    @RequestMapping(value = "/myPage")
    public String mypage() throws Exception{
        log.info("{}.Mypage Start!", this.getClass().getName());
        log.info("{}.Mypage End!", this.getClass().getName());
        return "/user/myPage";
    }
}
