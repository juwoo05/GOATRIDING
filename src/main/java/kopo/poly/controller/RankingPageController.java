package kopo.poly.controller;

import kopo.poly.dto.UserDTO;
import kopo.poly.service.IRankingService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.List;

@Controller
@RequiredArgsConstructor


public class RankingPageController {

    private final IRankingService rankingService;

    // ✅ JSP용 랭킹 페이지 GET 요청
    @GetMapping("/rank/ranking")
    public String rankingPage(Model model) {

        // 상위 5명의 유저 데이터를 가져와서
        List<UserDTO> top5List = rankingService.getTop5();

        // JSP로 넘긴다
        model.addAttribute("top5List", top5List);

        return "rank/ranking"; // => /WEB-INF/views/ranking.jsp
    }
}