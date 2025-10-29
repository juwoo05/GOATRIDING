package kopo.poly.mapper;

import kopo.poly.dto.RouteDTO;
import kopo.poly.dto.RoutePointDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface IRouteMapper {

    int insertRoute(RouteDTO dto);  // useGeneratedKeys로 ROUTE_ID 채움

    int bulkInsertPoints(@Param("routeId") Long routeId,
                         @Param("list") List<RoutePointDTO> list);

    List<RouteDTO> listRoutes();

    List<RoutePointDTO> getRoutePoints(@Param("routeId") Long routeId);
}
