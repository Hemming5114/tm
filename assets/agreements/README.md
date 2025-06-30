# 甜梦应用协议文档

本目录包含甜梦应用的法律协议文档，供在应用内展示和用户阅读。

## 文档列表

### 1. user_agreement.md - 用户协议
包含以下主要内容：
- 服务描述和使用条款
- 用户行为规范
- 知识产权声明
- 免责声明
- 争议解决等

### 2. privacy_policy.md - 隐私政策
包含以下主要内容：
- 个人信息收集和使用
- 信息保护措施
- 用户权利说明
- 儿童隐私保护
- 数据安全保障等

## 如何在应用中使用

### 1. 在用户注册/登录时展示
```dart
// 示例：在注册页面添加协议链接
Text('点击注册即表示您同意'),
GestureDetector(
  onTap: () {
    // 展示用户协议
    showAgreementDialog(context, 'user_agreement');
  },
  child: Text('《用户协议》', style: TextStyle(color: Colors.blue)),
),
Text('和'),
GestureDetector(
  onTap: () {
    // 展示隐私政策
    showAgreementDialog(context, 'privacy_policy');
  },
  child: Text('《隐私政策》', style: TextStyle(color: Colors.blue)),
),
```

### 2. 在设置页面提供访问入口
```dart
// 示例：在设置页面添加协议选项
ListTile(
  title: Text('用户协议'),
  trailing: Icon(Icons.arrow_forward_ios),
  onTap: () {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => AgreementPage(type: 'user_agreement'),
    ));
  },
),
ListTile(
  title: Text('隐私政策'),
  trailing: Icon(Icons.arrow_forward_ios),
  onTap: () {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => AgreementPage(type: 'privacy_policy'),
    ));
  },
),
```

### 3. 读取协议内容的示例代码
```dart
import 'package:flutter/services.dart';

Future<String> loadAgreement(String agreementType) async {
  try {
    String content = await rootBundle.loadString('assets/agreements/$agreementType.md');
    return content;
  } catch (e) {
    print('加载协议失败: $e');
    return '协议内容加载失败，请稍后重试。';
  }
}
```

## 重要提醒

### 法律合规
- 这些协议是根据当前中国法律法规制定的模板
- 实际使用前建议咨询法律专业人士
- 根据具体业务需求可能需要调整部分条款

### 更新维护
- 协议文档的生效日期和更新日期需要及时维护
- 重大变更时需要在应用内通知用户
- 建议定期审查协议内容的合规性

### 用户体验
- 协议内容较长，建议提供搜索和目录功能
- 重要条款可以高亮显示
- 提供便捷的联系方式供用户咨询

## 技术实现建议

### 1. 创建协议展示页面
建议创建一个专门的页面来展示协议内容，支持：
- Markdown渲染
- 文本搜索
- 字体大小调节
- 深色/浅色主题切换

### 2. 协议同意状态管理
建议在用户首次使用应用时记录协议同意状态：
```dart
// 保存协议同意状态
await StorageUtil.setBool('user_agreement_accepted', true);
await StorageUtil.setBool('privacy_policy_accepted', true);
await StorageUtil.setString('agreement_version', '1.0.0');
```

### 3. 协议更新提醒
当协议更新时，应该：
- 检查用户已同意的协议版本
- 如果有重大更新，要求用户重新同意
- 记录新的协议版本和同意时间

## 联系信息模板

协议中的联系信息需要替换为实际信息：
- 邮箱地址：support@sweetdream.com → 实际邮箱
- 客服电话：400-XXX-XXXX → 实际电话
- 公司信息：需要添加实际的公司名称和地址

---

**注意：本协议文档仅为模板，实际使用前请根据具体业务需求和法律要求进行调整。** 