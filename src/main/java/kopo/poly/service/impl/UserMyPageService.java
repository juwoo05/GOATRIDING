package kopo.poly.service.impl;

import kopo.poly.dto.UserMyPageDTO;
import kopo.poly.mapper.IUserMyPageMapper;
import kopo.poly.service.IUserMyPageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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

    /**
     * 닉네임 변경: USER_INFO + USER_RANK를 한 트랜잭션으로 동시 갱신
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updateUserName(UserMyPageDTO pDTO) throws Exception {
        log.info("[Service] updateUserName begin {}", pDTO);

        int a = userMyPageMapper.updateUserName(pDTO);        // USER_INFO
        int b = userMyPageMapper.updateUserNameInRank(pDTO);  // USER_RANK

        log.info("[Service] rows USER_INFO={}, USER_RANK={}", a, b);

        if (a <= 0) {
            log.warn("[Service] USER_INFO not updated. rollback.");
            throw new IllegalStateException("USER_INFO 닉네임 갱신 실패");
        }

        // USER_RANK 행이 아직 없는 사용자가 있을 수 있음 -> 필요하면 UPSERT 쿼리로 교체
        return a + Math.max(b, 0);
    }

    @Override
    public int updateProfileImage(UserMyPageDTO pDTO) throws Exception {
        log.info("[Service] updateProfileImage {}", pDTO);
        int r = userMyPageMapper.updateProfileImage(pDTO);
        log.info("[Service] 프로필 이미지 변경 rows={}", r);
        return r;
    }
}
