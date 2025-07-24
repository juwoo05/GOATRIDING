package kopo.poly.service.impl;

import kopo.poly.service.IDangerousZoneService;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

@Service
public class DangerousZoneService implements IDangerousZoneService {
    @Override
    public String getDangerZones() {
        String serviceKey = "kSsVcjsKFder8ooGlPFF8S9p6ZajeIs8lHgTXecmSWySbZc5nD3aQLnNhhbNipV6anjeYtO/4oSdQlFGQcimHw==";
        String url = UriComponentsBuilder
                .fromHttpUrl("http://apis.data.go.kr/B552061/frequentzoneBicycle/getRestFrequentzoneBicycle")
                .queryParam("ServiceKey", serviceKey)
                .queryParam("searchYearCd", "2021")
                .queryParam("siDo", "11")
                .queryParam("guGun", "680")
                .queryParam("numOfRows", "10")
                .queryParam("pageNo", "1")
                .build().toUriString();

        return new RestTemplate().getForObject(url, String.class);
    }
}
