package kopo.poly.service.impl;

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


    @Transactional
    @Override
    public void insertInfo(CommunityDTO pDTO) throws Exception {
        log.info("{}.insertNoticeInfo start!", this.getClass().getName());
        communityMapper.insertInfo(pDTO);
    }

    @Override
    public List<CommunityDTO> getInfoList() throws Exception {

        log.info(this.getClass().getName() + ".getInfoList start!");
        return communityMapper.getInfoList();
    }

    @Override
    public List<CommunityDTO> getInfoListWithLiked(String userId) throws Exception {
        CommunityLikeDTO dto = new CommunityLikeDTO();
        dto.setUserId(userId); // 로그인 안 했으면 null 가능

        List<CommunityDTO> list = communityMapper.selectCommunityListWithLiked(dto);

        // ✅ 여기서 상대시간 계산해서 DTO에 주입
        for (CommunityDTO c : list) {
            if (c.getChgDt() != null) {
                c.setTimeDiff(DateUtil.calculateTime(c.getChgDt()));
            } else {
                c.setTimeDiff(""); // 혹시 null일 때 대비
            }
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
