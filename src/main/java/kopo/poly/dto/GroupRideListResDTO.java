// kopo/poly/dto/GroupRideListResDTO.java
package kopo.poly.dto;
import lombok.*;
import java.util.List;

@Getter @Setter @Builder @AllArgsConstructor @NoArgsConstructor
public class GroupRideListResDTO {
    private Integer page;
    private Integer size;
    private Long total;
    private List<GroupRideDTO> items;
}

