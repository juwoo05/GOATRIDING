// kopo/poly/dto/EventExchangeResDTO.java
package kopo.poly.dto;
import lombok.*;
import java.util.List;

@Getter @Setter @Builder @AllArgsConstructor @NoArgsConstructor
public class EventExchangeResDTO {
    private String userId;
    private Integer usedPoints;
    private Integer remainingPoints;
    private List<EventCartItemDTO> exchangedItems;
    private Long exchangeId; // 영수증 번호(첫 insert id, 혹은 배치의 대표 id)
}

