# CareMate Backend

CareMate 护理陪诊服务平台后端 API

## 🚀 项目简介

CareMate 是一个专业的护理陪诊服务平台，为患者和陪护人员提供便捷的匹配服务。本仓库包含后端 API 服务，基于 Spring Boot + MyBatis-Plus 构建。

## 🛠️ 技术栈

- **框架**: Spring Boot 3.2.0
- **数据库**: MySQL 8.0
- **ORM**: MyBatis-Plus 3.5.4.1
- **缓存**: Redis 7
- **认证**: JWT
- **文档**: Knife4j (Swagger)
- **构建**: Maven
- **容器**: Docker

## 📋 功能特性

- ✅ 用户认证与授权
- ✅ 患者资料管理
- ✅ 陪护资料管理
- ✅ 订单管理
- ✅ 申请处理
- ✅ 数据统计
- ✅ 文件上传
- ✅ 管理员功能

## 🏗️ 项目结构

```
src/
├── main/
│   ├── java/com/caremate/
│   │   ├── config/          # 配置类
│   │   ├── controller/      # 控制器
│   │   ├── service/         # 服务层
│   │   ├── mapper/          # 数据访问层
│   │   ├── entity/          # 实体类
│   │   ├── dto/             # 数据传输对象
│   │   ├── vo/              # 视图对象
│   │   ├── common/          # 公共组件
│   │   │   ├── result/      # 统一响应
│   │   │   ├── exception/   # 异常处理
│   │   │   └── utils/       # 工具类
│   │   └── security/        # 安全配置
│   └── resources/
│       ├── mapper/          # MyBatis XML
│       ├── application.yml  # 配置文件
│       └── application-dev.yml
└── test/                    # 测试代码
```

## 🚀 快速开始

### 环境要求

- JDK 17+
- Maven 3.6+
- MySQL 8.0+
- Redis 7+
- Docker (可选)

### 方式一：本地开发

1. **克隆项目**
```bash
git clone https://github.com/Makiato1999/CareMate-Backend.git
cd CareMate-Backend
```

2. **配置数据库**
```bash
# 创建数据库
CREATE DATABASE caremate CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# 执行初始化脚本
mysql -u root -p caremate < docker/mysql/init.sql
```

3. **配置环境变量**
```bash
# 复制环境变量模板
cp .env.example .env

# 编辑环境变量
vim .env
```

4. **启动 Redis**
```bash
# 使用 Docker
docker run -d --name redis -p 6379:6379 redis:7-alpine

# 或本地安装
redis-server
```

5. **运行应用**
```bash
# 编译项目
mvn clean compile

# 运行应用
mvn spring-boot:run
```

### 方式二：Docker 部署

1. **启动所有服务**
```bash
docker-compose up -d
```

2. **查看服务状态**
```bash
docker-compose ps
```

3. **查看日志**
```bash
docker-compose logs -f caremate-backend
```

## 📖 API 文档

启动应用后，访问以下地址查看 API 文档：

- **Knife4j 文档**: http://localhost:8080/api/doc.html
- **Swagger JSON**: http://localhost:8080/api/v3/api-docs
- **健康检查**: http://localhost:8080/api/actuator/health

## 🔧 配置说明

### 数据库配置

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/caremate
    username: ${DB_USERNAME:root}
    password: ${DB_PASSWORD:123456}
```

### Redis 配置

```yaml
spring:
  data:
    redis:
      host: ${REDIS_HOST:localhost}
      port: ${REDIS_PORT:6379}
      password: ${REDIS_PASSWORD:}
```

### JWT 配置

```yaml
jwt:
  secret: ${JWT_SECRET:caremate-secret-key-2024}
  expiration: ${JWT_EXPIRATION:86400000}
```

## 🧪 测试

### 运行测试
```bash
# 运行所有测试
mvn test

# 运行特定测试
mvn test -Dtest=UserServiceTest

# 生成测试报告
mvn surefire-report:report
```

### 测试覆盖率
```bash
# 生成覆盖率报告
mvn jacoco:report
```

## 📦 构建部署

### 构建 JAR 包
```bash
mvn clean package -DskipTests
```

### Docker 构建
```bash
# 构建镜像
docker build -t caremate-backend .

# 运行容器
docker run -d -p 8080:8080 --name caremate-backend caremate-backend
```

## 🔍 监控

### 健康检查
```bash
curl http://localhost:8080/api/actuator/health
```

### 应用信息
```bash
curl http://localhost:8080/api/actuator/info
```

### 指标监控
```bash
curl http://localhost:8080/api/actuator/metrics
```

## 🐛 常见问题

### 1. 数据库连接失败
- 检查 MySQL 服务是否启动
- 确认数据库用户名密码正确
- 检查数据库端口是否被占用

### 2. Redis 连接失败
- 检查 Redis 服务是否启动
- 确认 Redis 端口配置正确
- 检查防火墙设置

### 3. 端口被占用
```bash
# 查看端口占用
lsof -i :8080

# 杀死进程
kill -9 <PID>
```

## 🤝 贡献指南

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 📄 许可证

本项目采用 Apache License 2.0 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📞 联系我们

- **项目主页**: https://github.com/Makiato1999/CareMate-Backend
- **问题反馈**: https://github.com/Makiato1999/CareMate-Backend/issues
- **邮箱**: caremate@example.com

## 🙏 致谢

感谢所有为 CareMate 项目做出贡献的开发者！

---

**CareMate - 您的医疗伙伴** 🏥 