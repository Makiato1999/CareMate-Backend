# CareMate React 移动端前端设计

## 1. 项目概述

**技术栈**: React + TypeScript + Ant Design Mobile + Axios
**目标平台**: 移动端 Web 应用（支持微信内浏览器）
**兼容性**: iOS Safari, Android Chrome, 微信内置浏览器

## 2. 项目结构

```
caremate-frontend-react/
├── src/
│   ├── pages/           # 页面组件
│   │   ├── auth/        # 认证相关
│   │   ├── home/        # 首页
│   │   ├── orders/      # 订单相关
│   │   ├── profile/     # 个人中心
│   │   ├── files/       # 文件管理
│   │   └── admin/       # 管理员页面
│   ├── components/      # 公共组件
│   │   ├── common/      # 通用组件
│   │   ├── forms/       # 表单组件
│   │   ├── upload/      # 上传组件
│   │   └── layout/      # 布局组件
│   ├── services/        # API服务
│   ├── hooks/           # 自定义Hooks
│   ├── utils/           # 工具函数
│   ├── styles/          # 样式文件
│   ├── types/           # TypeScript类型定义
│   ├── constants/       # 常量定义
│   └── App.tsx          # 应用入口
├── public/              # 静态资源
├── package.json
├── tsconfig.json
└── vite.config.ts
```

## 3. 技术选型

### 3.1 核心框架
- **React 18**: 最新版本，支持并发特性
- **TypeScript**: 类型安全，提高开发效率
- **Vite**: 快速构建工具

### 3.2 UI 组件库
- **Ant Design Mobile**: 移动端组件库
- **CSS Modules**: 样式隔离
- **PostCSS**: CSS 后处理器

### 3.3 状态管理
- **React Context**: 全局状态管理
- **React Query**: 服务端状态管理
- **Zustand**: 轻量级状态管理（可选）

### 3.4 路由管理
- **React Router**: 客户端路由
- **路由懒加载**: 按需加载页面

### 3.5 网络请求
- **Axios**: HTTP 客户端
- **请求拦截器**: Token 管理
- **响应拦截器**: 错误处理

## 4. 类型定义

### 4.1 用户相关类型

```typescript
// 用户类型枚举
export enum UserType {
  PATIENT = 'patient',
  CAREGIVER = 'caregiver',
  ADMIN = 'admin'
}

// 用户状态枚举
export enum UserStatus {
  ACTIVE = 'active',
  INACTIVE = 'inactive',
  BANNED = 'banned'
}

// 性别枚举
export enum Gender {
  MALE = 'male',
  FEMALE = 'female',
  UNKNOWN = 'unknown'
}

// 用户基础信息
export interface User {
  id: number;
  openid: string;
  unionid?: string;
  userType: UserType;
  nickname?: string;
  avatarUrl?: string;
  phone?: string;
  status: UserStatus;
  createdAt: string;
  updatedAt: string;
  deleted?: number;
}

// 患者资料
export interface PatientProfile {
  id: number;
  userId: number;
  realName?: string;
  gender: Gender;
  age?: number;
  idCard?: string;
  emergencyContact?: string;
  emergencyPhone?: string;
  diagnosis?: string;
  medicalHistory?: string;
  allergies?: string;
  specialNeeds?: string;
  createdAt: string;
  updatedAt: string;
  deleted?: number;
}

// 陪护资料
export interface CaregiverProfile {
  id: number;
  userId: number;
  realName?: string;
  gender: Gender;
  age?: number;
  idCard?: string;
  phone?: string;
  address?: string;
  hasCertification: number; // 0-否，1-是
  certificationInfo?: string;
  professionalBackground?: string;
  workExperience?: number;
  serviceAreas?: string;
  hourlyRate?: number;
  availableHours?: string;
  skills?: string;
  createdAt: string;
  updatedAt: string;
  deleted?: number;
}
```

### 4.2 订单相关类型

```typescript
// 订单状态枚举
export enum OrderStatus {
  ACTIVE = 'active',
  REQUESTED = 'requested',
  APPROVED = 'approved',
  LOCKED = 'locked',
  CLOSED = 'closed',
  REJECTED = 'rejected'
}

// 申请状态枚举
export enum ApplicationStatus {
  PENDING = 'pending',
  APPROVED = 'approved',
  REJECTED = 'rejected'
}

// 订单信息
export interface Order {
  id: number;
  orderNo: string;
  patientId: number;
  caregiverId?: number;
  title: string;
  description?: string;
  hospital: string;
  address?: string;
  expectedTime: string;
  durationHours: number;
  price: number;
  status: OrderStatus;
  createdAt: string;
  updatedAt: string;
  closedAt?: string;
  deleted?: number;
  patientInfo?: {
    nickname: string;
    gender: Gender;
    age?: number;
  };
  caregiverInfo?: {
    nickname: string;
    gender: Gender;
    age?: number;
    hasCertification: number;
  };
}

// 订单申请
export interface OrderApplication {
  id: number;
  orderId: number;
  caregiverId: number;
  status: ApplicationStatus;
  message?: string;
  proposedPrice?: number;
  createdAt: string;
  updatedAt: string;
  deleted?: number;
}
```

### 4.3 文件相关类型

```typescript
// 文件类型枚举
export enum FileType {
  IMAGE = 'image',
  DOCUMENT = 'document',
  CERTIFICATE = 'certificate',
  OTHER = 'other'
}

// 文件信息
export interface File {
  id: number;
  originalName: string;
  fileName: string;
  filePath: string;
  fileSize: number;
  fileType?: FileType;
  mimeType?: string;
  uploaderId: number;
  createdAt: string;
  deleted?: number;
}
```

## 5. 页面设计

### 5.1 首页 (pages/home)

**功能描述**: 根据用户类型显示不同的内容

**患者端**:
- 我的订单列表 (按状态分组)
- 发布新订单按钮
- 订单状态统计卡片

**陪护端**:
- 可接订单列表
- 我的申请列表
- 收入统计卡片

**页面结构**:
```tsx
// 患者端首页
<Layout>
  <Header title="我的订单" />
  <TabBar tabs={['已发布', '进行中', '已完成']} />
  <OrderList orders={orders} />
  <FloatingButton onClick={navigateToCreate} />
</Layout>

// 陪护端首页
<Layout>
  <Header title="可接订单" />
  <SearchBar />
  <FilterBar />
  <OrderList orders={availableOrders} />
  <TabBar tabs={['可接订单', '我的申请', '我的订单']} />
</Layout>
```

### 5.2 订单详情页 (pages/orders/detail)

**功能描述**: 显示订单详细信息，根据状态和用户权限显示不同内容

**页面结构**:
- 订单基本信息展示
- 根据订单状态显示不同操作按钮
- 用户信息脱敏显示
- 订单状态流转操作

### 5.3 发布订单页 (pages/orders/create)

**功能描述**: 患者发布新订单

**页面结构**:
- 订单标题输入
- 医院信息选择
- 时间地点设置
- 价格和时长配置（时长改为整数）
- 订单描述编辑

### 5.4 个人中心页 (pages/profile)

**功能描述**: 用户资料管理和数据统计

**页面结构**:
- 用户基本信息展示
- 数据统计卡片
- 功能菜单列表
- 设置和帮助入口

### 5.5 用户资料编辑页 (pages/profile/edit)

**功能描述**: 编辑用户详细资料

**患者端**:
- 基本信息编辑（新增真实姓名、身份证号、性别、年龄）
- 医疗信息管理
- 紧急联系人设置

**陪护端**:
- 基本信息编辑（新增真实姓名、身份证号、性别、年龄、地址）
- 资质证书上传（hasCertification改为数字类型）
- 工作经验填写

### 5.6 文件管理页 (pages/files)

**功能描述**: 文件上传和管理

**页面结构**:
- 文件上传组件
- 文件列表展示
- 文件预览功能
- 文件删除操作

## 6. 组件设计

### 6.1 订单卡片组件 (OrderCard)

**功能描述**: 统一的订单信息展示组件

**组件特性**:
- 支持不同用户类型的显示模式
- 订单状态标签显示
- 关键信息突出展示
- 点击跳转详情页
- 响应式设计

### 6.2 状态标签组件 (StatusTag)

**功能描述**: 订单状态的可视化标签

**状态类型**:
- active: 可申请
- requested: 待确认
- approved: 已批准
- locked: 进行中
- closed: 已完成
- rejected: 已拒绝

### 6.3 用户信息卡片 (UserCard)

**功能描述**: 用户信息的展示组件

**组件特性**:
- 支持敏感信息脱敏
- 根据用户类型显示不同内容
- 头像和基本信息展示
- 专业信息展示
- 新增真实姓名、身份证号等字段显示

### 6.4 搜索筛选组件 (SearchFilter)

**功能描述**: 订单搜索和筛选功能

**筛选条件**:
- 医院名称搜索
- 价格范围筛选
- 时间范围选择
- 订单状态筛选

### 6.5 表单组件 (FormComponents)

**功能描述**: 统一的表单组件

**组件类型**:
- Input: 文本输入
- Select: 下拉选择
- DatePicker: 日期选择
- NumberInput: 数字输入（时长改为整数）
- TextArea: 多行文本
- Upload: 文件上传

### 6.6 文件上传组件 (FileUpload)

**功能描述**: 文件上传功能

**组件特性**:
- 支持拖拽上传
- 文件类型验证
- 文件大小限制
- 上传进度显示
- 文件预览功能

```tsx
interface FileUploadProps {
  accept?: string;
  maxSize?: number;
  multiple?: boolean;
  onUpload: (files: File[]) => void;
  onError: (error: string) => void;
}
```

## 7. 状态管理设计

### 7.1 全局状态 (Context)

**用户状态**:
```tsx
interface UserState {
  user: User | null;
  userType: UserType;
  isAuthenticated: boolean;
  token: string | null;
  patientProfile?: PatientProfile;
  caregiverProfile?: CaregiverProfile;
}
```

**订单状态**:
```tsx
interface OrderState {
  orders: Order[];
  currentOrder: Order | null;
  filters: OrderFilters;
  loading: boolean;
}
```

**文件状态**:
```tsx
interface FileState {
  files: File[];
  uploading: boolean;
  uploadProgress: number;
}
```

### 7.2 服务端状态 (React Query)

**查询缓存**:
- 用户信息缓存
- 订单列表缓存
- 统计数据缓存
- 文件列表缓存

**数据同步**:
- 自动重新获取
- 乐观更新
- 错误重试

## 8. API 服务设计

### 8.1 认证服务 (AuthService)

**功能描述**: 处理用户认证相关API调用

**主要方法**:
- 微信登录
- Token刷新
- 用户信息获取
- 登出操作

### 8.2 订单服务 (OrderService)

**功能描述**: 处理订单相关API调用

**主要方法**:
- 获取订单列表
- 创建订单
- 订单详情
- 订单状态更新
- 申请接单

### 8.3 用户服务 (UserService)

**功能描述**: 处理用户信息相关API调用

**主要方法**:
- 获取用户信息
- 更新用户资料（新增字段支持）
- 上传头像
- 获取统计数据

### 8.4 文件服务 (FileService)

**功能描述**: 处理文件上传相关API调用

**主要方法**:
- 文件上传
- 获取文件信息
- 文件下载
- 文件删除

### 8.5 系统服务 (SystemService)

**功能描述**: 处理系统配置相关API调用

**主要方法**:
- 获取系统配置
- 更新系统配置
- 获取操作日志

## 9. 表单验证

### 9.1 用户资料验证

```typescript
// 患者资料验证规则
export const patientProfileSchema = yup.object({
  realName: yup.string().required('请输入真实姓名'),
  gender: yup.string().oneOf(['male', 'female', 'unknown']).required('请选择性别'),
  age: yup.number().min(1, '年龄必须大于0').max(120, '年龄不能超过120'),
  idCard: yup.string().matches(/^\d{17}[\dX]$/, '请输入正确的身份证号'),
  emergencyContact: yup.string().required('请输入紧急联系人'),
  emergencyPhone: yup.string().matches(/^1[3-9]\d{9}$/, '请输入正确的手机号'),
  diagnosis: yup.string().required('请输入诊断信息'),
  medicalHistory: yup.string(),
  allergies: yup.string(),
  specialNeeds: yup.string()
});

// 陪护资料验证规则
export const caregiverProfileSchema = yup.object({
  realName: yup.string().required('请输入真实姓名'),
  gender: yup.string().oneOf(['male', 'female', 'unknown']).required('请选择性别'),
  age: yup.number().min(18, '年龄必须大于18').max(65, '年龄不能超过65'),
  idCard: yup.string().matches(/^\d{17}[\dX]$/, '请输入正确的身份证号'),
  phone: yup.string().matches(/^1[3-9]\d{9}$/, '请输入正确的手机号'),
  address: yup.string().required('请输入地址'),
  hasCertification: yup.number().oneOf([0, 1]).required('请选择是否有资质证书'),
  certificationInfo: yup.string().when('hasCertification', {
    is: 1,
    then: yup.string().required('请输入资质证书信息')
  }),
  professionalBackground: yup.string().required('请输入专业背景'),
  workExperience: yup.number().min(0, '工作经验不能为负数'),
  serviceAreas: yup.string().required('请输入服务区域'),
  hourlyRate: yup.number().min(10, '时薪不能低于10元'),
  availableHours: yup.string().required('请输入可服务时间'),
  skills: yup.string().required('请输入专业技能')
});
```

### 9.2 订单表单验证

```typescript
export const orderSchema = yup.object({
  title: yup.string().required('请输入订单标题').max(200, '标题不能超过200字符'),
  description: yup.string().max(1000, '描述不能超过1000字符'),
  hospital: yup.string().required('请输入医院名称').max(100, '医院名称不能超过100字符'),
  address: yup.string().max(500, '地址不能超过500字符'),
  expectedTime: yup.date().required('请选择预计时间').min(new Date(), '预计时间不能早于当前时间'),
  durationHours: yup.number().required('请输入预计时长').min(1, '时长不能少于1小时').max(24, '时长不能超过24小时'),
  price: yup.number().required('请输入价格').min(10, '价格不能低于10元').max(10000, '价格不能超过10000元')
});
```

## 10. 样式设计

### 10.1 主题色彩

**主色调**:
- 主色: #1890ff
- 成功色: #52c41a
- 警告色: #fa8c16
- 错误色: #f5222d
- 信息色: #1890ff

**辅助色**:
- 背景色: #f5f5f5
- 边框色: #d9d9d9
- 文字色: #262626
- 次要文字: #8c8c8c

### 10.2 响应式设计

**断点设置**:
- 移动端: < 768px
- 平板端: 768px - 1024px
- 桌面端: > 1024px

**适配策略**:
- 移动优先设计
- 弹性布局
- 自适应组件

## 11. 性能优化

### 11.1 代码分割

- 路由级别的代码分割
- 组件级别的懒加载
- 第三方库的按需引入

### 11.2 缓存策略

- 静态资源缓存
- API响应缓存
- 组件状态缓存

### 11.3 图片优化

- 图片懒加载
- 图片压缩
- WebP格式支持

## 12. 安全考虑

### 12.1 数据安全

- 敏感信息脱敏显示
- 数据传输加密
- 本地存储安全

### 12.2 权限控制

- 路由权限控制
- 组件权限控制
- API权限验证

### 12.3 输入验证

- 前端表单验证
- XSS防护
- SQL注入防护

## 13. 测试策略

### 13.1 单元测试

- 组件测试
- 工具函数测试
- 服务层测试

### 13.2 集成测试

- API集成测试
- 用户流程测试
- 跨浏览器测试

### 13.3 E2E测试

- 关键业务流程测试
- 用户体验测试
- 性能测试 