package kopo.poly.service;

import kopo.poly.dto.MailDTO;

import java.util.List;

public interface IMailService {

    List<MailDTO> getMailList() throws Exception;

    MailDTO getMailInfo(MailDTO pDTO) throws Exception;

    int doSendMail(MailDTO pDTO);
}
