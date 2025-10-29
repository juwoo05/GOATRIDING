package kopo.poly.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;

@Getter
@Setter
public class CommunityCommentDTO {
    private String commentId;
    private String communityId;
    private String userId;
    private String contents;
    private Date chgDt;
    private String timeDiff;
}
