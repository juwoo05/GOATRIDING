// kopo/poly/service/IUserMyPageService.java
package kopo.poly.service;

import kopo.poly.dto.UserMyPageDTO;

public interface IUserMyPageService {
    UserMyPageDTO getMyPage(String userId) throws Exception;
    int updateUserName(UserMyPageDTO pDTO) throws Exception;     // void 금지 룰 반영
    int updateProfileImage(UserMyPageDTO pDTO) throws Exception; // void 금지 룰 반영
}
