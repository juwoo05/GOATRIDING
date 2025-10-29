// kopo/poly/service/IEventRewardService.java
package kopo.poly.service;
import kopo.poly.dto.*;
import java.util.List;

public interface IEventRewardService {
    List<EventItemDTO> items() throws Exception;
    PointsDTO getPoints(PointsDTO req) throws Exception;
    EventExchangeResDTO exchange(EventExchangeReqDTO req) throws Exception;
}

