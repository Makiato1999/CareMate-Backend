package com.caremate.controller;

import com.caremate.common.result.Result;
import com.caremate.dto.request.WechatLoginRequest;
import com.caremate.dto.response.LoginResponse;
import com.caremate.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {
    private final AuthService authService;

    @PostMapping("/login")
    public Result<LoginResponse> login(@Validated @RequestBody WechatLoginRequest request) {
        return Result.success(authService.wechatLogin(request));
    }
} 