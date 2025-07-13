-- CareMate 数据库初始化脚本
-- 创建时间: 2024-01-01
-- 版本: 1.0.0

-- 创建数据库
CREATE DATABASE IF NOT EXISTS caremate CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE caremate;

-- 用户基础表
CREATE TABLE IF NOT EXISTS base_users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '用户ID',
    openid VARCHAR(100) UNIQUE NOT NULL COMMENT '微信OpenID',
    unionid VARCHAR(100) COMMENT '微信UnionID',
    nickname VARCHAR(50) COMMENT '昵称',
    avatar_url VARCHAR(500) COMMENT '头像URL',
    phone VARCHAR(20) COMMENT '手机号',
    user_type ENUM('patient', 'caregiver', 'admin') NOT NULL COMMENT '用户类型',
    status ENUM('active', 'inactive', 'banned') DEFAULT 'active' COMMENT '用户状态',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT DEFAULT 0 COMMENT '逻辑删除标记',
    INDEX idx_openid (openid),
    INDEX idx_user_type (user_type),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户基础信息表';

-- 患者资料表
CREATE TABLE IF NOT EXISTS patient_profiles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '患者资料ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    real_name VARCHAR(50) COMMENT '真实姓名',
    gender ENUM('male', 'female') COMMENT '性别',
    age INT COMMENT '年龄',
    id_card VARCHAR(20) COMMENT '身份证号',
    emergency_contact VARCHAR(50) COMMENT '紧急联系人',
    emergency_phone VARCHAR(20) COMMENT '紧急联系电话',
    diagnosis TEXT COMMENT '诊断信息',
    medical_history TEXT COMMENT '病史',
    allergies TEXT COMMENT '过敏史',
    special_needs TEXT COMMENT '特殊需求',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT DEFAULT 0 COMMENT '逻辑删除标记',
    FOREIGN KEY (user_id) REFERENCES base_users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='患者资料表';

-- 陪护资料表
CREATE TABLE IF NOT EXISTS caregiver_profiles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '陪护资料ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    real_name VARCHAR(50) COMMENT '真实姓名',
    gender ENUM('male', 'female') COMMENT '性别',
    age INT COMMENT '年龄',
    id_card VARCHAR(20) COMMENT '身份证号',
    phone VARCHAR(20) COMMENT '联系电话',
    address TEXT COMMENT '地址',
    has_certification TINYINT DEFAULT 0 COMMENT '是否有相关资质证书',
    certification_info TEXT COMMENT '资质证书信息',
    professional_background TEXT COMMENT '专业背景',
    work_experience TEXT COMMENT '工作经验',
    service_areas TEXT COMMENT '服务区域',
    hourly_rate DECIMAL(10,2) COMMENT '时薪',
    available_hours TEXT COMMENT '可服务时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT DEFAULT 0 COMMENT '逻辑删除标记',
    FOREIGN KEY (user_id) REFERENCES base_users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_hourly_rate (hourly_rate)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='陪护资料表';

-- 订单表
CREATE TABLE IF NOT EXISTS orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '订单ID',
    title VARCHAR(200) NOT NULL COMMENT '订单标题',
    description TEXT COMMENT '订单描述',
    patient_id BIGINT NOT NULL COMMENT '患者ID',
    hospital VARCHAR(100) NOT NULL COMMENT '医院名称',
    address TEXT COMMENT '具体地址',
    expected_time DATETIME NOT NULL COMMENT '预计时间',
    duration_hours INT NOT NULL COMMENT '预计时长(小时)',
    price DECIMAL(10,2) NOT NULL COMMENT '价格',
    status ENUM('active', 'requested', 'approved', 'locked', 'closed', 'rejected') DEFAULT 'active' COMMENT '订单状态',
    caregiver_id BIGINT COMMENT '陪护ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT DEFAULT 0 COMMENT '逻辑删除标记',
    FOREIGN KEY (patient_id) REFERENCES base_users(id) ON DELETE CASCADE,
    FOREIGN KEY (caregiver_id) REFERENCES base_users(id) ON DELETE SET NULL,
    INDEX idx_patient_id (patient_id),
    INDEX idx_caregiver_id (caregiver_id),
    INDEX idx_status (status),
    INDEX idx_expected_time (expected_time),
    INDEX idx_price (price)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单表';

-- 申请记录表
CREATE TABLE IF NOT EXISTS applications (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '申请ID',
    order_id BIGINT NOT NULL COMMENT '订单ID',
    caregiver_id BIGINT NOT NULL COMMENT '陪护ID',
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending' COMMENT '申请状态',
    message TEXT COMMENT '申请留言',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT DEFAULT 0 COMMENT '逻辑删除标记',
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (caregiver_id) REFERENCES base_users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_order_caregiver (order_id, caregiver_id),
    INDEX idx_order_id (order_id),
    INDEX idx_caregiver_id (caregiver_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='申请记录表';

-- 文件表
CREATE TABLE IF NOT EXISTS files (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '文件ID',
    original_name VARCHAR(255) NOT NULL COMMENT '原始文件名',
    file_name VARCHAR(255) NOT NULL COMMENT '存储文件名',
    file_path VARCHAR(500) NOT NULL COMMENT '文件路径',
    file_size BIGINT NOT NULL COMMENT '文件大小(字节)',
    file_type VARCHAR(100) COMMENT '文件类型',
    mime_type VARCHAR(100) COMMENT 'MIME类型',
    uploader_id BIGINT NOT NULL COMMENT '上传者ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',
    deleted TINYINT DEFAULT 0 COMMENT '逻辑删除标记',
    FOREIGN KEY (uploader_id) REFERENCES base_users(id) ON DELETE CASCADE,
    INDEX idx_uploader_id (uploader_id),
    INDEX idx_file_type (file_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文件表';

-- 系统配置表
CREATE TABLE IF NOT EXISTS system_configs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '配置ID',
    config_key VARCHAR(100) UNIQUE NOT NULL COMMENT '配置键',
    config_value TEXT COMMENT '配置值',
    description VARCHAR(500) COMMENT '配置描述',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_config_key (config_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统配置表';

-- 操作日志表
CREATE TABLE IF NOT EXISTS operation_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    user_id BIGINT COMMENT '操作用户ID',
    operation VARCHAR(100) NOT NULL COMMENT '操作类型',
    description TEXT COMMENT '操作描述',
    ip_address VARCHAR(50) COMMENT 'IP地址',
    user_agent TEXT COMMENT '用户代理',
    request_url VARCHAR(500) COMMENT '请求URL',
    request_method VARCHAR(10) COMMENT '请求方法',
    request_params TEXT COMMENT '请求参数',
    response_status INT COMMENT '响应状态码',
    execution_time BIGINT COMMENT '执行时间(毫秒)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    FOREIGN KEY (user_id) REFERENCES base_users(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_operation (operation),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='操作日志表';

-- 插入初始数据

-- 插入系统配置
INSERT INTO system_configs (config_key, config_value, description) VALUES
('site_name', 'CareMate', '网站名称'),
('site_description', '专业的护理陪诊服务平台', '网站描述'),
('max_file_size', '10485760', '最大文件上传大小(字节)'),
('allowed_file_types', 'jpg,jpeg,png,gif,pdf,doc,docx', '允许上传的文件类型'),
('order_expire_hours', '24', '订单过期时间(小时)'),
('min_order_price', '50.00', '最低订单价格'),
('max_order_price', '1000.00', '最高订单价格');

-- 插入管理员用户（密码需要在实际使用时修改）
INSERT INTO base_users (openid, nickname, user_type, status) VALUES
('admin_caremate', 'CareMate管理员', 'admin', 'active');

-- 创建视图：用户完整信息视图
CREATE VIEW user_complete_info AS
SELECT 
    u.id,
    u.openid,
    u.nickname,
    u.avatar_url,
    u.phone,
    u.user_type,
    u.status,
    u.created_at,
    u.updated_at,
    CASE 
        WHEN u.user_type = 'patient' THEN p.real_name
        WHEN u.user_type = 'caregiver' THEN c.real_name
        ELSE NULL
    END as real_name,
    CASE 
        WHEN u.user_type = 'patient' THEN p.gender
        WHEN u.user_type = 'caregiver' THEN c.gender
        ELSE NULL
    END as gender,
    CASE 
        WHEN u.user_type = 'patient' THEN p.age
        WHEN u.user_type = 'caregiver' THEN c.age
        ELSE NULL
    END as age
FROM base_users u
LEFT JOIN patient_profiles p ON u.id = p.user_id AND u.user_type = 'patient'
LEFT JOIN caregiver_profiles c ON u.id = c.user_id AND u.user_type = 'caregiver'
WHERE u.deleted = 0;

-- 创建视图：订单详细信息视图
CREATE VIEW order_detail_info AS
SELECT 
    o.id,
    o.title,
    o.description,
    o.hospital,
    o.address,
    o.expected_time,
    o.duration_hours,
    o.price,
    o.status,
    o.created_at,
    o.updated_at,
    -- 患者信息
    p.user_id as patient_id,
    p.real_name as patient_name,
    p.gender as patient_gender,
    p.age as patient_age,
    -- 陪护信息
    c.user_id as caregiver_id,
    c.real_name as caregiver_name,
    c.gender as caregiver_gender,
    c.age as caregiver_age,
    c.hourly_rate as caregiver_hourly_rate
FROM orders o
LEFT JOIN patient_profiles p ON o.patient_id = p.user_id
LEFT JOIN caregiver_profiles c ON o.caregiver_id = c.user_id
WHERE o.deleted = 0;

-- 创建索引优化查询性能
CREATE INDEX idx_orders_status_created ON orders(status, created_at);
CREATE INDEX idx_applications_status_created ON applications(status, created_at);
CREATE INDEX idx_users_type_status ON base_users(user_type, status);
CREATE INDEX idx_caregiver_rate_status ON caregiver_profiles(hourly_rate, deleted);

-- 插入测试数据（可选）
-- 注意：在生产环境中应该删除这些测试数据

-- 插入测试患者
INSERT INTO base_users (openid, nickname, user_type, status) VALUES
('test_patient_1', '测试患者1', 'patient', 'active'),
('test_patient_2', '测试患者2', 'patient', 'active');

-- 插入测试陪护
INSERT INTO base_users (openid, nickname, user_type, status) VALUES
('test_caregiver_1', '测试陪护1', 'caregiver', 'active'),
('test_caregiver_2', '测试陪护2', 'caregiver', 'active');

-- 插入患者资料
INSERT INTO patient_profiles (user_id, real_name, gender, age, emergency_contact, emergency_phone) VALUES
(2, '周峰峰', 'male', 65, '陈明远', '13800138001'),
(3, '陈飞飞', 'female', 58, '王佳琦', '13800138002');

-- 插入陪护资料
INSERT INTO caregiver_profiles (user_id, real_name, gender, age, phone, has_certification, hourly_rate) VALUES
(4, '王佳琦', 'female', 35, '13900139001', 1, 80.00),
(5, '洪一峰', 'male', 42, '13900139002', 1, 100.00);

-- 插入测试订单
INSERT INTO orders (title, description, patient_id, hospital, address, expected_time, duration_hours, price, status) VALUES
('需要陪诊服务', '需要专业陪护人员陪同就医', 2, '北京协和医院', '北京市东城区东单帅府园1号', '2024-01-15 09:00:00', 4, 320.00, 'active'),
('术后护理', '术后需要专业护理服务', 3, '北京大学第一医院', '北京市西城区西什库大街8号', '2024-01-16 14:00:00', 6, 480.00, 'active');

COMMIT; 