package com.caremate.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class WechatLoginRequest {
    @NotBlank(message = "code不能为空")
    private String code;
} 