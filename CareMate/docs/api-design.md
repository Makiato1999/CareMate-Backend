# CareMate API 接口设计

## 基础信息

- **Base URL**: `https://api.caremate.com/v1`
- **认证方式**: Bearer Token (JWT)
- **数据格式**: JSON
- **字符编码**: UTF-8
- **时间格式**: ISO 8601 (YYYY-MM-DDTHH:mm:ssZ)

## 通用响应格式

```json
{
  "code": 200,
  "message": "success",
  "data": {},
  "timestamp": "2024-01-01T00:00:00Z"
}
```

## 1. 用户认证模块

### 1.1 微信登录
```
POST /auth/wechat/login
```

**请求参数:**
```json
{
  "code": "string", // 微信授权码
  "userInfo": {
    "nickName": "string",
    "avatarUrl": "string",
    "gender": 0
  }
}
```

**响应:**
```json
{
  "code": 200,
  "data": {
    "token": "jwt_token",
    "user": {
      "id": 1,
      "openid": "string",
      "unionid": "string",
      "nickname": "string",
      "avatarUrl": "string",
      "userType": "patient|caregiver|admin",
      "phone": "string",
      "status": "active|inactive|banned",
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-01T00:00:00Z"
    }
  }
}
```

### 1.2 完善用户资料
```
PUT /auth/profile
```

**请求参数:**
```json
{
  "userType": "patient|caregiver",
  "phone": "string",
  
  // 患者特有字段 (当 userType 为 patient 时)
  "patientProfile": {
    "realName": "string",
    "gender": "male|female|unknown",
    "age": 25,
    "idCard": "string",
    "emergencyContact": "string",
    "emergencyPhone": "string",
    "diagnosis": "string",
    "medicalHistory": "string",
    "allergies": "string",
    "specialNeeds": "string"
  },
  
  // 陪护人员特有字段 (当 userType 为 caregiver 时)
  "caregiverProfile": {
    "realName": "string",
    "gender": "male|female|unknown",
    "age": 35,
    "idCard": "string",
    "phone": "string",
    "address": "string",
    "hasCertification": 0, // 0-否，1-是
    "certificationInfo": "string",
    "professionalBackground": "string",
    "workExperience": 5,
    "serviceAreas": "string",
    "hourlyRate": 50.00,
    "availableHours": "string",
    "skills": "string"
  }
}
```

**响应:**
```json
{
  "code": 200,
  "data": {
    "id": 1,
    "openid": "string",
    "unionid": "string",
    "nickname": "string",
    "avatarUrl": "string",
    "userType": "patient",
    "phone": "string",
    "status": "active",
    "createdAt": "2024-01-01T00:00:00Z",
    "updatedAt": "2024-01-01T00:00:00Z",
    "patientProfile": {
      "id": 1,
      "userId": 1,
      "realName": "张三",
      "gender": "male",
      "age": 65,
      "idCard": "110101195801011234",
      "emergencyContact": "张小明",
      "emergencyPhone": "138****1234",
      "diagnosis": "高血压",
      "medicalHistory": "高血压病史5年",
      "allergies": "无",
      "specialNeeds": "需要轮椅",
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-01T00:00:00Z"
    }
  }
}
```

## 2. 订单管理模块

### 2.1 获取订单列表
```
GET /orders
```

**查询参数:**
- `status`: 订单状态筛选 (active|requested|approved|locked|closed|rejected)
- `page`: 页码 (默认1)
- `limit`: 每页数量 (默认20)
- `userType`: 用户类型 (patient|caregiver)

**响应:**
```json
{
  "code": 200,
  "data": {
    "orders": [
      {
        "id": 1,
        "orderNo": "CB202401010001",
        "patientId": 1,
        "caregiverId": null,
        "title": "陪诊服务",
        "description": "需要陪护人员陪同就诊",
        "hospital": "协和医院",
        "address": "北京市东城区东单帅府园1号",
        "expectedTime": "2024-01-15T09:00:00Z",
        "durationHours": 4,
        "price": 200.00,
        "status": "active",
        "createdAt": "2024-01-01T00:00:00Z",
        "updatedAt": "2024-01-01T00:00:00Z",
        "closedAt": null,
        "deleted": 0,
        "patientInfo": {
          "nickname": "张**",
          "gender": "male",
          "age": 65
        }
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 100,
      "totalPages": 5
    }
  }
}
```

### 2.2 创建订单
```
POST /orders
```

**请求参数:**
```json
{
  "title": "陪诊服务",
  "description": "需要陪护人员陪同就诊",
  "hospital": "协和医院",
  "address": "北京市东城区东单帅府园1号",
  "expectedTime": "2024-01-15T09:00:00Z",
  "durationHours": 4,
  "price": 200.00
}
```

**响应:**
```json
{
  "code": 200,
  "data": {
    "id": 1,
    "orderNo": "CB202401010001",
    "patientId": 1,
    "caregiverId": null,
    "title": "陪诊服务",
    "description": "需要陪护人员陪同就诊",
    "hospital": "协和医院",
    "address": "北京市东城区东单帅府园1号",
    "expectedTime": "2024-01-15T09:00:00Z",
    "durationHours": 4,
    "price": 200.00,
    "status": "active",
    "createdAt": "2024-01-01T00:00:00Z",
    "updatedAt": "2024-01-01T00:00:00Z",
    "closedAt": null,
    "deleted": 0
  }
}
```

### 2.3 获取订单详情
```
GET /orders/{orderId}
```

**响应:**
```json
{
  "code": 200,
  "data": {
    "id": 1,
    "orderNo": "CB202401010001",
    "patientId": 1,
    "caregiverId": 2,
    "title": "陪诊服务",
    "description": "需要陪护人员陪同就诊",
    "hospital": "协和医院",
    "address": "北京市东城区东单帅府园1号",
    "expectedTime": "2024-01-15T09:00:00Z",
    "durationHours": 4,
    "price": 200.00,
    "status": "approved",
    "createdAt": "2024-01-01T00:00:00Z",
    "updatedAt": "2024-01-01T00:00:00Z",
    "closedAt": null,
    "deleted": 0,
    "patientInfo": {
      "nickname": "张**",
      "gender": "male",
      "age": 65
    },
    "caregiverInfo": {
      "nickname": "李**",
      "gender": "female",
      "age": 45,
      "hasCertification": 1
    }
  }
}
```

### 2.4 申请接单
```
POST /orders/{orderId}/applications
```

**请求参数:**
```json
{
  "message": "我可以提供专业的陪护服务",
  "proposedPrice": 200.00
}
```

**响应:**
```json
{
  "code": 200,
  "data": {
    "id": 1,
    "orderId": 1,
    "caregiverId": 2,
    "message": "我可以提供专业的陪护服务",
    "proposedPrice": 200.00,
    "status": "pending",
    "createdAt": "2024-01-01T00:00:00Z"
  }
}
```

### 2.5 处理接单申请
```
PUT /orders/{orderId}/applications/{applicationId}
```

**请求参数:**
```json
{
  "action": "approve|reject"
}
```

### 2.6 确认订单
```
PUT /orders/{orderId}/confirm
```

### 2.7 修改订单
```
PUT /orders/{orderId}
```

**请求参数:**
```json
{
  "title": "陪诊服务",
  "description": "需要陪护人员陪同就诊",
  "hospital": "协和医院",
  "address": "北京市东城区东单帅府园1号",
  "expectedTime": "2024-01-15T09:00:00Z",
  "durationHours": 4,
  "price": 200.00
}
```

### 2.8 取消订单
```
DELETE /orders/{orderId}
```

## 3. 文件管理模块

### 3.1 文件上传
```
POST /files/upload
```

**请求参数:**
- `file`: 文件 (multipart/form-data)
- `type`: 文件类型 (可选)

**响应:**
```json
{
  "code": 200,
  "data": {
    "id": 1,
    "originalName": "certificate.jpg",
    "fileName": "20240101_123456_certificate.jpg",
    "filePath": "/uploads/20240101_123456_certificate.jpg",
    "fileSize": 1024000,
    "fileType": "image",
    "mimeType": "image/jpeg",
    "uploaderId": 1,
    "accessUrl": "https://api.caremate.com/files/20240101_123456_certificate.jpg",
    "createdAt": "2024-01-01T00:00:00Z"
  }
}
```

### 3.2 获取文件信息
```
GET /files/{fileId}
```

**响应:**
```json
{
  "code": 200,
  "data": {
    "id": 1,
    "originalName": "certificate.jpg",
    "fileName": "20240101_123456_certificate.jpg",
    "filePath": "/uploads/20240101_123456_certificate.jpg",
    "fileSize": 1024000,
    "fileType": "image",
    "mimeType": "image/jpeg",
    "uploaderId": 1,
    "accessUrl": "https://api.caremate.com/files/20240101_123456_certificate.jpg",
    "createdAt": "2024-01-01T00:00:00Z"
  }
}
```

### 3.3 删除文件
```
DELETE /files/{fileId}
```

## 4. 用户中心模块

### 4.1 获取用户统计
```
GET /users/stats
```

**响应:**
```json
{
  "code": 200,
  "data": {
    "userType": "caregiver",
    "totalOrders": 15,
    "totalEarnings": 3000.00,
    "completedOrders": 12,
    "avgOrderPrice": 200.00,
    "totalHours": 48
  }
}
```

### 4.2 获取日统计
```
GET /users/stats/daily
```

**查询参数:**
- `startDate`: 开始日期 (YYYY-MM-DD)
- `endDate`: 结束日期 (YYYY-MM-DD)

**响应:**
```json
{
  "code": 200,
  "data": [
    {
      "date": "2024-01-01",
      "orderCount": 3,
      "dailyEarnings": 600.00
    },
    {
      "date": "2024-01-02",
      "orderCount": 2,
      "dailyEarnings": 400.00
    }
  ]
}
```

### 4.3 获取用户资料
```
GET /users/profile
```

**响应:**
```json
{
  "code": 200,
  "data": {
    "id": 1,
    "openid": "string",
    "nickname": "string",
    "avatarUrl": "string",
    "userType": "patient",
    "phone": "string",
    "status": "active",
    "createdAt": "2024-01-01T00:00:00Z",
    "updatedAt": "2024-01-01T00:00:00Z",
    "patientProfile": {
      "id": 1,
      "userId": 1,
      "realName": "张三",
      "gender": "male",
      "age": 65,
      "idCard": "110101195801011234",
      "emergencyContact": "张小明",
      "emergencyPhone": "138****1234",
      "diagnosis": "高血压",
      "medicalHistory": "高血压病史5年",
      "allergies": "无",
      "specialNeeds": "需要轮椅",
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-01T00:00:00Z"
    }
  }
}
```

### 4.4 更新用户资料
```
PUT /users/profile
```

## 5. 系统管理模块

### 5.1 获取系统配置
```
GET /admin/configs
```

**响应:**
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "configKey": "site_name",
      "configValue": "CareMate",
      "description": "网站名称",
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-01T00:00:00Z"
    },
    {
      "id": 2,
      "configKey": "order_auto_close_hours",
      "configValue": "24",
      "description": "订单自动关闭时间(小时)",
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-01T00:00:00Z"
    }
  ]
}
```

### 5.2 更新系统配置
```
PUT /admin/configs/{configKey}
```

**请求参数:**
```json
{
  "configValue": "CareMate Pro",
  "description": "网站名称"
}
```

### 5.3 获取操作日志
```
GET /admin/logs
```

**查询参数:**
- `userId`: 用户ID (可选)
- `operation`: 操作类型 (可选)
- `startDate`: 开始日期 (YYYY-MM-DD)
- `endDate`: 结束日期 (YYYY-MM-DD)
- `page`: 页码
- `limit`: 每页数量

**响应:**
```json
{
  "code": 200,
  "data": {
    "logs": [
      {
        "id": 1,
        "userId": 1,
        "operation": "user_login",
        "description": "用户登录",
        "ipAddress": "192.168.1.1",
        "userAgent": "Mozilla/5.0...",
        "requestUrl": "/api/auth/login",
        "requestMethod": "POST",
        "responseStatus": 200,
        "executionTime": 150,
        "createdAt": "2024-01-01T00:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 100,
      "totalPages": 5
    }
  }
}
```

## 6. 管理员模块

### 6.1 获取所有用户
```
GET /admin/users
```

**查询参数:**
- `userType`: 用户类型筛选 (patient|caregiver|admin)
- `status`: 状态筛选 (active|inactive|banned)
- `page`: 页码
- `limit`: 每页数量

### 6.2 获取所有订单
```
GET /admin/orders
```

**查询参数:**
- `status`: 订单状态筛选
- `userType`: 用户类型筛选
- `page`: 页码
- `limit`: 每页数量

### 6.3 更新订单状态
```
PUT /admin/orders/{orderId}/status
```

**请求参数:**
```json
{
  "status": "active|requested|approved|locked|closed|rejected"
}
```

### 6.4 获取系统统计
```
GET /admin/stats
```

**响应:**
```json
{
  "code": 200,
  "data": {
    "totalUsers": 1000,
    "totalPatients": 600,
    "totalCaregivers": 400,
    "totalOrders": 500,
    "activeOrders": 50,
    "completedOrders": 400,
    "totalRevenue": 50000.00,
    "dailyStats": [
      {
        "date": "2024-01-01",
        "newUsers": 10,
        "newOrders": 25,
        "revenue": 2500.00
      }
    ]
  }
}
```

## 7. 错误码定义

| 错误码 | 说明 |
|--------|------|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未授权 |
| 403 | 权限不足 |
| 404 | 资源不存在 |
| 409 | 资源冲突 |
| 413 | 文件过大 |
| 415 | 不支持的文件类型 |
| 500 | 服务器内部错误 |

## 8. 状态码说明

### 订单状态
- `active`: 活跃状态，可被申请
- `requested`: 已申请，等待患者确认
- `approved`: 已批准，等待陪护确认
- `locked`: 已锁定，开始执行
- `closed`: 已完成
- `rejected`: 已拒绝

### 申请状态
- `pending`: 待处理
- `approved`: 已批准
- `rejected`: 已拒绝

### 用户类型
- `patient`: 患者
- `caregiver`: 陪护人员
- `admin`: 管理员

### 用户状态
- `active`: 活跃
- `inactive`: 非活跃
- `banned`: 已禁用

### 性别
- `male`: 男
- `female`: 女
- `unknown`: 未知

### 文件类型
- `image`: 图片
- `document`: 文档
- `certificate`: 证书
- `other`: 其他 