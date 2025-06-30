import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../utils/storage_util.dart';
import 'main_screen.dart';
import 'splash_screen.dart';

/// 启动页面 - 展示launch.png
class LaunchScreen extends StatefulWidget {
  const LaunchScreen({Key? key}) : super(key: key);

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// 初始化应用
  Future<void> _initializeApp() async {
    // 并行执行启动画面显示和网络检查
    await Future.wait([
      Future.delayed(const Duration(seconds: 2)), // 显示启动画面2秒
      _checkNetworkPermission(), // 检查网络权限并调用智谱接口
    ]);
    
    try {
      // 检查Keychain中的用户信息
      final userInfo = await StorageUtil.getUserInfo();
      
      if (mounted) {
        if (userInfo != null && userInfo.id.isNotEmpty) {
          print('启动页面：从Keychain获取到用户信息，用户ID: ${userInfo.id}');
          // 有用户信息，直接进入主页
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          print('启动页面：Keychain中没有用户信息，跳转到欢迎页面');
          // 没有用户信息，进入欢迎页面
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const SplashScreen()),
          );
        }
      }
    } catch (e) {
      print('启动页面：获取用户信息失败: $e');
      if (mounted) {
        // 获取失败，进入欢迎页面
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SplashScreen()),
        );
      }
    }
  }

  /// 检查网络权限并调用智谱接口
  Future<void> _checkNetworkPermission() async {
    try {
      print('🌐 启动页面：开始网络权限检查，调用智谱接口...');
      
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AppConstants.zhipuApiKey}',
      };

      final body = {
        'model': AppConstants.zhipuModel,
        'messages': [
          {
            'role': 'user',
            'content': '请简单回复"网络连接正常"'
          }
        ],
        'temperature': 0.3,
      };

      // 设置较短的超时时间，因为这只是为了触发网络权限弹框
      final response = await http.post(
        Uri.parse(AppConstants.zhipuApiUrl),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        print('✅ 启动页面：智谱接口调用成功，网络权限已获取');
      } else {
        print('⚠️ 启动页面：智谱接口调用失败，状态码: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ 启动页面：网络权限检查异常 (这是正常的，已触发权限弹框): $e');
      // 不做任何处理，因为这个异常通常表示网络权限弹框正在显示
      // 或者网络确实不可用，但这不应该阻止应用继续启动
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/launch.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}