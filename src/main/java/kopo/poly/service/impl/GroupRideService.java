// kopo/poly/service/impl/GroupRideService.java
package kopo.poly.service.impl;

import kopo.poly.dto.*;
import kopo.poly.mapper.IEventRewardMapper;
import kopo.poly.mapper.IGroupRideMapper;
import kopo.poly.service.IGroupRideService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class GroupRideService implements IGroupRideService {

    private final IGroupRideMapper rideMapper;
    private final IEventRewardMapper rewardMapper; // 포인트/거리 업데이트 위해

    @Override
    public List<UserMyPageDTO> members(GroupRideJoinDTO req) throws Exception {
        log.info("[GroupRideService][members] groupRideId={}, userId={}",
                req.getGroupRideId(), req.getUserId());
        return rideMapper.selectMembersByRide(req);
    }

    @Override
    public GroupRideListResDTO list(GroupRideListReqDTO req) throws Exception {
        log.info("[GroupRideService][list] req={}", req);
        List<GroupRideDTO> rows = rideMapper.selectGroupRides(req);
        Long total = rideMapper.countGroupRides(req);

        // joinedCount & joined 여부 채우기
        for (GroupRideDTO r : rows) {
            GroupRideJoinDTO jr = GroupRideJoinDTO.builder()
                    .groupRideId(r.getId())
                    .userId(req.getUserId())
                    .build();
            r.setJoinedCount(rideMapper.countJoinedByRide(jr));
            r.setJoined(req.getUserId() != null && rideMapper.existsJoin(jr) > 0);
        }

        return GroupRideListResDTO.builder()
                .page(req.getPage())
                .size(req.getSize())
                .total(total)
                .items(rows)
                .build();
    }

    @Override
    @Transactional
    public GroupRideDTO create(GroupRideDTO req) throws Exception {
        log.info("[GroupRideService][create] req={}", req);

        // 1) 그룹라이드 생성
        rideMapper.insertGroupRide(req); // useGeneratedKeys=true 이므로 req.id 채워짐

        // 2) 생성자(organizer)가 자동 참가되도록 JOIN 테이블에 즉시 등록
        GroupRideJoinDTO creatorJoin = GroupRideJoinDTO.builder()
                .groupRideId(req.getId())
                .userId(req.getOrganizerId())
                .build();

        // 혹시 모를 중복 방지(이상 상황 대비)
        int already = rideMapper.existsJoin(creatorJoin);
        if (already == 0) {
            rideMapper.insertJoin(creatorJoin);
            log.info("[GroupRideService][create] organizer auto-joined. rideId={}, userId={}",
                    req.getId(), req.getOrganizerId());
        } else {
            log.info("[GroupRideService][create] organizer was already joined. rideId={}, userId={}",
                    req.getId(), req.getOrganizerId());
        }

        rewardMapper.incrementPoints(PointsDTO.builder()
                .userId(req.getOrganizerId())
                .points(10)
                .build());


        // 3) 최신 상태 조회해서 반환 (joinedCount/joined 채워서 내려줌)
        GroupRideDTO out = rideMapper.selectGroupRideById(
                GroupRideDTO.builder().id(req.getId()).build()
        );
        out.setJoinedCount(rideMapper.countJoinedByRide(creatorJoin)); // 최소 1이어야 함
        out.setJoined(true); // 생성자는 자동 참가 상태

        return out;
    }


    @Override
    @Transactional
    public GroupRideDTO join(GroupRideJoinDTO req) throws Exception {
        log.info("[GroupRideService][join] req={}", req);

        GroupRideDTO ride = rideMapper.selectGroupRideById(GroupRideDTO.builder().id(req.getGroupRideId()).build());
        if (ride == null) throw new IllegalStateException("NOT_FOUND");

        int already = rideMapper.existsJoin(req);
        if (already > 0) throw new IllegalStateException("ALREADY_JOINED");

        int current = rideMapper.countJoinedByRide(req);
        if (current >= ride.getMaxParticipants()) throw new IllegalStateException("FULL");

        rideMapper.insertJoin(req);

        // 보상 정책: 참가 시 즉시 +10 포인트(예시), 거리 합산은 실제 라이딩 완료시 별도 처리해도 됨
        rewardMapper.incrementPoints(PointsDTO.builder().userId(req.getUserId()).points(10).build());

        // 최신 joinedCount/상태 갱신해서 반환
        GroupRideDTO out = rideMapper.selectGroupRideById(GroupRideDTO.builder().id(req.getGroupRideId()).build());
        out.setJoinedCount(rideMapper.countJoinedByRide(req));
        out.setJoined(true);
        return out;
    }

    @Override
    @Transactional
    public GroupRideDTO cancel(GroupRideJoinDTO req) throws Exception {
        log.info("[GroupRideService][cancel] req={}", req);

        GroupRideDTO ride = rideMapper.selectGroupRideById(GroupRideDTO.builder().id(req.getGroupRideId()).build());
        if (ride == null) throw new IllegalStateException("NOT_FOUND");

        int exists = rideMapper.existsJoin(req);
        if (exists == 0) throw new IllegalStateException("NOT_JOINED");

        rideMapper.deleteJoin(req);

        // 정책: 취소 시 포인트 -10 (음수 방지 필요 시 조건 추가)
        rewardMapper.incrementPoints(PointsDTO.builder().userId(req.getUserId()).points(-10).build());

        GroupRideDTO out = rideMapper.selectGroupRideById(GroupRideDTO.builder().id(req.getGroupRideId()).build());
        out.setJoinedCount(rideMapper.countJoinedByRide(req));
        out.setJoined(false);
        return out;
    }
}
