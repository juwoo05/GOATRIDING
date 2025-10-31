package kopo.poly.service;

public interface IRankBadgeService {
    /** 업적/도전과제 개수를 다시 계산해서 USER_RANK에 반영 */
    void recalcBadgeCounts(String userId);
}