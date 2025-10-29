// kopo/poly/mapper/IUserMyPageMapper.java
package kopo.poly.mapper;

import kopo.poly.dto.UserMyPageDTO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface IUserMyPageMapper {

    UserMyPageDTO getMyPage(String userId);          // 조회는 단일 파라미터 OK
    int updateUserName(UserMyPageDTO pDTO);          // 항상 DTO 하나
    int updateProfileImage(UserMyPageDTO pDTO);      // 항상 DTO 하나
}
