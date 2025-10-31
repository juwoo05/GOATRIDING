package kopo.poly.service;

public interface IOnboardService {
    /**
     * 회원가입 직후 호출: USER_RANK / USER_ACHIEVEMENT / USER_CHALLENGE 초기화
     */
    void onUserSignup(String userId, String userName);
}