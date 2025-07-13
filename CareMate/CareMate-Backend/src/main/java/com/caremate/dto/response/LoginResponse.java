package com.caremate.dto.response;

import com.caremate.constant.UserType;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class LoginResponse {
    private String token;
    private Long userId;
    private UserType userType;
} 