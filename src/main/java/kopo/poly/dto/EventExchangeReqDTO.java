// kopo/poly/dto/EventExchangeReqDTO.java
package kopo.poly.dto;
import lombok.*;
import java.util.List;

@Getter @Setter @Builder @AllArgsConstructor @NoArgsConstructor
public class EventExchangeReqDTO {
    private String userId;
    private List<EventCartItemDTO> items;
}

