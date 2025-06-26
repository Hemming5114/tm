import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'constants/app_constants.dart';
import 'pages/launch_screen.dart';
import 'pages/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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

// 通用提示工具类
class ToastUtil {
  static OverlayEntry? _overlayEntry;

  /// 显示成功提示
  static void showSuccess(BuildContext context, String message) {
    _showCustomToast(context, message, const Color(0xFF4CAF50), Colors.white);
  }

  /// 显示错误提示
  static void showError(BuildContext context, String message) {
    _showCustomToast(context, message, const Color(0xFFE53E3E), Colors.white);
  }

  /// 显示警告提示
  static void showWarning(BuildContext context, String message) {
    _showCustomToast(context, message, const Color(0xFFFFE04F), const Color(0xFF111111));
  }

  /// 显示信息提示
  static void showInfo(BuildContext context, String message) {
    _showCustomToast(context, message, const Color(0xFF3182CE), Colors.white);
  }

  /// 显示加载提示
  static void showLoading(BuildContext context, String message) {
    _showCustomToast(context, message, Colors.black87, Colors.white);
  }

  static void _showCustomToast(BuildContext context, String message, Color backgroundColor, Color textColor) {
    // 移除之前的提示
    _hideToast();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    // 3秒后自动隐藏
    Future.delayed(const Duration(seconds: 3), () {
      _hideToast();
    });
  }

  static void _hideToast() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

// 欢迎页面 - 用户引导和登录
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  bool _isAgreed = false;
  bool _isLoading = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    
    // 初始化抖动动画
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  // 调用智谱AI API生成用户姓名
  Future<String?> _generateUserNameWithAI() async {
    try {
      print('🤖 开始调用智谱AI API生成姓名...');
      
      final requestBody = {
        'model': 'GLM-4-Flash-250414',
        'messages': [
          {
            'role': 'user',
            'content': '''
请生成一个4-6位的中文姓名，要求：
1. 符合中文姓名规范
2. 音律优美
3. 寓意美好
4. 只返回姓名，不要其他任何文字

示例：张雨涵、李星月、王思雨
            '''
          }
        ],
        'temperature': 0.8,
      };
      
      print('📤 API请求体: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        Uri.parse('https://open.bigmodel.cn/api/paas/v4/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer 2b74dd4009944bb4a231ee9a7d50eab2.gRo4uOUiDz91hHkH',
        },
        body: jsonEncode(requestBody),
      );

      print('📥 API响应状态码: ${response.statusCode}');
      print('📥 API响应头: ${response.headers}');
      print('📥 API响应体: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ API响应解析成功: $data');
        
        final content = data['choices'][0]['message']['content'].trim();
        print('🎯 AI生成的姓名: $content');
        
        // 验证生成的姓名长度
        if (content.length > 2 && content.length <= 6) {
          print('✨ 姓名验证通过: $content');
          return content;
        } else {
          print('❌ 姓名长度不符合要求: $content');
          return null;
        }
      } else {
        print('❌ API调用失败，状态码: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('💥 API调用异常: $e');
      return null;
    }
  }

  // 创建完整用户信息
  Future<Map<String, dynamic>?> _createUserWithAI() async {
    // 先尝试用AI生成姓名
    final aiName = await _generateUserNameWithAI();
    
    // 生成其他本地信息
    final signatures = [
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
    
    final userInfo = {
      'name': aiName ?? _getRandomName(), // 如果AI生成失败，使用本地姓名
      'avatar': (Random().nextInt(20) + 1).toString(),
      'userId': (100000 + Random().nextInt(900000)).toString(),
      'gender': Random().nextBool() ? '男' : '女',
      'signature': signatures[Random().nextInt(signatures.length)],
    };
    
    print('🎭 最终用户信息: $userInfo');
    return userInfo;
  }

  // 获取随机本地姓名
  String _getRandomName() {
    final names = ['张雨涵', '李星月', '王思雨', '陈梦琪', '刘诗涵', '黄雨桐', '赵心语', '孙梦瑶', '周诗涵', '吴雨桐'];
    return names[Random().nextInt(names.length)];
  }

  // 备用用户创建方法
  Map<String, dynamic> _createFallbackUser() {
    print('🎲 使用备用方法生成用户信息...');
    
    final names = ['张雨涵', '李星月', '王思雨', '陈梦琪', '刘诗涵', '黄雨桐', '赵心语', '孙梦瑶'];
    final signatures = [
      '生活不止眼前的苟且，还有诗和远方的田野',
      '愿你三冬暖，愿你春不寒，愿你天黑有灯',
      '时光温柔，还需你懂，生活可爱，也需你宠',
      '把温柔给这个世界，把勇敢留给自己',
      '生活明朗，万物可爱，人间值得，未来可期',
      '愿所有美好如约而至，愿所有黑暗渐行渐远'
    ];
    
    final fallbackUser = {
      'name': names[Random().nextInt(names.length)],
      'avatar': (Random().nextInt(20) + 1).toString(),
      'userId': (100000 + Random().nextInt(900000)).toString(),
      'gender': Random().nextBool() ? '男' : '女',
      'signature': signatures[Random().nextInt(signatures.length)],
    };
    
    print('🎭 备用用户信息生成完成: $fallbackUser');
    return fallbackUser;
  }

  Future<void> _enterApp() async {
    if (!_isAgreed) {
      // 触发抖动动画
      _shakeController.forward().then((_) {
        _shakeController.reverse();
      });
      
      ToastUtil.showWarning(context, '请先同意用户协议和隐私授权协议');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // 显示加载提示
    ToastUtil.showLoading(context, '正在创建账户...');

    try {
      // 调用智谱AI创建用户
      final userInfo = await _createUserWithAI();
      
      if (userInfo != null) {
        // 保存用户信息到本地存储
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userName', userInfo['name']);
        await prefs.setString('userAvatar', 'user_head_icon${userInfo['avatar']}');
        await prefs.setString('userId', userInfo['userId']);
        await prefs.setString('userGender', userInfo['gender']);
        await prefs.setString('userSignature', userInfo['signature']);

        // 显示成功提示
        ToastUtil.showSuccess(context, '账户创建成功！欢迎 ${userInfo['name']}');

        // 延迟跳转，让用户看到成功提示
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          }
        });
      } else {
        throw Exception('用户创建失败');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ToastUtil.showError(context, '创建用户失败，请重试');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // 备用渐变背景
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A90E2),
              Color(0xFF87CEEB),
              Color(0xFFF0F8FF),
            ],
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            // 如果有背景图片，使用DecorationImage
            image: DecorationImage(
              image: AssetImage('assets/images/bg_login_icon.png'),
              fit: BoxFit.cover,
              onError: null, // 如果图片加载失败，将显示渐变背景
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // 左上角标题区域
                Padding(
                  padding: const EdgeInsets.only(left: 36, top: 100),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 标题
                          const Text(
                            '甜梦',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // 副标题
                          const Text(
                            '记录美好旅行时光',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                
                const Spacer(flex: 3),
                
                // 进入App按钮
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _enterApp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              '进入App',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // 同意协议 - 添加抖动动画
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value * 
                          ((_shakeController.value * 4).round() % 2 == 0 ? 1 : -1), 0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isAgreed = !_isAgreed;
                                });
                              },
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  color: _isAgreed ? Colors.white : Colors.transparent,
                                ),
                                child: _isAgreed
                                    ? const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Color(0xFF4A90E2),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                  children: [
                                    TextSpan(text: '我已阅读并同意'),
                                    TextSpan(
                                      text: '《用户协议》',
                                      style: TextStyle(
                                        color: Color(0xFF28D9DE),
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    TextSpan(text: '和'),
                                    TextSpan(
                                      text: '《隐私授权协议》',
                                      style: TextStyle(
                                        color: Color(0xFF28D9DE),
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 登录注册页面
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();

  Future<void> _handleAuth() async {
    // 简单的登录逻辑，实际项目中需要调用API
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      ToastUtil.showWarning(context, '请填写完整信息');
      return;
    }

    // 保存登录状态
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userPhone', _phoneController.text);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            
            // 标题
            Text(
              _isLogin ? '登录' : '注册',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111111),
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              _isLogin ? '欢迎回来' : '创建你的账户',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // 手机号输入框
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: '手机号',
                hintText: '请输入手机号',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFFE04F)),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 密码输入框
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: '密码',
                hintText: '请输入密码',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFFE04F)),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 登录/注册按钮
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleAuth,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFE04F),
                  foregroundColor: const Color(0xFF111111),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _isLogin ? '登录' : '注册',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 切换登录/注册
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(
                  _isLogin ? '没有账号？去注册' : '已有账号？去登录',
                  style: const TextStyle(
                    color: Color(0xFF666666),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
