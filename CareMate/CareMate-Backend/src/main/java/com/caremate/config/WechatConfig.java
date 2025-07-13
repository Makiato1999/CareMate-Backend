package com.caremate.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Data
@Configuration
@ConfigurationProperties(prefix = "wechat")
public class WechatConfig {
    private String appId;
    private String appSecret;
    private String grantType = "authorization_code";
    private String codeToSessionUrl = "https://api.weixin.qq.com/sns/jscode2session";
} 