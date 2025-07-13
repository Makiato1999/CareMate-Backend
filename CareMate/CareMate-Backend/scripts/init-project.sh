#!/bin/bash

# CareMate Backend 项目初始化脚本
# 作者: CareMate Team
# 版本: 1.0.0

set -e

echo "🚀 开始初始化 CareMate Backend 项目..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查必要的工具
check_requirements() {
    print_info "检查系统要求..."
    
    # 检查 Java
    if ! command -v java &> /dev/null; then
        print_error "Java 未安装，请先安装 JDK 17+"
        exit 1
    fi
    
    java_version=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
    if [ "$java_version" -lt 17 ]; then
        print_error "Java 版本过低，需要 JDK 17+"
        exit 1
    fi
    
    print_success "Java 版本检查通过: $(java -version 2>&1 | head -n 1)"
    
    # 检查 Maven
    if ! command -v mvn &> /dev/null; then
        print_error "Maven 未安装，请先安装 Maven 3.6+"
        exit 1
    fi
    
    print_success "Maven 版本检查通过: $(mvn -version | head -n 1)"
    
    # 检查 Docker (可选)
    if command -v docker &> /dev/null; then
        print_success "Docker 已安装: $(docker --version)"
    else
        print_warning "Docker 未安装，将跳过 Docker 相关操作"
    fi
    
    # 检查 Docker Compose (可选)
    if command -v docker-compose &> /dev/null; then
        print_success "Docker Compose 已安装: $(docker-compose --version)"
    else
        print_warning "Docker Compose 未安装，将跳过 Docker Compose 相关操作"
    fi
}

# 创建项目目录结构
create_project_structure() {
    print_info "创建项目目录结构..."
    
    # 创建主要目录
    mkdir -p src/main/java/com/caremate/{config,controller,service,mapper,entity,dto,vo,common/{result,exception,utils},security}
    mkdir -p src/main/resources/{mapper,static,templates}
    mkdir -p src/test/java/com/caremate
    mkdir -p src/test/resources
    mkdir -p logs
    mkdir -p uploads
    mkdir -p docs
    mkdir -p scripts
    
    print_success "项目目录结构创建完成"
}

# 创建环境变量文件
create_env_file() {
    print_info "创建环境变量文件..."
    
    cat > .env.example << EOF
# 数据库配置
DB_USERNAME=root
DB_PASSWORD=123456
DB_HOST=localhost
DB_PORT=3306
DB_NAME=caremate

# Redis 配置
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DATABASE=0

# JWT 配置
JWT_SECRET=caremate-secret-key-2024
JWT_EXPIRATION=86400000

# 微信配置
WECHAT_APP_ID=your_wechat_app_id
WECHAT_APP_SECRET=your_wechat_app_secret

# 文件上传配置
FILE_UPLOAD_PATH=./uploads
FILE_ACCESS_PATH=/files

# 服务器配置
SERVER_PORT=8080
SERVER_CONTEXT_PATH=/api
EOF
    
    print_success "环境变量模板文件创建完成: .env.example"
    print_warning "请根据实际情况修改 .env.example 文件，并复制为 .env"
}

# 创建 Docker 配置文件
create_docker_config() {
    print_info "创建 Docker 配置文件..."
    
    # 创建 Nginx 配置目录
    mkdir -p docker/nginx/conf.d
    
    # 创建 Nginx 配置文件
    cat > docker/nginx/nginx.conf << EOF
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                    '\$status \$body_bytes_sent "\$http_referer" '
                    '"\$http_user_agent" "\$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
    
    include /etc/nginx/conf.d/*.conf;
}
EOF
    
    # 创建 Nginx 站点配置
    cat > docker/nginx/conf.d/caremate.conf << EOF
server {
    listen 80;
    server_name localhost;
    
    # API 代理
    location /api/ {
        proxy_pass http://caremate-backend:8080/api/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # 文件访问
    location /files/ {
        alias /var/www/uploads/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
    
    # 健康检查
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
EOF
    
    print_success "Docker 配置文件创建完成"
}

# 创建开发脚本
create_dev_scripts() {
    print_info "创建开发脚本..."
    
    # 创建启动脚本
    cat > scripts/start.sh << 'EOF'
#!/bin/bash

echo "🚀 启动 CareMate Backend 开发环境..."

# 检查环境变量文件
if [ ! -f .env ]; then
    echo "⚠️  未找到 .env 文件，请先复制 .env.example 并配置"
    exit 1
fi

# 加载环境变量
export $(cat .env | grep -v '^#' | xargs)

# 启动应用
echo "📦 编译项目..."
mvn clean compile

echo "🚀 启动应用..."
mvn spring-boot:run
EOF
    
    # 创建测试脚本
    cat > scripts/test.sh << 'EOF'
#!/bin/bash

echo "🧪 运行 CareMate Backend 测试..."

# 运行所有测试
mvn test

# 生成测试报告
mvn surefire-report:report

echo "✅ 测试完成，报告生成在 target/site/surefire-report.html"
EOF
    
    # 创建构建脚本
    cat > scripts/build.sh << 'EOF'
#!/bin/bash

echo "📦 构建 CareMate Backend..."

# 清理并打包
mvn clean package -DskipTests

echo "✅ 构建完成，JAR 包位置: target/caremate-backend-1.0.0.jar"
EOF
    
    # 创建 Docker 构建脚本
    cat > scripts/docker-build.sh << 'EOF'
#!/bin/bash

echo "🐳 构建 CareMate Backend Docker 镜像..."

# 构建镜像
docker build -t caremate-backend .

echo "✅ Docker 镜像构建完成"
echo "🚀 运行命令: docker run -d -p 8080:8080 --name caremate-backend caremate-backend"
EOF
    
    # 创建 Docker Compose 脚本
    cat > scripts/docker-compose-start.sh << 'EOF'
#!/bin/bash

echo "🐳 启动 CareMate Backend Docker Compose 环境..."

# 启动所有服务
docker-compose up -d

echo "✅ 所有服务启动完成"
echo "📖 API 文档: http://localhost:8080/api/doc.html"
echo "🔍 健康检查: http://localhost:8080/api/actuator/health"
EOF
    
    # 创建停止脚本
    cat > scripts/docker-compose-stop.sh << 'EOF'
#!/bin/bash

echo "🛑 停止 CareMate Backend Docker Compose 环境..."

# 停止所有服务
docker-compose down

echo "✅ 所有服务已停止"
EOF
    
    # 设置脚本执行权限
    chmod +x scripts/*.sh
    
    print_success "开发脚本创建完成"
}

# 创建 Git 配置
setup_git() {
    print_info "配置 Git..."
    
    # 创建 .gitignore (如果不存在)
    if [ ! -f .gitignore ]; then
        print_warning ".gitignore 文件已存在，跳过创建"
    fi
    
    # 初始化 Git 仓库 (如果未初始化)
    if [ ! -d .git ]; then
        git init
        print_success "Git 仓库初始化完成"
    else
        print_info "Git 仓库已存在"
    fi
}

# 安装依赖
install_dependencies() {
    print_info "安装 Maven 依赖..."
    
    # 下载依赖
    mvn dependency:resolve
    
    print_success "Maven 依赖安装完成"
}

# 验证项目结构
verify_project() {
    print_info "验证项目结构..."
    
    # 检查关键文件
    required_files=(
        "pom.xml"
        "src/main/java/com/caremate/CareMateApplication.java"
        "src/main/resources/application.yml"
        "docker-compose.yml"
        "Dockerfile"
        "README.md"
        ".gitignore"
    )
    
    for file in "${required_files[@]}"; do
        if [ -f "$file" ]; then
            print_success "✓ $file"
        else
            print_error "✗ $file 不存在"
            exit 1
        fi
    done
    
    print_success "项目结构验证完成"
}

# 显示完成信息
show_completion_info() {
    echo ""
    echo "🎉 CareMate Backend 项目初始化完成！"
    echo ""
    echo "📁 项目结构:"
    echo "   ├── src/main/java/com/caremate/  # Java 源代码"
    echo "   ├── src/main/resources/          # 配置文件"
    echo "   ├── docker/                      # Docker 配置"
    echo "   ├── scripts/                     # 开发脚本"
    echo "   └── docs/                        # 文档"
    echo ""
    echo "🚀 快速开始:"
    echo "   1. 配置环境变量: cp .env.example .env && vim .env"
    echo "   2. 启动数据库: docker-compose up -d mysql redis"
    echo "   3. 运行应用: ./scripts/start.sh"
    echo ""
    echo "📖 更多信息请查看 README.md"
    echo ""
    echo "🔗 相关链接:"
    echo "   - API 文档: http://localhost:8080/api/doc.html"
    echo "   - 健康检查: http://localhost:8080/api/actuator/health"
    echo ""
}

# 主函数
main() {
    echo "=========================================="
    echo "  CareMate Backend 项目初始化脚本"
    echo "=========================================="
    echo ""
    
    check_requirements
    create_project_structure
    create_env_file
    create_docker_config
    create_dev_scripts
    setup_git
    install_dependencies
    verify_project
    show_completion_info
}

# 执行主函数
main "$@" 