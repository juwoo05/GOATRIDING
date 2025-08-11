package kopo.poly.mapper;

import kopo.poly.dto.DangerousPointDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface IWarnMapper {

    /**
     * 대량 Insert + 중복시 Update
     * - 컬럼 UNIQUE(spot_nm, lo_crd, la_crd) 또는 PK 필요
     */
    void insertList(@Param("list") List<DangerousPointDTO> list);

    /**
     * 단건 업서트
     */
    void upsert(DangerousPointDTO dto);
}