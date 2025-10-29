package kopo.poly.mapper;

import kopo.poly.dto.UserChallengeView;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface IChallengeMapper {
    List<UserChallengeView> getUserChallenges(@Param("userId") String userId);

}