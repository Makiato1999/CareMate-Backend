package com.caremate;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * CareMate 护理陪诊服务平台启动类
 * 
 * @author CareMate Team
 * @version 1.0.0
 * @since 2024-01-01
 */
@SpringBootApplication
@MapperScan("com.caremate.mapper")
public class CareMateApplication {

    public static void main(String[] args) {
        SpringApplication.run(CareMateApplication.class, args);
        System.out.println("🚀 CareMate 护理陪诊服务平台启动成功！");
        System.out.println("📖 API 文档地址: http://localhost:8080/doc.html");
        System.out.println("🔍 健康检查地址: http://localhost:8080/actuator/health");
    }
} 