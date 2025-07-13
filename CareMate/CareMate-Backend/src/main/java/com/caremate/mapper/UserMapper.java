package com.caremate.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.caremate.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface UserMapper extends BaseMapper<User> {
    @Select("SELECT * FROM user WHERE openid = #{openid} AND deleted = 0")
    User selectByOpenid(String openid);
} 