package kopo.poly.controller;

import kopo.poly.service.IAchievementService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@Slf4j
@RequiredArgsConstructor
@Controller
@RequestMapping("/admin/fix")
public class AdminFixController {

    private final IAchievementService achievementService;

    @PostMapping("/achievements/{userId}")
    @ResponseBody
    public String backfillAchievements(@PathVariable String userId) {
        try {
            log.info("[AdminFix] backfill UA from USER_RANK: userId={}", userId);
            achievementService.backfillFromRank(userId);
            return "OK";
        } catch (Exception e) {
            log.error("backfill error", e);
            return "ERR: " + e.getMessage();
        }
    }
}
