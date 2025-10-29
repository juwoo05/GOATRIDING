package kopo.poly.service.impl;

import kopo.poly.dto.CommunityCommentDTO;
import kopo.poly.dto.CommunityDTO;
import kopo.poly.dto.CommunityLikeDTO;
import kopo.poly.mapper.ICommunityMapper;
import kopo.poly.service.ICommunityService;
import kopo.poly.util.DateUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@RequiredArgsConstructor
@Service
public class CommunityService implements ICommunityService {

    private final ICommunityMapper communityMapper;

    @Override
    public Map<String, Object> getPostDetailWithComments(String communityId, String loginUserId, int page, int size) throws Exception {
        CommunityLikeDTO likeCtx = new CommunityLikeDTO();
        likeCtx.setCommunityId(communityId);
        likeCtx.setUserId(loginUserId);

        CommunityDTO post = communityMapper.selectPostDetailWithLiked(likeCtx);
        if (post == null) {
            return Map.of(
                    "post", null,
                    "comments", java.util.Collections.emptyList(),
                    "total", 0,
                    "page", page,
                    "size", size
            );
        }

        if (post.getChgDt() != null) {
            post.setTimeDiff(kopo.poly.util.DateUtil.calculateTime(post.getChgDt()));
        }
        log.info("시간 차이 이 씨부랄련아 {}", post.getTimeDiff());

        // 총 댓글 수
        CommunityCommentDTO countQ = new CommunityCommentDTO();
        countQ.setCommunityId(communityId);
        int total = communityMapper.countCommentsByCommunityId(countQ);
        log.info("댓글 개수 : {}", total);
        // 페이지 목록 조회 (Map 파라미터로 @Param 없이 limit/offset 전달)
        int offset = Math.max(0, (page - 1) * size);
        java.util.Map<String, Object> listParam = new java.util.HashMap<>();
        listParam.put("communityId", communityId);
        listParam.put("_limit", size);
        listParam.put("_offset", offset);

        List<CommunityCommentDTO> comments = communityMapper.selectCommentsByCommunityId(listParam);

        for (CommunityCommentDTO c : comments) {
            if (c.getChgDt() != null) {
                c.setTimeDiff(kopo.poly.util.DateUtil.calculateTime(c.getChgDt()));
            }
        }

        log.info("post 가 뭥이여 {}", post);
        Map<String, Object> res = new java.util.HashMap<>();
        res.put("post", post);
        res.put("comments", comments == null ? java.util.Collections.emptyList() : comments);
        res.put("total", total);
        res.put("page", page);
        res.put("size", size);
        log.info("res 잉 아잇 {}", res);
        return res;
    }


    @Override
    public CommunityCommentDTO addComment(String communityId, String userId, String contents) throws Exception {
        CommunityCommentDTO dto = new CommunityCommentDTO();
        dto.setCommunityId(communityId);
        dto.setUserId(userId);
        dto.setContents(contents);

        communityMapper.insertComment(dto);
        return dto; // void 금지 ✅
    }


    @Transactional
    @Override
    public CommunityDTO insertInfo(CommunityDTO pDTO) throws Exception {
        log.info("{}.insertInfo start!", getClass().getName());

        // 1) 글 저장 + PK 채우기
        communityMapper.insertInfo(pDTO); // useGeneratedKeys로 communityId 세팅됨
        log.info("inserted communityId={}", pDTO.getCommunityId());

        // 2) 이미지 저장 (여러 장)
        if (pDTO.getImageUrls() != null && !pDTO.getImageUrls().isEmpty()) {
            communityMapper.insertImages(pDTO);
        } else if (pDTO.getImageUrl() != null && !pDTO.getImageUrl().isEmpty()) {
            // 하위호환(단일 이미지가 넘어온 경우)
            communityMapper.insertImage(pDTO);
        }

        return pDTO; // ✅ void 금지
    }

    @Override
    public List<CommunityDTO> getInfoList() throws Exception {

        log.info(this.getClass().getName() + ".getInfoList start!");
        return communityMapper.getInfoList();
    }

    @Override
    public List<CommunityDTO> getInfoListWithLiked(String userId) throws Exception {
        CommunityLikeDTO dto = new CommunityLikeDTO();
        dto.setUserId(userId);

        List<CommunityDTO> list = communityMapper.selectCommunityListWithLiked(dto);

        for (CommunityDTO c : list) {
            if (c.getChgDt() != null) c.setTimeDiff(DateUtil.calculateTime(c.getChgDt()));
            else c.setTimeDiff("");
        }
        return list;
    }

    @Override
    public Map<String, Object> toggleLike(String communityId, String userId) throws Exception {
        CommunityLikeDTO req = new CommunityLikeDTO();
        req.setCommunityId(communityId);
        req.setUserId(userId);

        boolean already = communityMapper.existsUserLike(req) > 0;
        if (already) {
            communityMapper.deleteLike(req);
            communityMapper.decLikes(req);
        } else {
            communityMapper.insertLike(req);
            communityMapper.incLikes(req);
        }
        Integer likes = communityMapper.selectLikeCount(req);

        Map<String, Object> res = new HashMap<>();
        res.put("liked", !already);
        res.put("likes", likes == null ? 0 : likes);
        return res;
    }
}
