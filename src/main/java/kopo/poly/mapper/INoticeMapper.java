package kopo.poly.mapper;

import kopo.poly.dto.NoticeDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface INoticeMapper {

    List<NoticeDTO> getNoticeList() throws Exception;

    void insertNoticeInfo(NoticeDTO pDTO) throws Exception;

    NoticeDTO getNoticeInfo(NoticeDTO pDTO) throws Exception;

    void updateNoticeReadCnt(NoticeDTO pDTO) throws Exception;

    void updateNoticeInfo(NoticeDTO pDTO) throws Exception;

    void deleteNotice(NoticeDTO pDTO) throws Exception;
}
