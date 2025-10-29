package kopo.poly.service;

import kopo.poly.dto.SpamDTO;
import org.springframework.web.bind.annotation.PostMapping;


public interface ITestService {

    @PostMapping("/predict")
    SpamDTO test(SpamDTO pDTO);

}
