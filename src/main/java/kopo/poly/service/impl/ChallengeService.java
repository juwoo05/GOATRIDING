package kopo.poly.service.impl;

import kopo.poly.dto.UserChallengeView;
import kopo.poly.mapper.IChallengeMapper;
import kopo.poly.service.IChallengeService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ChallengeService implements IChallengeService {

    private final IChallengeMapper challengeMapper;

    @Override
    public List<UserChallengeView> getUserChallenges(String userId) throws Exception {
        return challengeMapper.getUserChallenges(userId);
    }
}