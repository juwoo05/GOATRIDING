package kopo.poly.controller;

import jakarta.servlet.http.HttpServletRequest;
import kopo.poly.dto.DangerousDTO;
import kopo.poly.service.IWarnService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RequestMapping(value = "/warn")
@RequiredArgsConstructor
@RestController
public class WarnController {

    private final IWarnService warnService;

    @GetMapping(value = "getDangerous")
    public DangerousDTO getDangerous(HttpServletRequest request) throws Exception{

        log.info(this.getClass().getName() + ".getDangerous Start!");

        DangerousDTO pDTO = new DangerousDTO();

        DangerousDTO rDTO = warnService.getDangerous(pDTO);

        if (rDTO == null) {
            rDTO = new DangerousDTO();
        }

        log.info(this.getClass().getName() + ".getDangerous End!");

        return rDTO;
    }
}
