// kopo/poly/dto/GroupRideDTO.java
package kopo.poly.dto;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalTime;

@Getter @Setter @Builder @AllArgsConstructor @NoArgsConstructor
public class GroupRideDTO {
    private Long id;
    private String title;
    private String organizerId;
    private String organizerName;
    private LocalDate date;
    private LocalTime time;
    private String location;
    private Float distance;
    private Integer maxParticipants;
    private String difficulty;

    // 조회 전용
    private Integer joinedCount;  // 현재 참가자 수 (JOIN 테이블 count)
    private Boolean joined;       // 내가 참가했는지 여부
}

