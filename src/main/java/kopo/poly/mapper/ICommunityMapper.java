package kopo.poly.mapper;

import kopo.poly.dto.CommunityDTO;
import kopo.poly.dto.CommunityLikeDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface ICommunityMapper {
    List<CommunityDTO> getInfoList() throws Exception;

    void insertInfo(CommunityDTO pDTO) throws Exception;

    // 로그인 유저 기준 liked 포함 리스트
    List<CommunityDTO> selectCommunityListWithLiked(CommunityLikeDTO dto);

    // 좋아요 존재 여부
    int existsUserLike(CommunityLikeDTO dto);

    // 좋아요 추가/삭제
    int insertLike(CommunityLikeDTO dto);
    int deleteLike(CommunityLikeDTO dto);

    // 총 좋아요 카운트 증감 및 조회
    int incLikes(CommunityLikeDTO dto);
    int decLikes(CommunityLikeDTO dto);
    Integer selectLikeCount(CommunityLikeDTO dto);
}
