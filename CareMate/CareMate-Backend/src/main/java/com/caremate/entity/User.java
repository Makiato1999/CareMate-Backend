package com.caremate.entity;

import com.caremate.constant.UserType;
import lombok.Data;

@Data
public class User {
    private Long id;
    private String openid;
    private String unionid;
    private UserType userType;
    private String nickname;
    private String avatarUrl;
    private String phone;
    private Integer deleted;
} 