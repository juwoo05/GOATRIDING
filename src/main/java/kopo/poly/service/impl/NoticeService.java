package kopo.poly.service.impl;

import kopo.poly.dto.NoticeDTO;
import kopo.poly.mapper.INoticeMapper;
import kopo.poly.service.INoticeService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
@Slf4j
@RequiredArgsConstructor
@Service

public class NoticeService implements INoticeService {

    private final INoticeMapper noticeMapper;

    @Override
    public List<NoticeDTO> getNoticeList() throws Exception {

        log.info(this.getClass().getName() + ".getNoticeList start!");
        return noticeMapper.getNoticeList();
    }

    @Transactional
    @Override
    public NoticeDTO getNoticeInfo(NoticeDTO pDTO, boolean type) throws Exception {

        log.info("{}.getNoticeInfo start!", this.getClass().getName());

        if (type) {
            log.info("Update ReadCNT");
            noticeMapper.updateNoticeReadCnt(pDTO);
        }

        return noticeMapper.getNoticeInfo(pDTO);
    }

    @Transactional
    @Override
    public void insertNoticeInfo(NoticeDTO pDTO) throws Exception {
        log.info("{}.insertNoticeInfo start!", this.getClass().getName());

        noticeMapper.insertNoticeInfo(pDTO);
    }

    @Override
    public void updateNoticeInfo(NoticeDTO pDTO) throws Exception {

        log.info("{}.updateNoticeInfo start!", this.getClass().getName());

        noticeMapper.updateNoticeInfo(pDTO);
    }

    @Transactional
    @Override
    public void deleteNoticeInfo(NoticeDTO pDTO) throws Exception {

        log.info("{}.deleteNoticeInfo start!", this.getClass().getName());

        noticeMapper.deleteNotice(pDTO);
    }
}
