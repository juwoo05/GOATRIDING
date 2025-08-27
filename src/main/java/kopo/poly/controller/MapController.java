package kopo.poly.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import kopo.poly.dto.HotspotDTO;
import kopo.poly.service.impl.KoroadHotspotService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;

@Controller
@RequiredArgsConstructor
public class MapController {

    @Value("${kakao.jsKey}")
    private String kakaoJsKey;

    @Value("${kakao.mobilityRestKey}")
    private String kakaoMobilityRestKey;

    private final KoroadHotspotService koroadHotspotService;

    /**
     * 지도 화면 렌더링
     */
    @GetMapping("/map/map")
    public String showMap(Model model) throws JsonProcessingException {
        ObjectMapper m = new ObjectMapper();

        // 실제 서비스에서 데이터를 가져오도록 연동할 수 있음
        // 여기서는 프론트에서 AJAX로 /map/hotspots/near API를 호출하도록 설계하는 게 적절함
        model.addAttribute("dangerousAreasJson", "[]"); // 기본 빈 배열
        model.addAttribute("recommendedRoutesJson", "[]"); // 기본 빈 배열
        model.addAttribute("kakaoJsKey", kakaoJsKey);
        model.addAttribute("kakaoMobilityRestKey", kakaoMobilityRestKey);

        return "map/map";
    }

    /** KoROAD 프록시(API 직접) */
    @GetMapping("/map/hotspots")
    @ResponseBody
    public List<HotspotDTO> hotspotsByRegion(
            @RequestParam int sido,
            @RequestParam int gugun,
            @RequestParam(defaultValue = "2024") int year,
            @RequestParam(defaultValue = "1") int pageNo,
            @RequestParam(defaultValue = "999") int numOfRows
    ) {
        return koroadHotspotService.fetchBicycleHotspots(year, sido, gugun, pageNo, numOfRows);
    }

    /** DB에서 반경 내 사고다발지역 조회 */
    @GetMapping("/map/hotspots/near")
    @ResponseBody
    public List<HotspotDTO> hotspotsNear(
            @RequestParam double lat,
            @RequestParam double lng,
            @RequestParam(defaultValue = "3000") int radiusM,
            @RequestParam(defaultValue = "300") int limit
    ) {
        return koroadHotspotService.fetchNearbyFromDb(lat, lng, radiusM, limit);
    }

    /** API → DB 동기화(관리용) */
    @GetMapping("/map/hotspots/sync")
    @ResponseBody
    public String syncHotspots(
            @RequestParam int sido,
            @RequestParam int gugun,
            @RequestParam(defaultValue = "2024") int year,
            @RequestParam(defaultValue = "1") int pageNo,
            @RequestParam(defaultValue = "999") int numOfRows
    ) {
        int affected = koroadHotspotService.syncBicycleHotspotsToDb(year, sido, gugun, pageNo, numOfRows);
        return "upserted=" + affected;
    }
}
