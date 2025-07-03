import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/app_constants.dart';

/// AI服务类，处理智谱API调用
class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  /// 获取AI回复
  Future<String> getAiResponse(String message) async {
    try {
      // 构建请求头
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AppConstants.zhipuApiKey}',
      };

      // 构建请求体
      final body = jsonEncode({
        'model': AppConstants.zhipuModel,
        'messages': [
          {
            'role': 'system',
            'content': '你是一个专业的旅游助手，名叫"旅行精灵"。请为用户提供旅游相关的建议、攻略、推荐等信息。回答要专业、实用、友好，并且要符合旅游场景。请用中文回答，回答要简洁明了，突出重点。',
          },
          {
            'role': 'user',
            'content': message,
          }
        ],
        'max_tokens': 1024,
        'temperature': 0.7,
        'top_p': 0.8,
        'stream': false,
      });

      print('发送AI请求: $message');

      // 发送请求
      final response = await http.post(
        Uri.parse(AppConstants.zhipuApiUrl),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 30));

      print('AI响应状态码: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'];
        
        if (content != null && content.isNotEmpty) {
          print('AI回复成功: ${content.substring(0, content.length > 50 ? 50 : content.length)}...');
          return content;
        } else {
          throw Exception('AI回复内容为空');
        }
      } else {
        print('智谱API错误: ${response.statusCode} - ${response.body}');
        throw Exception('AI服务暂时不可用，请稍后重试');
      }
    } catch (e) {
      print('智谱API调用失败: $e');
      
      // 如果API调用失败，返回友好的错误提示
      if (e.toString().contains('timeout')) {
        return '抱歉，网络连接超时，请检查网络后重试。';
      } else if (e.toString().contains('API')) {
        return 'AI服务暂时不可用，请稍后重试。如果问题持续存在，请联系客服。';
      } else {
        return '抱歉，我暂时无法回答您的问题，请稍后重试。';
      }
    }
  }

  /// 测试AI连接
  Future<bool> testConnection() async {
    try {
      final response = await getAiResponse('你好');
      return response.isNotEmpty && !response.contains('抱歉');
    } catch (e) {
      print('AI连接测试失败: $e');
      return false;
    }
  }
} 