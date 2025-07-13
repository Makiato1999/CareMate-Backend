package com.caremate.service.impl;

import com.caremate.config.WechatConfig;
import com.caremate.dto.request.WechatLoginRequest;
import com.caremate.dto.response.LoginResponse;
import com.caremate.entity.User;
import com.caremate.exception.BusinessException;
import com.caremate.mapper.UserMapper;
import com.caremate.service.AuthService;
import com.caremate.util.JwtUtil;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {
    private final WechatConfig wechatConfig;
    private final JwtUtil jwtUtil;
    private final UserMapper userMapper;
    private final OkHttpClient okHttpClient;
    private final ObjectMapper objectMapper;

    @Override
    @Transactional
    public LoginResponse wechatLogin(WechatLoginRequest request) {
        try {
            // 调用微信接口获取openid和session_key
            String url = String.format("%s?appid=%s&secret=%s&js_code=%s&grant_type=%s",
                    wechatConfig.getCodeToSessionUrl(),
                    wechatConfig.getAppId(),
                    wechatConfig.getAppSecret(),
                    request.getCode(),
                    wechatConfig.getGrantType());

            Request wxRequest = new Request.Builder()
                    .url(url)
                    .build();

            try (Response response = okHttpClient.newCall(wxRequest).execute()) {
                if (!response.isSuccessful() || response.body() == null) {
                    throw new BusinessException("微信登录失败");
                }

                JsonNode jsonNode = objectMapper.readTree(response.body().string());
                
                if (jsonNode.has("errcode") && jsonNode.get("errcode").asInt() != 0) {
                    throw new BusinessException("微信登录失败: " + jsonNode.get("errmsg").asText());
                }

                String openid = jsonNode.get("openid").asText();
                String sessionKey = jsonNode.get("session_key").asText();
                String unionid = jsonNode.has("unionid") ? jsonNode.get("unionid").asText() : null;

                // 查找或创建用户
                User user = userMapper.selectByOpenid(openid);
                if (user == null) {
                    user = new User();
                    user.setOpenid(openid);
                    user.setUnionid(unionid);
                    userMapper.insert(user);
                }

                // 生成JWT token
                String token = jwtUtil.generateToken(user.getId(), user.getUserType().name());

                return LoginResponse.builder()
                        .token(token)
                        .userId(user.getId())
                        .userType(user.getUserType())
                        .build();

            }
        } catch (IOException e) {
            log.error("微信登录异常", e);
            throw new BusinessException("微信登录失败");
        }
    }
} 