package com.caremate.interceptor;

import com.caremate.config.JwtConfig;
import com.caremate.util.JwtUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
@RequiredArgsConstructor
public class AuthInterceptor implements HandlerInterceptor {
    private final JwtUtil jwtUtil;
    private final JwtConfig jwtConfig;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        // 跳过OPTIONS请求
        if (request.getMethod().equals("OPTIONS")) {
            return true;
        }

        String authHeader = request.getHeader(jwtConfig.getHeader());
        if (authHeader != null && authHeader.startsWith(jwtConfig.getTokenPrefix())) {
            String token = authHeader.substring(jwtConfig.getTokenPrefix().length());
            if (jwtUtil.validateToken(token)) {
                // 将用户信息存入request属性中
                request.setAttribute("userId", jwtUtil.getUserIdFromToken(token));
                request.setAttribute("userType", jwtUtil.getUserTypeFromToken(token));
                return true;
            }
        }

        response.setStatus(HttpStatus.UNAUTHORIZED.value());
        return false;
    }
} 