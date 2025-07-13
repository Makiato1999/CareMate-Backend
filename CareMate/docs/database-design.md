# CareMate 数据库设计

## 1. 用户基础表 (users)

```sql
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    openid VARCHAR(100) UNIQUE NOT NULL COMMENT '微信openid',
    unionid VARCHAR(100) COMMENT '微信unionid',
    user_type ENUM('patient', 'caregiver', 'admin') NOT NULL COMMENT '用户类型',
    nickname VARCHAR(50) COMMENT '昵称',
    avatar_url VARCHAR(500) COMMENT '头像URL',
    phone VARCHAR(20) COMMENT '手机号',
    status ENUM('active', 'inactive', 'banned') DEFAULT 'active' COMMENT '用户状态',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT DEFAULT 0 COMMENT '逻辑删除标记',
    INDEX idx_openid (openid),
    INDEX idx_user_type (user_type),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户基础信息表';
```

## 2. 患者资料表 (patient_profiles)

```sql
CREATE TABLE patient_profiles (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '患者资料ID',
    user_id BIGINT NOT NULL UNIQUE COMMENT '用户ID',
    real_name VARCHAR(50) COMMENT '真实姓名',
    gender ENUM('male', 'female', 'unknown') DEFAULT 'unknown' COMMENT '性别',
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
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='患者资料表';
```

## 3. 陪护资料表 (caregiver_profiles)

```sql
CREATE TABLE caregiver_profiles (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '陪护资料ID',
    user_id BIGINT NOT NULL UNIQUE COMMENT '用户ID',
    real_name VARCHAR(50) COMMENT '真实姓名',
    gender ENUM('male', 'female', 'unknown') DEFAULT 'unknown' COMMENT '性别',
    age INT COMMENT '年龄',
    id_card VARCHAR(20) COMMENT '身份证号',
    phone VARCHAR(20) COMMENT '联系电话',
    address TEXT COMMENT '地址',
    has_certification TINYINT DEFAULT 0 COMMENT '是否有相关资质证书',
    certification_info TEXT COMMENT '资质证书信息',
    professional_background TEXT COMMENT '专业背景',
    work_experience INT COMMENT '工作经验(年)',
    service_areas TEXT COMMENT '服务区域',
    hourly_rate DECIMAL(10,2) COMMENT '时薪',
    available_hours TEXT COMMENT '可服务时间',
    skills TEXT COMMENT '专业技能',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT DEFAULT 0 COMMENT '逻辑删除标记',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_has_certification (has_certification),
    INDEX idx_hourly_rate (hourly_rate)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='陪护资料表';
```

## 4. 订单表 (orders)

```sql
CREATE TABLE orders (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '订单ID',
    order_no VARCHAR(50) UNIQUE NOT NULL COMMENT '订单号',
    patient_id BIGINT NOT NULL COMMENT '患者ID',
    caregiver_id BIGINT COMMENT '陪护ID',
    title VARCHAR(200) NOT NULL COMMENT '订单标题',
    description TEXT COMMENT '订单描述',
    hospital VARCHAR(100) NOT NULL COMMENT '医院名称',
    address TEXT COMMENT '具体地址',
    expected_time DATETIME NOT NULL COMMENT '预计时间',
    duration_hours INT NOT NULL COMMENT '预计时长(小时)',
    price DECIMAL(10,2) NOT NULL COMMENT '价格',
    status ENUM('active', 'requested', 'approved', 'locked', 'closed', 'rejected') DEFAULT 'active' COMMENT '订单状态',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    closed_at TIMESTAMP NULL COMMENT '订单关闭时间',
    deleted TINYINT DEFAULT 0 COMMENT '逻辑删除标记',
    FOREIGN KEY (patient_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (caregiver_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_patient_id (patient_id),
    INDEX idx_caregiver_id (caregiver_id),
    INDEX idx_status (status),
    INDEX idx_expected_time (expected_time),
    INDEX idx_price (price)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单表';
```

## 5. 订单申请记录表 (order_applications)

```sql
CREATE TABLE order_applications (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '申请ID',
    order_id BIGINT NOT NULL COMMENT '订单ID',
    caregiver_id BIGINT NOT NULL COMMENT '陪护ID',
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending' COMMENT '申请状态',
    message TEXT COMMENT '申请留言',
    proposed_price DECIMAL(10,2) COMMENT '提议价格',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT DEFAULT 0 COMMENT '逻辑删除标记',
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (caregiver_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_order_caregiver (order_id, caregiver_id),
    INDEX idx_order_id (order_id),
    INDEX idx_caregiver_id (caregiver_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单申请记录表';
```

## 6. 文件表 (files)

```sql
CREATE TABLE files (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '文件ID',
    original_name VARCHAR(255) NOT NULL COMMENT '原始文件名',
    file_name VARCHAR(255) NOT NULL COMMENT '存储文件名',
    file_path VARCHAR(500) NOT NULL COMMENT '文件路径',
    file_size BIGINT NOT NULL COMMENT '文件大小(字节)',
    file_type VARCHAR(100) COMMENT '文件类型',
    mime_type VARCHAR(100) COMMENT 'MIME类型',
    uploader_id BIGINT NOT NULL COMMENT '上传者ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',
    deleted TINYINT DEFAULT 0 COMMENT '逻辑删除标记',
    FOREIGN KEY (uploader_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_uploader_id (uploader_id),
    INDEX idx_file_type (file_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文件表';
```

## 7. 系统配置表 (system_configs)

```sql
CREATE TABLE system_configs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '配置ID',
    config_key VARCHAR(100) UNIQUE NOT NULL COMMENT '配置键',
    config_value TEXT COMMENT '配置值',
    description VARCHAR(500) COMMENT '配置描述',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_config_key (config_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统配置表';
```

## 8. 操作日志表 (operation_logs)

```sql
CREATE TABLE operation_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '日志ID',
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
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_operation (operation),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='操作日志表';
```

## 9. 数据统计视图

### 9.1 陪护人员统计视图 (caregiver_stats)

```sql
CREATE VIEW caregiver_stats AS
SELECT 
    u.id AS caregiver_id,
    u.nickname,
    u.avatar_url,
    c.hourly_rate,
    c.has_certification,
    COUNT(o.id) AS total_orders,
    SUM(o.price) AS total_earnings,
    COUNT(CASE WHEN o.status = 'closed' THEN 1 END) AS completed_orders,
    AVG(o.price) AS avg_order_price,
    COUNT(DISTINCT o.patient_id) AS unique_patients
FROM users u
LEFT JOIN caregiver_profiles c ON u.id = c.user_id
LEFT JOIN orders o ON u.id = o.caregiver_id
WHERE u.user_type = 'caregiver'
GROUP BY u.id, u.nickname, u.avatar_url, c.hourly_rate, c.has_certification;
```

### 9.2 患者统计视图 (patient_stats)

```sql
CREATE VIEW patient_stats AS
SELECT 
    u.id AS patient_id,
    u.nickname,
    u.avatar_url,
    p.diagnosis,
    COUNT(o.id) AS total_orders,
    SUM(o.duration_hours) AS total_service_hours,
    COUNT(CASE WHEN o.status = 'closed' THEN 1 END) AS completed_orders,
    AVG(o.price) AS avg_order_price,
    COUNT(DISTINCT o.caregiver_id) AS unique_caregivers
FROM users u
LEFT JOIN patient_profiles p ON u.id = p.user_id
LEFT JOIN orders o ON u.id = o.patient_id
WHERE u.user_type = 'patient'
GROUP BY u.id, u.nickname, u.avatar_url, p.diagnosis;
```

### 9.3 订单统计视图 (order_stats)

```sql
CREATE VIEW order_stats AS
SELECT 
    DATE(created_at) AS order_date,
    COUNT(*) AS total_orders,
    COUNT(CASE WHEN status = 'closed' THEN 1 END) AS completed_orders,
    COUNT(CASE WHEN status = 'active' THEN 1 END) AS active_orders,
    SUM(price) AS total_revenue,
    AVG(price) AS avg_order_price,
    AVG(duration_hours) AS avg_duration
FROM orders
GROUP BY DATE(created_at)
ORDER BY order_date DESC;
```

## 10. 系统配置初始化数据

```sql
INSERT INTO system_configs (config_key, config_value, description) VALUES
('site_name', 'CareMate', '网站名称'),
('order_auto_close_hours', '24', '订单自动关闭时间(小时)'),
('max_order_price', '1000', '最大订单价格'),
('min_order_price', '50', '最小订单价格'),
('caregiver_commission_rate', '0.05', '陪护人员佣金比例'),
('platform_service_fee', '0.03', '平台服务费比例');
```

## 11. 管理员初始用户

```sql
INSERT INTO users (openid, nickname, user_type, status) VALUES
('admin_caremate', 'CareMate管理员', 'admin', 'active');
```

## 12. 设计特点

### 12.1 逻辑删除
- 所有主要业务表都包含 `deleted` 字段，支持逻辑删除
- 避免数据丢失，便于数据恢复和审计

### 12.2 完整的审计功能
- `operation_logs` 表记录所有用户操作
- 包含请求详情、响应状态、执行时间等信息
- 支持系统监控和问题排查

### 12.3 文件管理
- `files` 表统一管理所有上传文件
- 支持文件类型、大小、MIME类型等信息
- 便于文件存储和访问控制

### 12.4 灵活的配置管理
- `system_configs` 表支持动态配置
- 无需修改代码即可调整系统参数
- 支持配置描述和版本管理

### 12.5 优化的索引设计
- 针对常用查询场景建立索引
- 支持高效的数据检索和统计
- 平衡查询性能和存储空间

## 13. 查询示例

### 13.1 获取陪护人员完整信息
```sql
SELECT 
    u.*,
    c.*
FROM users u
LEFT JOIN caregiver_profiles c ON u.id = c.user_id
WHERE u.user_type = 'caregiver' AND u.id = ? AND u.deleted = 0
```

### 13.2 获取患者完整信息
```sql
SELECT 
    u.*,
    p.*
FROM users u
LEFT JOIN patient_profiles p ON u.id = p.user_id
WHERE u.user_type = 'patient' AND u.id = ? AND u.deleted = 0
```

### 13.3 获取有资质的陪护人员
```sql
SELECT 
    u.id,
    u.nickname,
    u.avatar_url,
    c.hourly_rate,
    c.skills
FROM users u
INNER JOIN caregiver_profiles c ON u.id = c.user_id
WHERE u.user_type = 'caregiver' 
  AND c.has_certification = 1
  AND u.status = 'active'
  AND u.deleted = 0
ORDER BY c.hourly_rate ASC
```

### 13.4 获取活跃订单
```sql
SELECT 
    o.*,
    u1.nickname AS patient_name,
    u2.nickname AS caregiver_name
FROM orders o
LEFT JOIN users u1 ON o.patient_id = u1.id
LEFT JOIN users u2 ON o.caregiver_id = u2.id
WHERE o.status IN ('active', 'requested', 'approved')
  AND o.deleted = 0
ORDER BY o.expected_time ASC
``` 