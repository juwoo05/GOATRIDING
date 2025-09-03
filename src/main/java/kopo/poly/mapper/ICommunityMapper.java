package kopo.poly.mapper;

import kopo.poly.dto.CommunityDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface ICommunityMapper {
    List<CommunityDTO> getInfoList() throws Exception;

    void insertInfo(CommunityDTO pDTO) throws Exception;
}
