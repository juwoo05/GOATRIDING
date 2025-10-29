package kopo.poly.service;

import kopo.poly.dto.CommunityCommentDTO;
import kopo.poly.dto.CommunityDTO;

import java.util.List;
import java.util.Map;

public interface ICommunityService {

    CommunityDTO insertInfo(CommunityDTO pDTO) throws Exception;

    List<CommunityDTO> getInfoList() throws Exception;

    List<CommunityDTO> getInfoListWithLiked(String userId) throws Exception;

    Map<String, Object> toggleLike(String communityId, String userId) throws Exception;

    Map<String, Object> getPostDetailWithComments(String communityId, String loginUserId, int page, int size) throws Exception;

    CommunityCommentDTO addComment(String communityId, String userId, String contents) throws Exception;

}
