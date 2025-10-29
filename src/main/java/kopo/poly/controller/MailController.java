package kopo.poly.controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import kopo.poly.dto.MailDTO;
import kopo.poly.dto.MsgDTO;
import kopo.poly.service.IMailService;
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
@RequestMapping(value = "/mail")
@RequiredArgsConstructor
@Controller
public class MailController {

    private final IMailService mailService;

    @GetMapping(value = "mailForm")
    public String mailForm() {

        log.info("{}.mailForm Start!", this.getClass().getName());

        return "mail/mailForm";
    }

    @ResponseBody
    @PostMapping(value = "sendMail")
    public MsgDTO sendMail(HttpServletRequest request) {

        log.info("{}.sendMail Start!", this.getClass().getName());

        String msg;

        String toMail = CmmUtil.nvl(request.getParameter("toMail"));
        String title = CmmUtil.nvl(request.getParameter("title"));
        String contents = CmmUtil.nvl(request.getParameter("contents"));

        log.info("toMail : {} / title : {} / contents : {}", toMail, title, contents);

        MailDTO pDTO = new MailDTO();

        pDTO.setToMail(toMail);
        pDTO.setTitle(title);
        pDTO.setContents(contents);

        int res = mailService.doSendMail(pDTO);

        if (res == 1) {
            msg = "메일 발송하였습니다.";

        } else {
            msg = "메일 발송 실패하였습니다.";
        }

        log.info(msg);

        MsgDTO dto = new MsgDTO();
        dto.setMsg(msg);

        log.info("{}.sendMail End!",this.getClass().getName());

        return dto;
    }

    @GetMapping(value = "mailList")
    public String noticeList(HttpSession session, ModelMap model) throws Exception {

        log.info("{}.mailList Start!", this.getClass().getName());

        List<MailDTO> rList = Optional.ofNullable(mailService.getMailList())
                .orElseGet(ArrayList::new);

        model.addAttribute("rList", rList);
        log.info("씨발롬아{}", rList);
        log.info(this.getClass().getName() + " mailList End!");

        return "mail/mailList";
    }

    @GetMapping(value = "mailInfo")
    public String noticeInfo(HttpServletRequest request, ModelMap model) throws Exception {

        log.info("{}.mailInfo Start!", this.getClass().getName());

        int mailSeq = Integer.parseInt(request.getParameter("mailSeq"));

        log.info("mailSeq 씨발: {}", mailSeq);

        MailDTO pDTO = new MailDTO();
        pDTO.setMailSeq(mailSeq);

        MailDTO rDTO = Optional.ofNullable(mailService.getMailInfo(pDTO))
                .orElseGet(MailDTO::new);

        model.addAttribute("rDTO", rDTO);
        log.info("{}.mailInfo End!", this.getClass().getName());

        return "mail/mailInfo";
    }

}
