package kopo.poly.controller;

import kopo.poly.service.impl.DangerousZoneService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/api")
public class DangerousZoneController {

    private final DangerousZoneService dangerousZoneService;

    @GetMapping("bicycle-zones")
    public String getZones() {
        return dangerousZoneService.getDangerZones();
    }
}
