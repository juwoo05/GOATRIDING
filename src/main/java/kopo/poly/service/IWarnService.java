package kopo.poly.service;

import kopo.poly.dto.DangerousDTO;

public interface IWarnService {

    String apiURL = "http://apis.data.go.kr/B552061/frequentzoneBicycle/getRestFrequentzoneBicycle";

    DangerousDTO getDangerous(DangerousDTO pDTO) throws Exception;
}
