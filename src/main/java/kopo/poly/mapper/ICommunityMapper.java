package kopo.poly.mapper;

import kopo.poly.dto.CommunityCommentDTO;
import kopo.poly.dto.CommunityDTO;
import kopo.poly.dto.CommunityLikeDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface ICommunityMapper {

    // ----- Community 기본 -----
    List<CommunityDTO> getInfoList() throws Exception;

    // useGeneratedKeys 로 COMMUNITY_ID 세팅 + 영향 행 수 반환
    int insertInfo(CommunityDTO pDTO) throws Exception;

    // ----- 이미지 저장 -----
    // 단일 이미지(하위호환용)
    int insertImage(CommunityDTO pDTO) throws Exception;

    // 다건 이미지(최대 6장)
    int insertImages(CommunityDTO pDTO) throws Exception;

    // 글별 이미지 목록 (resultType=String, ORDER BY image_id ASC)
    List<String> selectImagesByCommunityId(String communityId);

    // ----- 목록 + liked 플래그 -----
    // 로그인 유저 기준 liked 포함 리스트 (resultMap으로 imageUrls 채움)
    List<CommunityDTO> selectCommunityListWithLiked(CommunityLikeDTO dto);

    // ----- 좋아요 토글 관련 -----
    int existsUserLike(CommunityLikeDTO dto);  // 존재 여부
    int insertLike(CommunityLikeDTO dto);      // 좋아요 추가
    int deleteLike(CommunityLikeDTO dto);      // 좋아요 삭제

    int incLikes(CommunityLikeDTO dto);        // 총 좋아요 +1
    int decLikes(CommunityLikeDTO dto);        // 총 좋아요 -1 (0 하한)
    Integer selectLikeCount(CommunityLikeDTO dto); // 현재 좋아요 수

    // ----- 단건 조회(모달용) + 이미지/liked 포함 -----
    CommunityDTO selectPostDetailWithLiked(CommunityLikeDTO dto);

    // ----- 댓글 -----
    int insertComment(CommunityCommentDTO dto);                  // 댓글 등록
    int countCommentsByCommunityId(CommunityCommentDTO dto);     // 총 개수
    java.util.List<kopo.poly.dto.CommunityCommentDTO> selectCommentsByCommunityId(java.util.Map<String,Object> map);


}
