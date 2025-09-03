package kopo.poly.service;

import kopo.poly.dto.CommunityDTO;

import java.util.List;

public interface ICommunityService {

    void insertInfo(CommunityDTO pDTO) throws Exception;

    List<CommunityDTO> getInfoList() throws Exception;

}
