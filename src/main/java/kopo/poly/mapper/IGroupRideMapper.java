// kopo/poly/mapper/IGroupRideMapper.java
package kopo.poly.mapper;

import kopo.poly.dto.GroupRideDTO;
import kopo.poly.dto.GroupRideJoinDTO;
import kopo.poly.dto.GroupRideListReqDTO;
import kopo.poly.dto.UserMyPageDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface IGroupRideMapper {
    List<GroupRideDTO> selectGroupRides(GroupRideListReqDTO req);
    Long countGroupRides(GroupRideListReqDTO req);
    GroupRideDTO selectGroupRideById(GroupRideDTO req);
    Integer insertGroupRide(GroupRideDTO req);

    // 참여 관련
    Integer insertJoin(GroupRideJoinDTO req);          // UNIQUE 위반 시 예외
    Integer deleteJoin(GroupRideJoinDTO req);
    Integer countJoinedByRide(GroupRideJoinDTO req);   // 그룹 참가자 수
    Integer existsJoin(GroupRideJoinDTO req);          // 0/1

    // 추가
    List<UserMyPageDTO> selectMembersByRide(GroupRideJoinDTO pDTO) throws Exception;

}
