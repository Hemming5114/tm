import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../utils/storage_util.dart';
import '../utils/toast_util.dart';

/// AI旅游助手页面
class AiTravelAssistantPage extends StatefulWidget {
  const AiTravelAssistantPage({Key? key}) : super(key: key);

  @override
  State<AiTravelAssistantPage> createState() => _AiTravelAssistantPageState();
}

class _AiTravelAssistantPageState extends State<AiTravelAssistantPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  UserModel? _userInfo;
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 加载用户信息
  Future<void> _loadUserInfo() async {
    try {
      final userInfo = await StorageUtil.getUserInfo();
      if (mounted) {
        setState(() {
          _userInfo = userInfo;
        });
      }
    } catch (e) {
      print('加载用户信息失败: $e');
    }
  }

  /// 添加欢迎消息
  void _addWelcomeMessage() {
    _messages.add({
      'type': 'ai',
      'content': '你好！我是你的专属AI旅游助手"旅行精灵"🧚‍♀️\n\n我可以为你提供：\n• 旅游目的地推荐\n• 行程规划建议\n• 美食攻略\n• 交通住宿信息\n• 旅行小贴士\n\n每次问答消耗1金币，VIP会员免费。\n有什么想了解的吗？',
      'timestamp': DateTime.now(),
    });
  }

  /// 发送消息
  Future<void> _sendMessage() async {
    final message = _textController.text.trim();
    if (message.isEmpty || _isLoading) return;

    // 检查用户金币或VIP状态
    if (!_isUserVip() && (_userInfo?.coins ?? 0) < 1) {
      ToastUtil.showError('金币不足，请先充值');
      return;
    }

    // 添加用户消息
    _messages.add({
      'type': 'user',
      'content': message,
      'timestamp': DateTime.now(),
    });

    _textController.clear();
    setState(() {
      _isLoading = true;
    });

    // 滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    try {
      // 扣除金币（非VIP用户）
      if (!_isUserVip()) {
        await _deductCoins(1);
      }

      // 调用AI接口获取回复
      final aiResponse = await _getAiResponse(message);
      
      // 添加AI回复
      _messages.add({
        'type': 'ai',
        'content': aiResponse,
        'timestamp': DateTime.now(),
      });
    } catch (e) {
      // 如果失败，退还金币
      if (!_isUserVip()) {
        await _addCoins(1);
      }
      ToastUtil.showError('发送失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }

    // 滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  /// 检查用户是否为VIP
  bool _isUserVip() {
    if (_userInfo?.memberExpiry.isEmpty ?? true) return false;
    
    final expiryDate = DateTime.tryParse(_userInfo!.memberExpiry);
    if (expiryDate == null) return false;
    
    return expiryDate.isAfter(DateTime.now());
  }

  /// 扣除金币
  Future<void> _deductCoins(int amount) async {
    if (_userInfo == null) return;

    final updatedUser = _userInfo!.copyWith(
      coins: _userInfo!.coins - amount,
    );

    await StorageUtil.saveUserInfo(updatedUser);
    
    if (mounted) {
      setState(() {
        _userInfo = updatedUser;
      });
    }
  }

  /// 添加金币
  Future<void> _addCoins(int amount) async {
    if (_userInfo == null) return;

    final updatedUser = _userInfo!.copyWith(
      coins: _userInfo!.coins + amount,
    );

    await StorageUtil.saveUserInfo(updatedUser);
    
    if (mounted) {
      setState(() {
        _userInfo = updatedUser;
      });
    }
  }

  /// 获取AI回复
  Future<String> _getAiResponse(String message) async {
    // 这里应该调用智谱AI接口
    // 目前使用模拟回复
    await Future.delayed(const Duration(seconds: 1));
    
    // 模拟AI回复
    final responses = [
      '根据你的问题，我建议你可以考虑以下几个旅游目的地...',
      '这是一个很好的问题！让我为你详细介绍一下...',
      '基于你的需求，我推荐以下行程安排...',
      '关于这个问题，我有以下建议供你参考...',
      '这是一个热门话题，让我为你提供一些实用的建议...',
    ];
    
    return responses[DateTime.now().millisecond % responses.length];
  }

  /// 滚动到底部
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// 格式化时间
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '旅行精灵',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        actions: [
          // 显示金币或VIP状态
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isUserVip())
                  const Icon(
                    Icons.workspace_premium,
                    color: Colors.amber,
                    size: 16,
                  )
                else
                  const Icon(
                    Icons.monetization_on,
                    color: Colors.amber,
                    size: 16,
                  ),
                const SizedBox(width: 4),
                Text(
                  _isUserVip() ? 'VIP' : '${_userInfo?.coins ?? 0}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 消息列表
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppConstants.primaryColor,
                    Color(0xFFE8F5E8),
                  ],
                  stops: [0.0, 0.3],
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    // 加载指示器
                    return Container(
                      margin: const EdgeInsets.only(top: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppConstants.primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '正在思考...',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final message = _messages[index];
                  final isUser = message['type'] == 'user';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: isUser 
                          ? MainAxisAlignment.end 
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser) ...[
                          // AI头像
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppConstants.primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        
                        // 消息内容
                        Flexible(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUser ? AppConstants.primaryColor : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message['content'],
                                  style: TextStyle(
                                    color: isUser ? Colors.white : Colors.black87,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTime(message['timestamp']),
                                  style: TextStyle(
                                    color: isUser 
                                        ? Colors.white.withOpacity(0.7)
                                        : Colors.grey[500],
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        if (isUser) const SizedBox(width: 44),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          
          // 输入区域
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: '输入你的旅游问题...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
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