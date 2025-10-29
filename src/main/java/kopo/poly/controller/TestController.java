package kopo.poly.controller;

import kopo.poly.dto.SpamDTO;
import kopo.poly.service.ITestService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RequiredArgsConstructor
@RestController
public class TestController {

    private final ITestService testService;

    @GetMapping(value = "/test/analyze")
    public SpamDTO analyze() {

        SpamDTO dto = new SpamDTO();
        dto.setText("완전 감동이에요 다시 봐도 좋네요");

        return testService.test(dto);
    }
}
