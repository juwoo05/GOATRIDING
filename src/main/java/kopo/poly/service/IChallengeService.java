package kopo.poly.service;

import kopo.poly.dto.UserChallengeView;

import java.util.List;

public interface IChallengeService {
    List<UserChallengeView> getUserChallenges(String userId) throws Exception;
}