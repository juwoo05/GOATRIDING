package kopo.poly.config;

import kopo.poly.service.IRankingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@EnableScheduling
@RequiredArgsConstructor
public class SchedulerConfig {

    private final IRankingService rankingService;

    // ⏰ 매주 월요일 00:00:00 실행
    @Scheduled(cron = "0 0 0 ? * MON")
    public void resetWeeklyRanking() {
        log.info("🕛 주간 랭킹 초기화 스케줄러 실행됨");
        rankingService.resetWeekly();
    }
}