package kopo.poly.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@RequestMapping(value = "/map")
@Controller
public class MapController {

    @GetMapping("map")
    public String showMapPage() {
        return "/map/map"; // map.jsp
    }
}