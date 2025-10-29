// kopo/poly/dto/EventItemDTO.java
package kopo.poly.dto;
import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder @AllArgsConstructor @NoArgsConstructor
public class EventItemDTO {
    private Long id;
    private String name;
    private String description;
    private Integer pointsCost;
    private String category;
    private String image;
    private Integer stock;
    private Boolean popular;
    private LocalDateTime timeLimit;
}
