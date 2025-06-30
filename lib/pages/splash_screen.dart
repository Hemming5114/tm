import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'main_screen.dart';
import 'agreement_page.dart';

/// 启动页面
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  bool _isAgreed = false;
  bool _isLoading = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // 个性签名列表
  final List<String> _signatures = [
    '生活不止眼前的苟且，还有诗和远方',
    '愿你走出半生，归来仍是少年',
    '世界那么大，我想去看看',
    '心中有梦，脚下有路',
    '做自己的太阳，无需凭借谁的光',
    '每一次出发，都是为了更好的回来',
    '用脚步丈量世界，用心灵感受生活',
    '旅行的意义不在终点，而在路上',
    '保持热爱，奔赴山海',
    '人生如旅，我亦是行人',
    '山河远阔，人间烟火',
    '慢品人间烟火色，闲观万事岁月长',
    '愿所有美好如期而至',
    '温柔半两，从容一生',
    '心怀浪漫宇宙，也珍惜人间日常',
    '把生活过成诗，把日子过成歌',
    '星光不问赶路人，时光不负有心人',
    '愿你眼中总有光芒，活成你想要的模样',
    '用心感受每一个当下',
    '简单生活，快乐至上'
  ];

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

  /// 调用智谱AI生成用户姓名
  Future<String?> _generateUserNameWithAI() async {
    try {
      final requestBody = {
        'model': 'GLM-4-Flash',
        'messages': [
          {
            'role': 'user',
            'content': '''
请生成一个3-10位的中文姓名，要求：
1. 符合中文姓名规范
2. 音律优美
3. 寓意美好
4. 只返回姓名，不要其他任何文字

示例：可乐里的小公主、月亮姐姐、jessi在路上、十七号公路
            '''
          }
        ],
        'temperature': 0.8,
      };
      
      final response = await http.post(
        Uri.parse('https://open.bigmodel.cn/api/paas/v4/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer 2b74dd4009944bb4a231ee9a7d50eab2.gRo4uOUiDz91hHkH',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          String generatedName = data['choices'][0]['message']['content'].trim();
          // 确保姓名长度在3-10位之间
          if (generatedName.length >= 3 && generatedName.length <= 10) {
            return generatedName;
          }
        }
      }
    } catch (e) {
      print('AI生成姓名失败: $e');
    }
    
    // 如果AI生成失败，使用备用姓名
    final fallbackNames = ['张雨涵', '李星月', '王思雨', '陈梦琪', '刘诗涵', '杨雨薇', '黄思雨', '赵梦瑶', '孙雨晴', '周思涵'];
    return fallbackNames[Random().nextInt(fallbackNames.length)];
  }

  /// 创建用户
  Future<void> _createUser() async {
    if (!_isAgreed) {
      // 触发抖动动画
      _shakeController.forward().then((_) {
        _shakeController.reverse();
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final random = Random();
      
      // 生成用户信息
      final userName = await _generateUserNameWithAI() ?? '甜梦用户';
      final gender = random.nextBool() ? '男' : '女';
      final userId = 'user_${random.nextInt(900000) + 100000}'; // 6位随机数
      final userAvatar = 'user_head_${random.nextInt(10) + 11}.jpg'; // 11-20范围
      final userCoins = random.nextInt(9000) + 1000; // 4位随机数
      
      // 生成会员到期时间（未来1-365天）
      final memberExpiry = DateTime.now().add(Duration(days: random.nextInt(365) + 1));
      
      // 随机选择个性签名
      final signature = _signatures[random.nextInt(_signatures.length)];

      // 创建用户数据
      final userData = {
        'id': userId,
        'name': userName,
        'gender': gender,
        'avatar': userAvatar,
        'coins': userCoins,
        'memberExpiry': memberExpiry.toIso8601String(),
        'signature': signature,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // 保存到本地存储
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userData', jsonEncode(userData));
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userPhone', userId); // 使用userId作为标识

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      print('创建用户失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('创建用户失败，请重试'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 显示用户协议
  void _showUserAgreement() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AgreementPage(
          agreementType: 'user_agreement',
          title: '用户协议',
        ),
      ),
    );
  }

  /// 显示隐私授权协议
  void _showPrivacyPolicy() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AgreementPage(
          agreementType: 'privacy_policy',
          title: '隐私政策',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_login_icon.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 左上角标题
              Padding(
                padding: const EdgeInsets.only(left: 36, top: 50),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题
                      const Text(
                        '翻山 悦己',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 4,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // 副标题
                      const Text(
                        '永远热烈，保持快乐',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          letterSpacing: 1,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // 底部区域
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    // 进入App按钮
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createUser,
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
                    
                    const SizedBox(height: 20),
                    
                    // 同意协议 - 添加抖动动画
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_shakeAnimation.value * 
                              ((_shakeController.value * 4).round() % 2 == 0 ? 1 : -1), 0),
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
                                          color: Colors.black,
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                    children: [
                                      const TextSpan(text: '我已阅读并同意'),
                                      WidgetSpan(
                                        child: GestureDetector(
                                          onTap: _showUserAgreement,
                                          child: const Text(
                                            '《用户协议》',
                                            style: TextStyle(
                                              color: Color(0xFF28D9DE),
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.underline,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const TextSpan(text: '和'),
                                      WidgetSpan(
                                        child: GestureDetector(
                                          onTap: _showPrivacyPolicy,
                                          child: const Text(
                                            '《隐私授权协议》',
                                            style: TextStyle(
                                              color: Color(0xFF28D9DE),
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.underline,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
} 