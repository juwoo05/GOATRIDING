package kopo.poly.service.impl;

import kopo.poly.dto.CommunityDTO;
import kopo.poly.mapper.ICommunityMapper;
import kopo.poly.service.ICommunityService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Service
public class CommunityService implements ICommunityService {

    private final ICommunityMapper communityMapper;

    @Transactional
    @Override
    public void insertInfo(CommunityDTO pDTO) throws Exception {
        log.info("{}.insertNoticeInfo start!", this.getClass().getName());

        communityMapper.insertInfo(pDTO);
    }

    @Override
    public List<CommunityDTO> getInfoList() throws Exception {

        log.info(this.getClass().getName() + ".getInfoList start!");
        return communityMapper.getInfoList();
    }
}
