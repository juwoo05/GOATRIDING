package kopo.poly.controller;

import kopo.poly.dto.RouteDTO;
import kopo.poly.dto.RoutePointDTO;
import kopo.poly.service.IRouteService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@Slf4j
@RequiredArgsConstructor
@RequestMapping("routes")
@Controller
public class RouteController {

    private final IRouteService routeService;

    /** GPX 업로드 */
    @PostMapping(value = "/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Map<String, Object>> upload(
            @RequestParam("gpxFile") MultipartFile gpxFile,
            @RequestParam(value = "name", required = false) String name) throws Exception {
        long routeId = routeService.uploadGpx(name, gpxFile);
        return ResponseEntity.ok(Map.of("routeId", routeId));
    }

    /** 추천 경로 목록 */
    @ResponseBody
    @GetMapping(value = "list", produces = "application/json; charset=UTF-8")
    public List<RouteDTO> list() throws Exception {
        return routeService.listRoutes();
    }

    /** 특정 경로의 좌표 */
    @ResponseBody
    @GetMapping(value = "{routeId}/points", produces = "application/json; charset=UTF-8")
    public List<RoutePointDTO> points(@PathVariable("routeId") Long routeId) throws Exception {
        return routeService.getRoutePoints(routeId);
    }
}
