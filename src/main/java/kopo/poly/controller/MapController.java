package kopo.poly.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.List;

@Controller
public class MapController {

    // ✅ application.properties(.yml)에 넣어둔 카카오 키 주입
    @Value("${kakao.jsKey}")
    private String kakaoJsKey;

    @Value("${kakao.mobilityRestKey}")
    private String kakaoMobilityRestKey;

    @GetMapping("/map/map")
    public String showMap(Model model) throws JsonProcessingException {

        // --- 더미 데이터 (그대로 사용/교체 자유) ---
        List<DangerousArea> areas = List.of(
                new DangerousArea("1", "강남역 사거리", 37.4979, 127.0276, "high", "지난달 3건 사고", 3),
                new DangerousArea("2", "교대역 근처",   37.4935, 127.0146, "medium","지난주 1건 사고", 1)
        );

        List<RoutePoint> r1 = List.of(
                new RoutePoint(37.4979, 127.0276),   // 강남역
                new RoutePoint(37.5665, 126.9780)    // 서울시청
        );
        List<RoutePoint> r2 = List.of(
                new RoutePoint(37.4979, 127.0276),
                new RoutePoint(37.5410, 126.9860)    // 서울역 근방
        );

        List<RecommendedRoute> routes = List.of(
                new RecommendedRoute("r1","최단 경로","fastest","4.2km","12분",2,"약간 오르막","easy", r1,"간단 경로"),
                new RecommendedRoute("r2","안전 경로","safest", "5.0km","15분",0,"평지 위주","easy", r2,"사고 적은 경로")
        );

        ObjectMapper m = new ObjectMapper();
        model.addAttribute("dangerousAreasJson", m.writeValueAsString(areas));
        model.addAttribute("recommendedRoutesJson", m.writeValueAsString(routes));

        // ✅ 카카오 키 JSP로 전달 (REST 키는 개발 중 테스트 용도)
        model.addAttribute("kakaoJsKey", kakaoJsKey);
        model.addAttribute("kakaoMobilityRestKey", kakaoMobilityRestKey);

        // 기존 뷰 이름 그대로
        return "map/map";
    }

    // ===== DTO =====
    public static class DangerousArea {
        public String id, name, riskLevel, description;
        public double lat, lng;
        public int incidents;
        public DangerousArea(String id,String name,double lat,double lng,String riskLevel,String description,int incidents){
            this.id=id; this.name=name; this.lat=lat; this.lng=lng;
            this.riskLevel=riskLevel; this.description=description; this.incidents=incidents;
        }
    }
    public static class RoutePoint {
        public double lat, lng;
        public RoutePoint(double lat,double lng){ this.lat=lat; this.lng=lng; }
    }
    public static class RecommendedRoute {
        public String id,name,type,distance,duration,elevation,difficulty,description;
        public int dangerousAreas; public List<RoutePoint> points;
        public RecommendedRoute(String id,String name,String type,String distance,String duration,
                                int dangerousAreas,String elevation,String difficulty,
                                List<RoutePoint> points,String description){
            this.id=id; this.name=name; this.type=type; this.distance=distance; this.duration=duration;
            this.dangerousAreas=dangerousAreas; this.elevation=elevation; this.difficulty=difficulty;
            this.points=points; this.description=description;
        }
    }
}
