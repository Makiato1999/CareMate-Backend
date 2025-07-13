package com.caremate.service;

import com.caremate.dto.request.WechatLoginRequest;
import com.caremate.dto.response.LoginResponse;

public interface AuthService {
    LoginResponse wechatLogin(WechatLoginRequest request);
} 