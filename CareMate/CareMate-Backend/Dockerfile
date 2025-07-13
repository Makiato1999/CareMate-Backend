# 使用 OpenJDK 17 作为基础镜像
FROM openjdk:17-jdk-slim

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV JAVA_OPTS="-Xmx512m -Xms256m"

# 复制 Maven 配置文件
COPY pom.xml .

# 复制源代码
COPY src ./src

# 安装 Maven 并构建应用
RUN apt-get update && \
    apt-get install -y maven && \
    mvn clean package -DskipTests && \
    rm -rf /root/.m2 && \
    apt-get remove -y maven && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 创建必要的目录
RUN mkdir -p /app/uploads /app/logs

# 暴露端口
EXPOSE 8080

# 启动应用
CMD ["java", "-jar", "target/caremate-backend-1.0.0.jar"] 