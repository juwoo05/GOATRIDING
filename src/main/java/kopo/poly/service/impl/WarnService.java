package kopo.poly.service.impl;

import com.fasterxml.jackson.databind.ObjectMapper;
import kopo.poly.dto.DangerousDTO;
import kopo.poly.dto.DangerousPointDTO;
import kopo.poly.service.IWarnService;
import kopo.poly.util.NetworkUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class WarnService implements IWarnService {

    @Value("${warn.api.key}")
    private String apiKey;

    @Override
    public DangerousDTO getDangerous(DangerousDTO pDTO) throws Exception {

        log.info(this.getClass().getName() + ".getWeather Start!");

        String searchYearCd = "2021";
        String siDo = "11";
        String guGun = "500";
        String type = "json";
        String numOfRows = "10";
        String pageNo = "1";

        String apiParam = "?ServiceKey=" + apiKey + "&searchYearCd=" + searchYearCd + "&siDo=" + siDo + "&guGun=" + guGun + "&type=" + type + "&numOfRows=" + numOfRows + "&pageNo=" + pageNo;
        log.info("apiParam" + apiParam);

        String json = NetworkUtil.get(IWarnService.apiURL + apiParam);
        log.info("json" + json);

        Map<String, Object> rMap = new ObjectMapper().readValue(json, LinkedHashMap.class);

        List<Map<String, Object>> itemList = (List<Map<String, Object>>)((Map<String, Object>)rMap.get("items")).get("item");

        List<DangerousPointDTO> pList = new LinkedList<>();

        for (Map<String, Object> itemMap : itemList) {

            String spot_nm = itemMap.get("spot_nm").toString();
            int occrrnc_cnt = Integer.parseInt(itemMap.get("occrrnc_cnt").toString());
            int caslt_cnt = Integer.parseInt(itemMap.get("caslt_cnt").toString());
            int dth_dnv_cnt = Integer.parseInt(itemMap.get("dth_dnv_cnt").toString());
            int se_dnv_cnt = Integer.parseInt(itemMap.get("se_dnv_cnt").toString());
            int sl_dnv_cnt = Integer.parseInt(itemMap.get("sl_dnv_cnt").toString());
            double lo_crd = Double.parseDouble(itemMap.get("lo_crd").toString());
            double la_crd = Double.parseDouble(itemMap.get("la_crd").toString());
            String geom_json = itemMap.get("geom_json").toString();

            log.info("------------------------------");
            log.info("spot_nm" + spot_nm);
            log.info("occrrnc_cnt" + occrrnc_cnt);
            log.info("caslt_cnt" + caslt_cnt);
            log.info("dth_dnv_cnt" + dth_dnv_cnt);
            log.info("se_dnv_cnt" + se_dnv_cnt);
            log.info("sl_dnv_cnt" + sl_dnv_cnt);
            log.info("lo_crd" + lo_crd);
            log.info("la_crd" + la_crd);
            log.info("geom_json" + geom_json);

            DangerousPointDTO dpDTO = new DangerousPointDTO();

            dpDTO.setSpot_nm(spot_nm);
            dpDTO.setOccrrnc_cnt(occrrnc_cnt);
            dpDTO.setCaslt_cnt(caslt_cnt);
            dpDTO.setDth_dnv_cnt(dth_dnv_cnt);
            dpDTO.setSe_dnv_cnt(se_dnv_cnt);
            dpDTO.setSl_dnv_cnt(sl_dnv_cnt);
            dpDTO.setLo_crd(lo_crd);
            dpDTO.setLa_crd(la_crd);
            dpDTO.setGeom_json(geom_json);

            pList.add(dpDTO);

            dpDTO = null;
        }

        DangerousDTO dDTO = new DangerousDTO();

        dDTO.setPointsList(pList);
        log.info(this.getClass().getName() + ".getDangerous End!");

        return dDTO;
    }
}
