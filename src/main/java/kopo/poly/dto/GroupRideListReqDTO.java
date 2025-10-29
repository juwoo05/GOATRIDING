// kopo/poly/dto/GroupRideListReqDTO.java
package kopo.poly.dto;
import lombok.*;

@Getter @Setter @Builder @AllArgsConstructor @NoArgsConstructor
public class GroupRideListReqDTO {
    private Integer page; // 1-base
    private Integer size;
    private String difficulty; // optional filter
    private String userId;     // 로그인 사용자(참여여부 표시용)
}

