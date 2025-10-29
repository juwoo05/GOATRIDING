// kopo/poly/controller/EventRewardController.java
package kopo.poly.controller;

import jakarta.validation.Valid;
import kopo.poly.dto.*;
import kopo.poly.service.IEventRewardService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/events")
public class EventRewardController {

    private final IEventRewardService service;

    @GetMapping("/items")
    public ApiResponseDTO<List<EventItemDTO>> items() throws Exception {
        return ApiResponseDTO.ok(service.items());
    }

    @GetMapping("/points")
    public ApiResponseDTO<PointsDTO> points(@RequestParam String userId) throws Exception {
        return ApiResponseDTO.ok(service.getPoints(PointsDTO.builder().userId(userId).build()));
    }

    @PostMapping("/exchange")
    public ApiResponseDTO<EventExchangeResDTO> exchange(@Valid @RequestBody EventExchangeReqDTO req) throws Exception {
        return ApiResponseDTO.ok(service.exchange(req));
    }
}
