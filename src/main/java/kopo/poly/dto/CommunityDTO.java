// kopo/poly/dto/CommunityDTO.java
package kopo.poly.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;
import java.util.List;

@Getter
@Setter
public class CommunityDTO {

    private String userId;
    private String contents;
    private int likes;
    private Date chgDt;
    private String timeDiff;
    private String communityId;
    private boolean liked;

    // ✅ 여러 장 이미지
    private List<String> imageUrls;

    // (하위호환이 필요하면 유지)
    private String imageUrl; // 단일 이미지가 넘어오던 예전 필드(옵션)

    private int commentCount;
}
