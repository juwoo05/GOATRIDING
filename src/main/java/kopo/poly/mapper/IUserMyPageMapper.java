package kopo.poly.mapper;

import kopo.poly.dto.UserMyPageDTO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface IUserMyPageMapper {

    UserMyPageDTO getMyPage(String userId);

    int updateUserName(UserMyPageDTO pDTO);           // USER_INFO 갱신
    int updateUserNameInRank(UserMyPageDTO pDTO);     // USER_RANK.user_name 갱신 (신규)
    int updateProfileImage(UserMyPageDTO pDTO);
}
