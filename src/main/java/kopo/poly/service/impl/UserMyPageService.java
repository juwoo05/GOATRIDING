// kopo/poly/service/impl/UserMyPageService.java
package kopo.poly.service.impl;

import kopo.poly.dto.UserMyPageDTO;
import kopo.poly.mapper.IUserMyPageMapper;
import kopo.poly.service.IUserMyPageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@RequiredArgsConstructor
@Service
public class UserMyPageService implements IUserMyPageService {

    private final IUserMyPageMapper userMyPageMapper;

    @Override
    public UserMyPageDTO getMyPage(String userId) throws Exception {
        log.info("[Service] getMyPage userId={}", userId);
        UserMyPageDTO dto = userMyPageMapper.getMyPage(userId);

        if (dto != null) {
            log.info("[Service] result userName={}, email={}, points={}, distance={}, carbonSaved={}, level={}, profileImage={}",
                    dto.getUserName(), dto.getEmail(), dto.getPoints(), dto.getDistance(),
                    dto.getCarbonSaved(), dto.getLevel(), dto.getProfileImage());
        } else {
            log.warn("[Service] no result userId={}", userId);
        }
        return dto;
    }

    @Override
    public int updateUserName(UserMyPageDTO pDTO) throws Exception {
        log.info("[Service] updateUserName {}", pDTO);
        int r = userMyPageMapper.updateUserName(pDTO);
        log.info("[Service] 닉네임 변경 rows={}", r);
        return r;
    }

    @Override
    public int updateProfileImage(UserMyPageDTO pDTO) throws Exception {
        log.info("[Service] updateProfileImage {}", pDTO);
        int r = userMyPageMapper.updateProfileImage(pDTO);
        log.info("[Service] 프로필 이미지 변경 rows={}", r);
        return r;
    }
}
