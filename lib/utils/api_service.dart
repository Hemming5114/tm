import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/user_model.dart';

/// API服务类
class ApiService {
  /// 生成用户信息
  static Future<UserModel> generateUserInfo() async {
    // 使用AI生成姓名
    final aiName = await _generateNameWithAI();
    
    // 生成随机用户信息
    final random = Random();
    final avatarNum = random.nextInt(10) + 11; // 11-20范围
    final avatar = 'user_head_$avatarNum.jpg';
    final userId = (100000 + random.nextInt(900000)).toString();
    final gender = random.nextBool() ? '男' : '女';
    final signature = AppConstants.defaultSignatures[random.nextInt(AppConstants.defaultSignatures.length)];
    
    // 如果AI生成失败，使用默认姓名
    final name = aiName ?? AppConstants.defaultNames[random.nextInt(AppConstants.defaultNames.length)];
    
    final userInfo = UserModel(
      id: userId,
      name: name,
      gender: gender,
      avatar: avatar,
      coins: 100 + random.nextInt(500), // 随机金币数100-599
      memberExpiry: DateTime.now().add(Duration(days: 30 + random.nextInt(335))).toIso8601String(), // 随机会员时长30-365天
      signature: signature,
      createdAt: DateTime.now().toIso8601String(),
    );
    
    print('🎭 最终用户信息: ${userInfo.toMap()}');
    return userInfo;
  }

  /// 使用AI生成姓名
  static Future<String?> _generateNameWithAI() async {
    try {
      print('🤖 开始调用智谱AI API生成姓名...');
      
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AppConstants.zhipuApiKey}',
      };

      final body = {
        'model': AppConstants.zhipuModel,
        'messages': [
          {
            'role': 'user',
            'content': '''请生成一个4-6位的中文姓名，要求：
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

      print('📤 API请求体: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(AppConstants.zhipuApiUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      print('📥 API响应状态码: ${response.statusCode}');
      print('📥 API响应头: ${response.headers}');
      print('📥 API响应体: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('✅ API响应解析成功: $responseData');
        
        final content = responseData['choices'][0]['message']['content'].toString().trim();
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
      print('❌ API调用异常: $e');
      return null;
    }
  }
} 