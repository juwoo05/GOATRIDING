// kopo/poly/mapper/IEventRewardMapper.java
package kopo.poly.mapper;

import kopo.poly.dto.EventExchangeResDTO;
import kopo.poly.dto.EventItemDTO;
import kopo.poly.dto.PointsDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface IEventRewardMapper {
    // 아이템
    List<EventItemDTO> selectItems();
    EventItemDTO selectItemById(EventItemDTO req);
    Integer decrementStockIfEnough(EventItemDTO req); // WHERE stock >= ?

    // 교환
    Integer insertExchangeOne(EventExchangeResDTO req); // 단건 기록용(배치면 반복)

    // 포인트 (USER_RANK)
    PointsDTO selectUserPoints(PointsDTO req);
    Integer decrementPointsIfEnough(PointsDTO req);     // WHERE points >= ?
    Integer incrementPoints(PointsDTO req);             // (그룹보상 등)
    Integer addDistance(PointsDTO req);                 // (그룹참여 보상용: distance += X)
}
