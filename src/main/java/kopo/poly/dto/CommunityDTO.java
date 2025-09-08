package kopo.poly.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;

@Getter
@Setter
public class CommunityDTO {

    private String userId;

    private String contents;

    private int likes;

    private Date chgDt;

    private String timeDiff;

    private String communityId;

    // ✅ 현재 로그인 유저 기준으로 이 글을 좋아요 눌렀는지
    private boolean liked; // <-- 추가

}
