package kopo.poly.service;

import kopo.poly.dto.UserDTO;

import java.util.List;

public interface IRankingService {
    void updateScore(UserDTO pDTO);
    List<UserDTO> getTop5();
    void resetWeekly();
}


