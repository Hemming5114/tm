import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants/app_constants.dart';
import 'pages/launch_screen.dart';
import 'utils/message_service.dart';
import 'utils/blacklist_service.dart';
import 'utils/favorite_service.dart';
import 'utils/report_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置状态栏样式为黑色字体
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));
  
  // 初始化消息服务
  await MessageService.instance.initialize();
  
  // 初始化黑名单服务
  await BlacklistService.instance.initialize();
  
  // 初始化收藏服务
  await FavoriteService.instance.initialize();
  
  // 初始化举报服务
  await ReportService.instance.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        primaryColor: AppConstants.primaryColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'PingFang SC',
      ),
      home: const LaunchScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
