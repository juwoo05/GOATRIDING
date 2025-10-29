// kopo/poly/dto/EventCartItemDTO.java
package kopo.poly.dto;
import lombok.*;

@Getter @Setter @Builder @AllArgsConstructor @NoArgsConstructor
public class EventCartItemDTO {
    private Long itemId;
    private Integer qty;
}

