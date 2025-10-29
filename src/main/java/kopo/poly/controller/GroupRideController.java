// kopo/poly/controller/GroupRideController.java
package kopo.poly.controller;

import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import kopo.poly.dto.*;
import kopo.poly.service.IGroupRideService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/groups")
public class GroupRideController {

    private final IGroupRideService service;

    // 참여자 목록 조회 (JSON)
    @GetMapping("/{id}/members")
    @ResponseBody
    public List<UserMyPageDTO> members(@PathVariable("id") Long rideId,
                                       HttpSession session) throws Exception {
        log.info("{}.noticeInfo Start!", this.getClass().getName());

        String ssUserId = (String) session.getAttribute("SS_USER_ID");
        GroupRideJoinDTO req = GroupRideJoinDTO.builder()
                .groupRideId(rideId)
                .userId(ssUserId) // 굳이 필요 없지만 로그/권한용으로 전달
                .build();

        log.info("GroupRideJoinDTO : {}", req);

        return service.members(req);
    }

    @GetMapping
    public ApiResponseDTO<GroupRideListResDTO> list(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String difficulty,
            @RequestParam(required = false) String userId
    ) throws Exception {
        GroupRideListReqDTO req = GroupRideListReqDTO.builder()
                .page(page).size(size).difficulty(difficulty).userId(userId).build();
        return ApiResponseDTO.ok(service.list(req));
    }

    @PostMapping("/create")
    public ApiResponseDTO<GroupRideDTO> create(@Valid @RequestBody GroupRideDTO req) throws Exception {
        return ApiResponseDTO.ok(service.create(req));
    }

    @PostMapping("/join")
    public ApiResponseDTO<GroupRideDTO> join(@Valid @RequestBody GroupRideJoinDTO req) throws Exception {
        return ApiResponseDTO.ok(service.join(req));
    }

    @PostMapping("/cancel")
    public ApiResponseDTO<GroupRideDTO> cancel(@Valid @RequestBody GroupRideJoinDTO req) throws Exception {
        return ApiResponseDTO.ok(service.cancel(req));
    }
}

