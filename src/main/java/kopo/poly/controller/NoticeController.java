package kopo.poly.controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import kopo.poly.dto.MsgDTO;
import kopo.poly.dto.NoticeDTO;
import kopo.poly.service.INoticeService;
import kopo.poly.util.CmmUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Slf4j
@RequestMapping(value = "notice")
@RequiredArgsConstructor
@Controller
public class NoticeController {

    private final INoticeService noticeService;

    @GetMapping(value = "noticeList")
    public String noticeList(HttpSession session, ModelMap model) throws Exception {

        log.info("{}.noticeList Start!", this.getClass().getName());


        List<NoticeDTO> rList = Optional.ofNullable(noticeService.getNoticeList())
                .orElseGet(ArrayList::new);

        model.addAttribute("rList", rList);
        log.info(this.getClass().getName() + " noticeList End!");

        return "notice/noticeList";
    }

    @GetMapping(value = "noticeReg")
    public String NoticeReg() {

        log.info("{}.noticeReg Start!", this.getClass().getName());

        log.info("{}.noticeReg End!", this.getClass().getName());

        return "notice/noticeReg";
    }

    @ResponseBody
    @PostMapping(value = "noticeInsert")
    public MsgDTO noticeInsert(HttpServletRequest request, HttpSession session) {

        log.info("{}.noticeInsert Start!", this.getClass().getName());

        String msg = "";
        MsgDTO dto;

        try {

            String userId = CmmUtil.nvl((String) session.getAttribute("SS_USER_ID"));
            String title = CmmUtil.nvl(request.getParameter("title"));
            String noticeYn = CmmUtil.nvl(request.getParameter("noticeYn"));
            String contents = CmmUtil.nvl(request.getParameter("contents"));

            log.info("session user_id : {} / title : {} / noticeYn : {} / contents : {} ",
                    userId, title, noticeYn, contents);

            NoticeDTO pDTO = new NoticeDTO();
            pDTO.setUserId(userId);
            pDTO.setTitle(title);
            pDTO.setNoticeYn(noticeYn);
            pDTO.setContents(contents);

            noticeService.insertNoticeInfo(pDTO);

            msg = "등록되었습니다.";

        } catch (Exception e) {

            msg = "실패하였습니다. : " + e.getMessage();
            log.info(e.toString());
        } finally {
            dto = new MsgDTO();
            dto.setMsg(msg);

            log.info("{}.noticeInsert End!", this.getClass().getName());
        }

        return dto;

    }

    @GetMapping(value = "noticeInfo")
    public String noticeInfo(HttpServletRequest request, ModelMap model) throws Exception {

        log.info("{}.noticeInfo Start!", this.getClass().getName());

        String nSeq = CmmUtil.nvl(request.getParameter("nSeq"));

        log.info("nSeq : {}", nSeq);

        NoticeDTO pDTO = new NoticeDTO();
        pDTO.setNoticeSeq(nSeq);

        NoticeDTO rDTO = Optional.ofNullable(noticeService.getNoticeInfo(pDTO, true))
                .orElseGet(NoticeDTO::new);

        model.addAttribute("rDTO", rDTO);
        log.info("{}.noticeInfo End!", this.getClass().getName());

        return "notice/noticeInfo";
    }

    @GetMapping(value = "noticeEditInfo")
    public String noticeEditInfo(HttpServletRequest request, ModelMap model) throws Exception {

        log.info("{}.noticeEditInfo Start!", this.getClass().getName());

        String nSeq = CmmUtil.nvl(request.getParameter("nSeq"));

        log.info("nSeq : {}", nSeq);

        NoticeDTO pDTO = new NoticeDTO();
        pDTO.setNoticeSeq(nSeq);

        NoticeDTO rDTO = Optional.ofNullable(noticeService.getNoticeInfo(pDTO,false))
                .orElseGet(NoticeDTO::new);

        model.addAttribute("rDTO", rDTO);

        log.info("{}.noticeEditInfo End!", this.getClass().getName());

        return "notice/noticeEditInfo";
    }

    @ResponseBody
    @PostMapping(value = "noticeUpdate")
    public MsgDTO noticeUpdate(HttpSession session, HttpServletRequest request) {

        log.info("{}.noticeUpdate Start!", this.getClass().getName());

        String msg = "";
        MsgDTO dto;

        try {
            String userId = CmmUtil.nvl((String) session.getAttribute("SESSION_USER_ID"));
            String nSeq = CmmUtil.nvl(request.getParameter("nSeq"));
            String title = CmmUtil.nvl(request.getParameter("title"));
            String noticeYn = CmmUtil.nvl(request.getParameter("noticeYn"));
            String contents = CmmUtil.nvl(request.getParameter("contents"));

            log.info("userid : {} / nSeq : {} / title : {} / noticeYn : {} / contents : {} ",
                    userId, nSeq, title, noticeYn, contents);

            NoticeDTO pDTO = new NoticeDTO();
            pDTO.setUserId(userId);
            pDTO.setNoticeSeq(nSeq);
            pDTO.setTitle(title);
            pDTO.setNoticeYn(noticeYn);
            pDTO.setContents(contents);

            noticeService.updateNoticeInfo(pDTO);

            msg = "수정되었습니다.";
        } catch (Exception e) {
            msg = "실패하였습니다. : " + e.getMessage();
            log.info(e.toString());
        } finally {

            dto = new MsgDTO();
            dto.setMsg(msg);

            log.info("{}.noticeUpdate End!", this.getClass().getName());
        }
        return dto;
    }

    @ResponseBody
    @PostMapping(value="/noticeDelete")
    public MsgDTO noticeDelete(HttpServletRequest request) {

        log.info("{}.noticeDelete Start!", this.getClass().getName());

        String msg = "";
        MsgDTO dto;

        try {
            String nSeq = CmmUtil.nvl(request.getParameter("nSeq"));

            log.info("nSeq : {}", nSeq);

            NoticeDTO pDTO = new NoticeDTO();
            pDTO.setNoticeSeq(nSeq);

            noticeService.deleteNoticeInfo(pDTO);

            msg = "삭제되었습니다.";

        } catch (Exception e) {
            msg = "실패하였습니다. : " + e.getMessage();
            log.info(e.toString());
        } finally {
            dto = new MsgDTO();
            dto.setMsg(msg);

            log.info("{}.noticeDelete End!", this.getClass().getName());
        }
        return dto;
    }
}
