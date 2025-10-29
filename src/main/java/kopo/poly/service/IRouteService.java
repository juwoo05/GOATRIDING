package kopo.poly.service;

import kopo.poly.dto.RouteDTO;
import kopo.poly.dto.RoutePointDTO;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface IRouteService {

    // GPX 파싱/IO가 있으므로 throws 유지 (필요 시 구체화 가능)
    Long uploadGpx(String name, MultipartFile file) throws Exception;

    // 단순 조회 -> 체크 예외 제거
    List<RouteDTO> listRoutes();

    List<RoutePointDTO> getRoutePoints(Long routeId);
}
