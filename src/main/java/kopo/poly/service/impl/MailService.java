package kopo.poly.service.impl;

import jakarta.mail.internet.MimeMessage;
import kopo.poly.dto.MailDTO;
import kopo.poly.mapper.IMailMapper;
import kopo.poly.service.IMailService;
import kopo.poly.util.CmmUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Service
public class MailService implements IMailService {

    private final JavaMailSender mailSender;
    private final IMailMapper mailMapper;

    @Value("${spring.mail.username}")
    private String fromMail;

    @Transactional
    @Override
    public MailDTO getMailInfo(MailDTO pDTO) throws Exception {

        log.info("{}.getNoticeInfo start!", this.getClass().getName());

        return mailMapper.getMailInfo(pDTO);
    }

    @Override
    public int doSendMail(MailDTO pDTO) {

        log.info("{}.doSendMail start!", this.getClass().getName());

        int res = 1;

        if (pDTO == null) {
            pDTO = new MailDTO();
        }

        String toMail = CmmUtil.nvl(pDTO.getToMail());
        String title = CmmUtil.nvl(pDTO.getTitle());
        String contents = CmmUtil.nvl(pDTO.getContents());


        log.info("toMail : {} / title : {} / contents : {}", toMail, title, contents);

        MimeMessage message = mailSender.createMimeMessage();


        MimeMessageHelper messageHelper = new MimeMessageHelper(message, "UTF-8");

        try {

            messageHelper.setTo(toMail);
            messageHelper.setFrom(fromMail);
            messageHelper.setSubject(title);
            messageHelper.setText(contents);

            mailSender.send(message);
            mailMapper.insertMailInfo(pDTO);


        } catch (Exception e) {
            res = 0;
            log.info("[ERROR] doSendMail : {}", e);
        }


        log.info("{}.doSendMail end!", this.getClass().getName());
        return res;
    }

    @Override
    public List<MailDTO> getMailList() throws Exception {

        log.info(this.getClass().getName() + ".getNoticeList start!");
        return mailMapper.getMailList();
    }
}
