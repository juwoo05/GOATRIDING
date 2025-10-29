// kopo/poly/service/impl/EventRewardService.java
package kopo.poly.service.impl;

import kopo.poly.dto.*;
import kopo.poly.mapper.IEventRewardMapper;
import kopo.poly.service.IEventRewardService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class EventRewardService implements IEventRewardService {

    private final IEventRewardMapper mapper;

    @Override
    public List<EventItemDTO> items() throws Exception {
        log.info("[EventRewardService][items]");
        return mapper.selectItems();
    }

    @Override
    public PointsDTO getPoints(PointsDTO req) throws Exception {
        log.info("[EventRewardService][getPoints] req={}", req);
        PointsDTO p = mapper.selectUserPoints(req);
        if (p == null) return PointsDTO.builder().userId(req.getUserId()).points(0).build();
        return p;
    }

    @Override
    @Transactional
    public EventExchangeResDTO exchange(EventExchangeReqDTO req) throws Exception {
        log.info("[EventRewardService][exchange] req={}", req);

        // 총 포인트 계산
        int total = 0;
        for (EventCartItemDTO c : req.getItems()) {
            EventItemDTO item = mapper.selectItemById(EventItemDTO.builder().id(c.getItemId()).build());
            if (item == null) throw new IllegalStateException("ITEM_NOT_FOUND");
            total += item.getPointsCost() * c.getQty();
        }

        // 포인트 조건부 차감
        int dec = mapper.decrementPointsIfEnough(PointsDTO.builder().userId(req.getUserId()).points(total).build());
        if (dec != 1) throw new IllegalStateException("INSUFFICIENT_POINTS");

        // 아이템 재고 차감 (각 품목 조건부)
        for (EventCartItemDTO c : req.getItems()) {
            int stockDec = mapper.decrementStockIfEnough(
                    EventItemDTO.builder().id(c.getItemId()).stock(c.getQty()).build());
            if (stockDec != 1) throw new IllegalStateException("INSUFFICIENT_STOCK");
        }

        // 교환 이력 기록(단순히 첫 품목만 대표 영수증으로 저장하는 예시 - 필요 시 별도 테이블/배치로 확장)
        EventExchangeResDTO res = EventExchangeResDTO.builder()
                .userId(req.getUserId())
                .usedPoints(total)
                .exchangedItems(req.getItems())
                .build();
        mapper.insertExchangeOne(res);

        // 남은 포인트 조회
        PointsDTO remain = mapper.selectUserPoints(PointsDTO.builder().userId(req.getUserId()).build());
        res.setRemainingPoints(remain != null ? remain.getPoints() : 0);

        log.info("[EventRewardService][exchange] OK res={}", res);
        return res;
    }
}

