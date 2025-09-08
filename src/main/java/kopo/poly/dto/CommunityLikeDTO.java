// 패키지는 프로젝트 구조에 맞게 조정
package kopo.poly.dto;

import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class CommunityLikeDTO {
    private String communityId; // 글 ID
    private String userId;      // 현재 로그인 유저 ID
}
