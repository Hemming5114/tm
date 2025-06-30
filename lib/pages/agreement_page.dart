import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 协议展示页面
class AgreementPage extends StatefulWidget {
  final String agreementType; // 'user_agreement' 或 'privacy_policy'
  final String title; // 页面标题

  const AgreementPage({
    Key? key,
    required this.agreementType,
    required this.title,
  }) : super(key: key);

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  String _content = '';
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadAgreementContent();
  }

  /// 加载协议内容
  Future<void> _loadAgreementContent() async {
    try {
      String content = await rootBundle.loadString(
        'assets/agreements/${widget.agreementType}.md'
      );
      
      // 简单的markdown转换（去掉markdown语法，保留基本格式）
      content = _convertMarkdownToText(content);
      
      setState(() {
        _content = content;
        _isLoading = false;
      });
    } catch (e) {
      print('加载协议失败: $e');
      setState(() {
        _content = '协议内容加载失败，请稍后重试。\n\n如有疑问，请联系客服。';
        _isLoading = false;
      });
    }
  }

  /// 简单的Markdown转文本转换
  String _convertMarkdownToText(String markdown) {
    String result = markdown;
    
    // 移除markdown标记，保留文本内容
    result = result.replaceAll(RegExp(r'^#{1,6}\s+'), ''); // 移除标题标记
    result = result.replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1'); // 移除粗体标记
    result = result.replaceAll(RegExp(r'\*(.*?)\*'), r'$1'); // 移除斜体标记
    result = result.replaceAll(RegExp(r'`(.*?)`'), r'$1'); // 移除代码标记
    result = result.replaceAll(RegExp(r'\[(.*?)\]\(.*?\)'), r'$1'); // 移除链接标记，保留文本
    result = result.replaceAll(RegExp(r'^-\s+', multiLine: true), '• '); // 转换列表项
    result = result.replaceAll(RegExp(r'^\s*$', multiLine: true), ''); // 移除空行
    result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n'); // 合并多个换行
    
    return result.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF28D9DE),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '正在加载协议内容...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // 顶部提示信息
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF28D9DE).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF28D9DE).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: const Color(0xFF28D9DE),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.agreementType == 'user_agreement' 
                              ? '请仔细阅读用户协议的各项条款'
                              : '请了解我们如何收集和使用您的个人信息',
                          style: TextStyle(
                            color: const Color(0xFF28D9DE),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 协议内容
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _content,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // 底部操作区域
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 联系我们信息
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '如有疑问，请联系我们：',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '邮箱：support@sweetdream.com',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const Text(
                              '或通过应用内意见反馈功能联系我们',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 确认按钮
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF28D9DE),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(23),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            '我已阅读',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
} 