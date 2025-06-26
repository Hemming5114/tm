import 'package:flutter/material.dart';

class AppConstants {
  // 应用信息
  static const String appName = '甜梦';
  static const String appSlogan = '记录美好旅行时光';
  
  // API配置
  static const String zhipuApiKey = '2b74dd4009944bb4a231ee9a7d50eab2.gRo4uOUiDz91hHkH';
  static const String zhipuApiUrl = 'https://open.bigmodel.cn/api/paas/v4/chat/completions';
  static const String zhipuModel = 'GLM-4-Flash-250414';
  
  // 主题颜色 - 甜梦主题（梦幻粉紫色系）
  static const Color primaryColor = Color(0xFFFF9EC7); // 甜美粉色
  static const Color secondaryColor = Color(0xFFB794F6); // 梦幻紫色
  static const Color accentColor = Color(0xFFFED7E2); // 淡粉色
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textTertiary = Color(0xFF718096);
  static const Color agreementColor = Color(0xFF9F7AEA);
  
  // 提示颜色
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color warningColor = Color(0xFFFFE04F);
  static const Color infoColor = Color(0xFF3182CE);
  
  // 本地存储键
  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyUserName = 'userName';
  static const String keyUserAvatar = 'userAvatar';
  static const String keyUserId = 'userId';
  static const String keyUserGender = 'userGender';
  static const String keyUserSignature = 'userSignature';
  
  // 资源路径
  static const String backgroundImage = 'assets/images/launch.png';
  static const String appIcon = 'assets/icons/icon.png';
  static const String bannerImage = 'assets/images/baner/banner_icon.png';
  
  // 默认签名库
  static const List<String> defaultSignatures = [
    '生活不止眼前的苟且，还有诗和远方的田野',
    '愿你三冬暖，愿你春不寒，愿你天黑有灯',
    '时光温柔，还需你懂，生活可爱，也需你宠',
    '把温柔给这个世界，把勇敢留给自己',
    '生活明朗，万物可爱，人间值得，未来可期',
    '愿所有美好如约而至，愿所有黑暗渐行渐远',
    '心有繁花似锦，眼有山河辽阔',
    '愿你历尽千帆，归来仍是少年',
    '在最美的年华里，做最好的自己',
    '温柔半两，从容一生'
  ];
  
  // 默认姓名库
  static const List<String> defaultNames = [
    '张雨涵', '李星月', '王思雨', '陈梦琪', '刘诗涵', 
    '黄雨桐', '赵心语', '孙梦瑶', '周诗涵', '吴雨桐'
  ];
} 