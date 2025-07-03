import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../utils/ai_service.dart';
import '../utils/toast_util.dart';

/// AI测试页面
class AiTestPage extends StatefulWidget {
  const AiTestPage({Key? key}) : super(key: key);

  @override
  State<AiTestPage> createState() => _AiTestPageState();
}

class _AiTestPageState extends State<AiTestPage> {
  final TextEditingController _textController = TextEditingController();
  String _response = '';
  bool _isLoading = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// 测试连接
  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final connected = await AiService().testConnection();
      setState(() {
        _isConnected = connected;
        _isLoading = false;
      });

      if (connected) {
        ToastUtil.showSuccess(context, 'AI服务连接正常');
      } else {
        ToastUtil.showError(context, 'AI服务连接失败');
      }
    } catch (e) {
      setState(() {
        _isConnected = false;
        _isLoading = false;
      });
      ToastUtil.showError(context, '连接测试失败: $e');
    }
  }

  /// 发送消息
  Future<void> _sendMessage() async {
    final message = _textController.text.trim();
    if (message.isEmpty || _isLoading) return;

    setState(() {
      _isLoading = true;
      _response = '';
    });

    try {
      final response = await AiService().getAiResponse(message);
      setState(() {
        _response = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _response = '错误: $e';
        _isLoading = false;
      });
      ToastUtil.showError(context, '发送失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI服务测试'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _testConnection,
            icon: Icon(_isConnected ? Icons.check_circle : Icons.error),
            color: _isConnected ? Colors.green : Colors.red,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // API配置信息
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API配置信息',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('模型: ${AppConstants.zhipuModel}'),
                    Text('API地址: ${AppConstants.zhipuApiUrl}'),
                    Text('API Key: ${AppConstants.zhipuApiKey.substring(0, 10)}...'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _isConnected ? Icons.check_circle : Icons.error,
                          color: _isConnected ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isConnected ? '连接正常' : '连接失败',
                          style: TextStyle(
                            color: _isConnected ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 输入区域
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: '输入测试消息...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  onPressed: _sendMessage,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                ),
              ),
              maxLines: 3,
              onSubmitted: (_) => _sendMessage(),
            ),
            
            const SizedBox(height: 16),
            
            // 响应区域
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI响应',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              _response.isEmpty ? '等待响应...' : _response,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ],
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