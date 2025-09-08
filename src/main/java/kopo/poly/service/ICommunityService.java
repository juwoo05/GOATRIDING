package kopo.poly.service;

import kopo.poly.dto.CommunityDTO;

import java.util.List;
import java.util.Map;

public interface ICommunityService {

    void insertInfo(CommunityDTO pDTO) throws Exception;

    List<CommunityDTO> getInfoList() throws Exception;

    List<CommunityDTO> getInfoListWithLiked(String userId) throws Exception;

    Map<String, Object> toggleLike(String communityId, String userId) throws Exception;
}
