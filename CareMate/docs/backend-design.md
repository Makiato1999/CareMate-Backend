# CareMate 后端API服务设计 (Java版本)

## 1. 技术栈选择

- **运行环境**: Java 17+
- **框架**: Spring Boot 3.x
- **数据库**: MySQL 8.0
- **ORM**: MyBatis-Plus
- **认证**: JWT + 微信OAuth
- **验证**: Spring Validation
- **日志**: Logback
- **测试**: JUnit 5 + Mockito
- **构建工具**: Maven
- **部署**: Docker + Docker Compose
- **文档**: Swagger/OpenAPI 3.0

### 1.1 ORM框架设计

**MyBatis-Plus + XML映射：**
- 基础CRUD使用MyBatis-Plus自动生成
- 复杂查询使用XML映射文件
- 统计查询在XML中编写SQL
- 支持逻辑删除（deleted字段）
- 标准的MyBatis开发模式

## 2. 项目结构

```
caremate-backend/
├── src/
│   ├── main/
│   │   ├── java/com/caremate/
│   │   │   ├── CareMateApplication.java
│   │   │   ├── controller/        # 控制器层
│   │   │   │   ├── AuthController.java
│   │   │   │   ├── UserController.java
│   │   │   │   ├── OrderController.java
│   │   │   │   ├── FileController.java
│   │   │   │   ├── StatsController.java
│   │   │   │   └── AdminController.java
│   │   │   ├── service/           # 业务逻辑层
│   │   │   │   ├── AuthService.java
│   │   │   │   ├── UserService.java
│   │   │   │   ├── OrderService.java
│   │   │   │   ├── FileService.java
│   │   │   │   ├── StatsService.java
│   │   │   │   └── AdminService.java
│   │   │   ├── mapper/            # MyBatis Mapper接口
│   │   │   │   ├── UserMapper.java
│   │   │   │   ├── PatientProfileMapper.java
│   │   │   │   ├── CaregiverProfileMapper.java
│   │   │   │   ├── OrderMapper.java
│   │   │   │   ├── OrderApplicationMapper.java
│   │   │   │   ├── FileMapper.java
│   │   │   │   ├── SystemConfigMapper.java
│   │   │   │   └── OperationLogMapper.java
│   │   │   ├── entity/            # 实体类
│   │   │   │   ├── base/
│   │   │   │   │   └── BaseEntity.java
│   │   │   │   ├── User.java
│   │   │   │   ├── PatientProfile.java
│   │   │   │   ├── CaregiverProfile.java
│   │   │   │   ├── Order.java
│   │   │   │   ├── OrderApplication.java
│   │   │   │   ├── File.java
│   │   │   │   ├── SystemConfig.java
│   │   │   │   └── OperationLog.java
│   │   │   ├── dto/               # 数据传输对象
│   │   │   │   ├── request/
│   │   │   │   │   ├── WechatLoginRequest.java
│   │   │   │   │   ├── UserProfileRequest.java
│   │   │   │   │   ├── CreateOrderRequest.java
│   │   │   │   │   ├── ApplyOrderRequest.java
│   │   │   │   │   └── FileUploadRequest.java
│   │   │   │   └── response/
│   │   │   │       ├── LoginResponse.java
│   │   │   │       ├── UserResponse.java
│   │   │   │       ├── OrderResponse.java
│   │   │   │       └── StatsResponse.java
│   │   │   ├── vo/                # 视图对象
│   │   │   │   ├── UserVO.java
│   │   │   │   ├── OrderVO.java
│   │   │   │   ├── CaregiverStatsVO.java
│   │   │   │   ├── PatientStatsVO.java
│   │   │   │   └── OrderStatsVO.java
│   │   │   ├── config/            # 配置类
│   │   │   │   ├── JwtConfig.java
│   │   │   │   ├── MybatisPlusConfig.java
│   │   │   │   ├── WebConfig.java
│   │   │   │   ├── SwaggerConfig.java
│   │   │   │   └── FileUploadConfig.java
│   │   │   ├── interceptor/       # 拦截器
│   │   │   │   ├── AuthInterceptor.java
│   │   │   │   └── LogInterceptor.java
│   │   │   ├── exception/         # 异常处理
│   │   │   │   ├── GlobalExceptionHandler.java
│   │   │   │   ├── BusinessException.java
│   │   │   │   └── ErrorCode.java
│   │   │   ├── util/              # 工具类
│   │   │   │   ├── JwtUtil.java
│   │   │   │   ├── FileUtil.java
│   │   │   │   ├── DateUtil.java
│   │   │   │   └── ValidationUtil.java
│   │   │   ├── constant/          # 常量定义
│   │   │   │   ├── UserType.java
│   │   │   │   ├── OrderStatus.java
│   │   │   │   ├── ApplicationStatus.java
│   │   │   │   └── FileType.java
│   │   │   └── common/            # 公共组件
│   │   │       ├── result/        # 统一响应
│   │   │       │   ├── Result.java
│   │   │       │   └── PageResult.java
│   │   │       └── base/          # 基础类
│   │   │           └── BaseEntity.java
│   │   └── resources/
│   │       ├── application.yml
│   │       ├── application-dev.yml
│   │       ├── application-prod.yml
│   │       └── mapper/            # MyBatis XML映射文件
│   │           ├── UserMapper.xml
│   │           ├── PatientProfileMapper.xml
│   │           ├── CaregiverProfileMapper.xml
│   │           ├── OrderMapper.xml
│   │           ├── OrderApplicationMapper.xml
│   │           ├── FileMapper.xml
│   │           ├── SystemConfigMapper.xml
│   │           └── OperationLogMapper.xml
│   └── test/
│       └── java/com/caremate/
│           ├── controller/
│           ├── service/
│           └── mapper/
├── docs/                          # API文档
├── scripts/                       # 部署脚本
├── pom.xml
└── Dockerfile
```

## 3. 核心模块设计

### 3.1 用户认证模块

**文件结构**:
```
src/main/java/com/caremate/
├── controller/
│   └── AuthController.java
├── service/
│   └── AuthService.java
├── entity/
│   ├── User.java
│   ├── PatientProfile.java
│   └── CaregiverProfile.java
├── dto/
│   ├── WechatLoginRequest.java
│   ├── UserProfileRequest.java
│   └── LoginResponse.java
├── mapper/
│   ├── UserMapper.java
│   ├── PatientProfileMapper.java
│   └── CaregiverProfileMapper.java
├── config/
│   └── JwtConfig.java
└── interceptor/
    └── AuthInterceptor.java
```

**核心功能**:
- 微信OAuth登录
- JWT Token生成和验证
- 用户权限控制
- 用户资料管理
- 逻辑删除支持

### 3.2 订单管理模块

**文件结构**:
```
src/main/java/com/caremate/
├── controller/
│   └── OrderController.java
├── service/
│   └── OrderService.java
├── entity/
│   ├── Order.java
│   └── OrderApplication.java
├── dto/
│   ├── CreateOrderRequest.java
│   ├── OrderResponse.java
│   └── ApplyOrderRequest.java
└── mapper/
    ├── OrderMapper.java
    └── OrderApplicationMapper.java
```

**核心功能**:
- 订单CRUD操作
- 订单状态管理
- 申请处理逻辑
- 权限控制
- 逻辑删除支持

### 3.3 文件管理模块

**文件结构**:
```
src/main/java/com/caremate/
├── controller/
│   └── FileController.java
├── service/
│   └── FileService.java
├── entity/
│   └── File.java
├── dto/
│   ├── FileUploadRequest.java
│   └── FileResponse.java
├── mapper/
│   └── FileMapper.java
└── config/
    └── FileUploadConfig.java
```

**核心功能**:
- 文件上传下载
- 文件类型验证
- 文件存储管理
- 文件访问控制
- 逻辑删除支持

### 3.4 系统管理模块

**文件结构**:
```
src/main/java/com/caremate/
├── controller/
│   └── AdminController.java
├── service/
│   ├── SystemConfigService.java
│   └── OperationLogService.java
├── entity/
│   ├── SystemConfig.java
│   └── OperationLog.java
├── mapper/
│   ├── SystemConfigMapper.java
│   └── OperationLogMapper.java
└── interceptor/
    └── LogInterceptor.java
```

**核心功能**:
- 系统配置管理
- 操作日志记录
- 系统监控
- 数据统计

### 3.5 数据统计模块

**文件结构**:
```
src/main/java/com/caremate/
├── controller/
│   └── StatsController.java
├── service/
│   └── StatsService.java
├── dto/
│   ├── UserStatsResponse.java
│   ├── OrderStatsResponse.java
│   └── DailyStatsResponse.java
├── mapper/
│   ├── OrderMapper.java
│   └── OrderStatsMapper.java
└── vo/
    ├── CaregiverStatsVO.java
    ├── PatientStatsVO.java
    └── OrderStatsVO.java
```

**核心功能**:
- 用户数据统计
- 订单数据统计
- 收入统计
- 时间统计
- 视图查询支持

## 4. 实体类设计

### 4.1 用户实体类

**User.java** - 用户基础信息
```java
public class User {
    private Long id;                    // 用户ID
    private String openid;              // 微信openid
    private String unionid;             // 微信unionid
    private UserType userType;          // 用户类型：patient/caregiver/admin
    private String nickname;            // 昵称
    private String avatarUrl;           // 头像URL
    private String phone;               // 手机号
    private UserStatus status;          // 用户状态：active/inactive/banned
    private LocalDateTime createdAt;    // 创建时间
    private LocalDateTime updatedAt;    // 更新时间
    private Integer deleted;            // 逻辑删除标记：0-未删除，1-已删除
}
```

**PatientProfile.java** - 患者详细信息
```java
public class PatientProfile {
    private Long id;                    // 患者资料ID
    private Long userId;                // 用户ID
    private String realName;            // 真实姓名
    private Gender gender;              // 性别：male/female/unknown
    private Integer age;                // 年龄
    private String idCard;              // 身份证号
    private String emergencyContact;    // 紧急联系人
    private String emergencyPhone;      // 紧急联系电话
    private String diagnosis;           // 诊断信息
    private String medicalHistory;      // 病史
    private String allergies;           // 过敏史
    private String specialNeeds;        // 特殊需求
    private LocalDateTime createdAt;    // 创建时间
    private LocalDateTime updatedAt;    // 更新时间
    private Integer deleted;            // 逻辑删除标记
}
```

**CaregiverProfile.java** - 陪护人员详细信息
```java
public class CaregiverProfile {
    private Long id;                    // 陪护资料ID
    private Long userId;                // 用户ID
    private String realName;            // 真实姓名
    private Gender gender;              // 性别：male/female/unknown
    private Integer age;                // 年龄
    private String idCard;              // 身份证号
    private String phone;               // 联系电话
    private String address;             // 地址
    private Integer hasCertification;   // 是否有相关资质证书：0-否，1-是
    private String certificationInfo;   // 资质证书信息
    private String professionalBackground; // 专业背景
    private Integer workExperience;     // 工作经验(年)
    private String serviceAreas;        // 服务区域
    private BigDecimal hourlyRate;      // 时薪
    private String availableHours;      // 可服务时间
    private String skills;              // 专业技能
    private LocalDateTime createdAt;    // 创建时间
    private LocalDateTime updatedAt;    // 更新时间
    private Integer deleted;            // 逻辑删除标记
}
```

### 4.2 订单实体类

**Order.java** - 订单信息
```java
public class Order {
    private Long id;                    // 订单ID
    private String orderNo;             // 订单号
    private Long patientId;             // 患者ID
    private Long caregiverId;           // 陪护ID
    private String title;               // 订单标题
    private String description;         // 订单描述
    private String hospital;            // 医院名称
    private String address;             // 具体地址
    private LocalDateTime expectedTime; // 预计时间
    private Integer durationHours;      // 预计时长(小时)
    private BigDecimal price;           // 价格
    private OrderStatus status;         // 订单状态
    private LocalDateTime createdAt;    // 创建时间
    private LocalDateTime updatedAt;    // 更新时间
    private LocalDateTime closedAt;     // 订单关闭时间
    private Integer deleted;            // 逻辑删除标记
}
```

**OrderApplication.java** - 订单申请记录
```java
public class OrderApplication {
    private Long id;                    // 申请ID
    private Long orderId;               // 订单ID
    private Long caregiverId;           // 陪护ID
    private ApplicationStatus status;   // 申请状态：pending/approved/rejected
    private String message;             // 申请留言
    private BigDecimal proposedPrice;   // 提议价格
    private LocalDateTime createdAt;    // 申请时间
    private LocalDateTime updatedAt;    // 更新时间
    private Integer deleted;            // 逻辑删除标记
}
```

### 4.3 文件实体类

**File.java** - 文件信息
```java
public class File {
    private Long id;                    // 文件ID
    private String originalName;        // 原始文件名
    private String fileName;            // 存储文件名
    private String filePath;            // 文件路径
    private Long fileSize;              // 文件大小(字节)
    private String fileType;            // 文件类型
    private String mimeType;            // MIME类型
    private Long uploaderId;            // 上传者ID
    private LocalDateTime createdAt;    // 上传时间
    private Integer deleted;            // 逻辑删除标记
}
```

### 4.4 系统实体类

**SystemConfig.java** - 系统配置
```java
public class SystemConfig {
    private Long id;                    // 配置ID
    private String configKey;           // 配置键
    private String configValue;         // 配置值
    private String description;         // 配置描述
    private LocalDateTime createdAt;    // 创建时间
    private LocalDateTime updatedAt;    // 更新时间
}
```

**OperationLog.java** - 操作日志
```java
public class OperationLog {
    private Long id;                    // 日志ID
    private Long userId;                // 操作用户ID
    private String operation;           // 操作类型
    private String description;         // 操作描述
    private String ipAddress;           // IP地址
    private String userAgent;           // 用户代理
    private String requestUrl;          // 请求URL
    private String requestMethod;       // 请求方法
    private String requestParams;       // 请求参数
    private Integer responseStatus;     // 响应状态码
    private Long executionTime;         // 执行时间(毫秒)
    private LocalDateTime createdAt;    // 操作时间
}
```

## 5. 配置管理

### 5.1 应用配置

**application.yml** - 主配置文件
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/caremate
    username: ${DB_USERNAME:root}
    password: ${DB_PASSWORD:123456}
  
  servlet:
    multipart:
      max-file-size: 10MB
      max-request-size: 10MB

mybatis-plus:
  configuration:
    map-underscore-to-camel-case: true
  global-config:
    db-config:
      logic-delete-field: deleted
      logic-delete-value: 1
      logic-not-delete-value: 0

jwt:
  secret: ${JWT_SECRET:caremate-secret-key-2024}
  expiration: ${JWT_EXPIRATION:86400000}

file:
  upload-path: ${FILE_UPLOAD_PATH:./uploads}
  access-path: ${FILE_ACCESS_PATH:/files}
```

### 5.2 Maven配置

**pom.xml** - 项目依赖管理
```xml
<dependencies>
    <!-- Spring Boot Starters -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    
    <!-- MyBatis-Plus -->
    <dependency>
        <groupId>com.baomidou</groupId>
        <artifactId>mybatis-plus-boot-starter</artifactId>
        <version>3.5.4.1</version>
    </dependency>
    
    <!-- JWT -->
    <dependency>
        <groupId>io.jsonwebtoken</groupId>
        <artifactId>jjwt-api</artifactId>
        <version>0.12.3</version>
    </dependency>
    
    <!-- 其他依赖... -->
</dependencies>
```

## 6. 部署配置

### 6.1 Docker配置

**Dockerfile** - 容器化配置
```dockerfile
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/caremate-backend-1.0.0.jar app.jar
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
```

### 6.2 Docker Compose配置

**docker-compose.yml** - 服务编排
```yaml
version: '3.8'
services:
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: 123456
      MYSQL_DATABASE: caremate
    volumes:
      - ./docker/mysql/init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "3306:3306"
  
  caremate-backend:
    build: .
    ports:
      - "8080:8080"
    depends_on:
      - mysql
    environment:
      - DB_USERNAME=root
      - DB_PASSWORD=123456
```

## 7. 开发规范

### 7.1 代码规范
- 使用统一的命名规范
- 添加完整的注释
- 遵循SOLID原则
- 编写单元测试

### 7.2 数据库规范
- 使用逻辑删除
- 添加必要的索引
- 使用外键约束
- 规范字段命名

### 7.3 API规范
- 统一的响应格式
- 完整的错误处理
- 规范的URL设计
- 详细的API文档 