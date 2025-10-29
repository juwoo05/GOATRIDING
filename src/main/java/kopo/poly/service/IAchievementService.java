package kopo.poly.service;

import kopo.poly.dto.UserAchievementView;
import java.util.List;

public interface IAchievementService {
    // ✅ USER_ACHIEVEMENT에서 가져온 결과를 전달하는 서비스 인터페이스 (DB 구현부 제외)
    List<UserAchievementView> getUserAchievements(String userId) throws Exception;
}