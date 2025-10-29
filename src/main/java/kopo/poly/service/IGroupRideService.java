// kopo/poly/service/IGroupRideService.java
package kopo.poly.service;

import kopo.poly.dto.*;

import java.util.List;

public interface IGroupRideService {
    GroupRideListResDTO list(GroupRideListReqDTO req) throws Exception;
    GroupRideDTO create(GroupRideDTO req) throws Exception;
    GroupRideDTO join(GroupRideJoinDTO req) throws Exception;    // 참가
    GroupRideDTO cancel(GroupRideJoinDTO req) throws Exception;  // 취소
    // 추가
    List<UserMyPageDTO> members(GroupRideJoinDTO req) throws Exception;

}

