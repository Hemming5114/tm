import 'dart:convert';
import 'dart:io';

void main() async {
  print('开始测试智谱API...');
  
  // API配置
  const apiKey = '2b74dd4009944bb4a231ee9a7d50eab2.gRo4uOUiDz91hHkH';
  const apiUrl = 'https://open.bigmodel.cn/api/paas/v4/chat/completions';
  const model = 'GLM-4-Flash-250414';
  
  try {
    // 创建HTTP客户端
    final client = HttpClient();
    
    // 构建请求
    final request = await client.postUrl(Uri.parse(apiUrl));
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Authorization', 'Bearer $apiKey');
    
    // 构建请求体
    final body = {
      'model': model,
      'messages': [
        {
          'role': 'system',
          'content': '你是一个专业的旅游助手，名叫"旅行精灵"。请为用户提供旅游相关的建议、攻略、推荐等信息。回答要专业、实用、友好，并且要符合旅游场景。请用中文回答，回答要简洁明了，突出重点。',
        },
        {
          'role': 'user',
          'content': '你好，请推荐一个适合情侣旅游的地方',
        }
      ],
      'max_tokens': 1024,
      'temperature': 0.7,
      'top_p': 0.8,
      'stream': false,
    };
    
    final jsonBody = jsonEncode(body);
    print('请求体: $jsonBody');
    
    request.write(jsonBody);
    
    print('发送请求...');
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('响应状态码: ${response.statusCode}');
    print('响应内容: $responseBody');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      final content = data['choices']?[0]?['message']?['content'];
      
      if (content != null && content.isNotEmpty) {
        print('\n✅ AI回复成功:');
        print(content);
      } else {
        print('\n❌ AI回复内容为空');
      }
    } else {
      print('\n❌ API调用失败');
    }
    
  } catch (e) {
    print('\n❌ 测试失败: $e');
  } finally {
    exit(0);
  }
} 