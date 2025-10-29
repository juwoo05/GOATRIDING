package kopo.poly.service.impl;

import kopo.poly.dto.MailDTO;
import kopo.poly.dto.UserAchievementView;
import kopo.poly.dto.UserDTO;
import kopo.poly.dto.UserInfoDTO;
import kopo.poly.mapper.IAchievementMapper;
import kopo.poly.mapper.IUserInfoMapper;
import kopo.poly.service.IMailService;
import kopo.poly.service.IUserInfoService;
import kopo.poly.util.CmmUtil;
import kopo.poly.util.EncryptUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.concurrent.ThreadLocalRandom;

@Slf4j
@RequiredArgsConstructor
@Service
public class UserInfoService implements IUserInfoService {

    private final IUserInfoMapper userInfoMapper;     // 유저 정보 관련 매퍼
    private final IMailService mailService;           // 메일 발송 서비스
    private final IAchievementMapper achievementMapper; // ✅ 업적 초기화 매퍼

    /**
     * 회원가입 처리
     * - USER_INFO 저장
     * - USER_RANK 기본 데이터 생성
     * - USER_ACHIEVEMENT 기본 업적들 생성 (progress=0)
     * - 축하 메일 발송
     */
    @Override
    public int insertUserInfo(UserInfoDTO pDTO) throws Exception {

        log.info("{}.insertUserInfo Start!", this.getClass().getName());
        log.info("가입 요청: userId={}, password={}", pDTO.getUserId(), pDTO.getPassword());

        int res;
        int success = userInfoMapper.insertUserInfo(pDTO); // USER_INFO 테이블에 유저 저장

        if (success > 0) { // DB insert 성공 시
            // 1) USER_RANK 테이블에 기본 랭킹 데이터 생성
            UserDTO rDTO = new UserDTO();
            rDTO.setUserId(pDTO.getUserId());
            rDTO.setUserName(pDTO.getUserName());
            rDTO.setLevel(1);
            rDTO.setAchievements(0);
            rDTO.setChallenges(0);
            rDTO.setAvatar("🚴");
            rDTO.setPoints(0);
            rDTO.setDistance(0.0);
            rDTO.setCarbonSaved(0.0);

            userInfoMapper.insertUserRank(rDTO);

            // 2) USER_ACHIEVEMENT 테이블 초기화 (모든 업적 progress=0으로 세팅)
            List<UserAchievementView> achievements = achievementMapper.getAllAchievements();
            for (UserAchievementView a : achievements) {
                achievementMapper.insertUserAchievement(
                        pDTO.getUserId(),   // 가입한 유저 ID
                        a.getId(),          // 업적 ID
                        0,                  // 시작 progress = 0
                        a.getTarget()       // 업적 목표값
                );
            }

            // 3) 회원가입 축하 메일 발송
            MailDTO mDTO = new MailDTO();
            mDTO.setToMail(EncryptUtil.decAES128CBC(CmmUtil.nvl(pDTO.getEmail()))); // 암호화된 이메일 복호화
            mDTO.setTitle("회원가입을 축하드립니다."); // 제목
            mDTO.setContents(CmmUtil.nvl(pDTO.getUserName()) + " 님의 회원가입을 진심으로 축하드립니다.");
            mailService.doSendMail(mDTO);

            res = 1; // 성공
        } else {
            res = 0; // 실패
        }

        log.info("{}.insertUserInfo End!", this.getClass().getName());

        return res;
    }

    /**
     * 유저 랭킹 데이터 생성 (직접 호출 시 사용 가능)
     */
    @Override
    public void createUser(UserInfoDTO dto) throws Exception {
        UserDTO rDTO = new UserDTO();

        rDTO.setUserId(dto.getUserId());
        rDTO.setUserName(dto.getUserName());
        rDTO.setPoints(0);
        rDTO.setDistance(0.0);
        rDTO.setCarbonSaved(0.0);
        rDTO.setLevel(1);
        rDTO.setAchievements(0);
        rDTO.setChallenges(0);
        rDTO.setAvatar("🚴");

        userInfoMapper.insertUserRank(rDTO);
    }

    /**
     * 비밀번호 변경 처리
     */
    @Override
    public int newPasswordProc(UserInfoDTO pDTO) throws Exception {
        log.info("{}.newPasswordProc Start!", this.getClass().getName());
        int success = userInfoMapper.updatePassword(pDTO);
        log.info("{}.newPasswordProc End!", this.getClass().getName());
        return success;
    }

    /**
     * 아이디 / 비밀번호 찾기
     */
    @Override
    public UserInfoDTO searchUserIdOrPasswordProc(UserInfoDTO pDTO) throws Exception {
        log.info("{}.seachUserIdOrPasswordProc Start", this.getClass().getName());
        UserInfoDTO rDTO = userInfoMapper.getUserId(pDTO);
        log.info("{}.searchUserIdOrPasswordProc End", this.getClass().getName());
        return rDTO;
    }

    /**
     * 로그인 처리 + 로그인 알림 메일 발송
     */
    @Override
    public UserInfoDTO getLogin(UserInfoDTO pDTO) throws Exception {
        log.info("{}.getLogin Start!", this.getClass().getName());

        UserInfoDTO rDTO = Optional.ofNullable(userInfoMapper.getLogin(pDTO))
                .orElseGet(UserInfoDTO::new);

        if (!CmmUtil.nvl(rDTO.getUserId()).isEmpty()) {
            // 로그인 성공 시 알림 메일 발송
            MailDTO mDTO  = new MailDTO();
            mDTO.setToMail(EncryptUtil.decAES128CBC(CmmUtil.nvl(rDTO.getEmail())));
            mDTO.setTitle("로그인 알림!");
            mDTO.setContents(CmmUtil.nvl(rDTO.getUserName()) + "님이 로그인하였습니다.");
            mailService.doSendMail(mDTO);
        }

        log.info("{}.getLogin End!", this.getClass().getName());
        return rDTO;
    }

    /**
     * 아이디 존재 여부 확인
     */
    @Override
    public UserInfoDTO getUserIdExists(UserInfoDTO pDTO) throws Exception {
        return userInfoMapper.getUserIdExists(pDTO);
    }

    /**
     * 이메일 중복 확인 + 인증번호 발송
     */
    @Override
    public UserInfoDTO getEmailExists(UserInfoDTO pDTO) throws Exception {
        UserInfoDTO rDTO = Optional.ofNullable(userInfoMapper.getEmailExists(pDTO))
                .orElseGet(UserInfoDTO::new);

        if (CmmUtil.nvl(rDTO.getExistsYn()).equals("N")) {
            // 이메일이 존재하지 않는 경우 → 인증번호 발송
            int authNumber = ThreadLocalRandom.current().nextInt(100000, 1000000);
            MailDTO dto = new MailDTO();
            dto.setTitle("이메일 중복 확인 인증번호 발송 메일");
            dto.setContents("인증번호는 " + authNumber + " 입니다.");
            dto.setToMail(EncryptUtil.decAES128CBC(CmmUtil.nvl(pDTO.getEmail())));
            mailService.doSendMail(dto);
            rDTO.setAuthNumber(authNumber);
        }

        return rDTO;
    }

    /**
     * 이메일로 아이디 찾기 + 인증번호 발송
     */
    @Override
    public UserInfoDTO getUserIdByEmail(UserInfoDTO pDTO) throws Exception {
        UserInfoDTO rDTO = Optional.ofNullable(userInfoMapper.getEmailExists(pDTO))
                .orElseGet(UserInfoDTO::new);

        if (CmmUtil.nvl(rDTO.getExistsYn()).equals("Y")) {
            int authNumber = ThreadLocalRandom.current().nextInt(100000, 1000000);
            MailDTO dto = new MailDTO();
            dto.setTitle("이메일로 아이디 찾기 인증번호 발송 메일");
            dto.setContents("인증번호는 " + authNumber + " 입니다.");
            dto.setToMail(EncryptUtil.decAES128CBC(CmmUtil.nvl(pDTO.getEmail())));
            mailService.doSendMail(dto);
            rDTO.setAuthNumber(authNumber);
        }

        return rDTO;
    }
}
