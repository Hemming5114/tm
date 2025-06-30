import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../models/message_model.dart';
import '../models/travel_blogger.dart';
import '../utils/message_service.dart';
import '../utils/blacklist_service.dart';
import 'video_call_page.dart';

/// 聊天详情页面
class ChatPage extends StatefulWidget {
  final ChatConversation conversation;

  const ChatPage({
    Key? key,
    required this.conversation,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MessageService _messageService = MessageService.instance;
  late ChatConversation _conversation;
  bool _isSending = false;
  double _keyboardHeight = 0.0;

  @override
  void initState() {
    super.initState();
    _conversation = widget.conversation;
    _messageService.addListener(_onMessageServiceChanged);
    
    // 延迟滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _messageService.removeListener(_onMessageServiceChanged);
    super.dispose();
  }

  void _onMessageServiceChanged() {
    if (mounted) {
      // 更新会话信息
      final updatedConversation = _messageService.getConversation(_conversation.id);
      if (updatedConversation != null) {
        setState(() {
          _conversation = updatedConversation;
        });
        
        // 如果有新消息，滚动到底部
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // 使用更长的延迟确保ListView完成布局调整
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients && mounted) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 监听键盘状态变化
    final currentKeyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    if (currentKeyboardHeight != _keyboardHeight) {
      _keyboardHeight = currentKeyboardHeight;
      // 键盘弹起时延迟滚动到底部
      if (currentKeyboardHeight > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    }
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _conversation.userName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              _handleMenuAction(value);
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.report, color: Colors.red),
                    SizedBox(width: 8),
                    Text('举报'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block, color: Colors.red),
                    SizedBox(width: 8),
                    Text('拉黑'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // 点击空白区域收起键盘
          FocusScope.of(context).unfocus();
        },
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(_conversation.userAvatar), // 使用对方用户头像作为背景
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              // 消息列表
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 60,
                    left: 16,
                    right: 16,
                    bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  itemCount: _conversation.messages.length,
                  itemBuilder: (context, index) => _buildMessageItem(
                    _conversation.messages[index],
                    index,
                  ),
                ),
              ),
              
              // 输入框
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  /// 处理菜单操作
  void _handleMenuAction(String action) {
    switch (action) {
      case 'report':
        _showReportDialog();
        break;
      case 'block':
        _showBlockDialog();
        break;
    }
  }

  /// 显示举报对话框
  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('举报用户'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('垃圾信息'),
                onTap: () => _submitReport('垃圾信息'),
              ),
              ListTile(
                title: const Text('不当内容'),
                onTap: () => _submitReport('不当内容'),
              ),
              ListTile(
                title: const Text('虚假信息'),
                onTap: () => _submitReport('虚假信息'),
              ),
              ListTile(
                title: const Text('其他'),
                onTap: () => _submitReport('其他'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  /// 显示拉黑对话框
  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('拉黑用户'),
          content: Text('确定要拉黑 ${_conversation.userName} 吗？拉黑后将不再看到该用户的内容。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _blockUser();
              },
              child: const Text('确定', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  /// 提交举报
  void _submitReport(String reason) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('举报已提交：$reason'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// 拉黑用户
  Future<void> _blockUser() async {
    try {
      // 创建临时TravelBlogger对象用于拉黑
      final blogger = TravelBlogger(
        id: int.tryParse(_conversation.userId) ?? 0,
        name: _conversation.userName,
        avatar: _conversation.userAvatar,
        fans: 0,
        follows: 0,
        bio: '',
        tags: [],
        gender: '',
        posts: [],
      );
      
      final success = await BlacklistService.instance.blockUser(blogger);
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已拉黑 ${_conversation.userName}'),
              backgroundColor: Colors.red,
            ),
          );
          
          // 返回主页
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('拉黑失败，请重试'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('拉黑失败，请重试'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 构建消息项
  Widget _buildMessageItem(ChatMessage message, int index) {
    final isUser = message.sender == MessageSender.user;
    final isSystem = message.sender == MessageSender.system;
    final showTime = _shouldShowTime(index);
    
    return Column(
      children: [
        // 时间分隔
        if (showTime)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _formatMessageTime(message.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
        
        // 系统消息
        if (isSystem)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message.content,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        
        // 用户和AI消息
        if (!isSystem)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: isUser 
                  ? MainAxisAlignment.end 
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 对方消息布局
                if (!isUser) ...[
                  const SizedBox(width: 12), // 头像左间距12
                  ClipOval(
                    child: Image.asset(
                      _conversation.userAvatar,
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: AppConstants.primaryColor,
                            size: 24,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12), // 内容左距离头像12
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(right: 60), // 内容距离右边最小60
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient( // 对方消息用渐变
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFFF9FB50), // 左边黄色
                            Color(0xFF8DFAD7), // 右边绿色
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                          bottomLeft: Radius.circular(4),
                          bottomRight: Radius.circular(18),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: message.isLoading
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  message.content,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              message.content,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                height: 1.4,
                              ),
                            ),
                    ),
                  ),
                ],
                
                // 自己消息布局
                if (isUser) ...[
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(left: 60), // 内容距离左边最小60
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white, // 自己的消息纯白色
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                          bottomLeft: Radius.circular(18),
                          bottomRight: Radius.circular(4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: message.isLoading
                          ? Row(
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
                                  message.content,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              message.content,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                height: 1.4,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12), // 内容右距离头像12
                  ClipOval(
                    child: Image.asset(
                      'assets/images/head/user_head_1.jpg', // 使用生成的用户信息里的头像
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: AppConstants.primaryColor,
                            size: 24,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12), // 头像右间距12
                ],
              ],
            ),
          ),
      ],
    );
  }

  /// 判断是否应该显示时间
  bool _shouldShowTime(int index) {
    if (index == 0) return true;
    
    final currentMessage = _conversation.messages[index];
    final previousMessage = _conversation.messages[index - 1];
    
    final timeDiff = currentMessage.timestamp.difference(previousMessage.timestamp);
    return timeDiff.inMinutes > 5; // 超过5分钟显示时间
  }

  /// 格式化消息时间
  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);
    
    if (messageDate == today) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return '昨天 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.month}月${time.day}日 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  /// 构建输入区域
  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // 输入框
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      onChanged: (text) => setState(() {}), // 更新发送按钮状态
                      onTap: () {
                        // 点击输入框时滚动到底部
                        Future.delayed(const Duration(milliseconds: 300), () {
                          _scrollToBottom();
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: '聊一聊吧～',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  // 发送按钮（当有文本时显示）
                  if (_textController.text.trim().isNotEmpty || _isSending)
                    GestureDetector(
                      onTap: _isSending ? null : _sendMessage,
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _isSending 
                              ? Colors.grey[300]
                              : const Color(0xFF95EC69),
                          shape: BoxShape.circle,
                        ),
                        child: _isSending
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(
                                Icons.send,
                                color: Colors.black,
                                size: 16,
                              ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // 视频通话按钮
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _startVideoCall,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF28D9DE),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF28D9DE).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.videocam,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 发送消息
  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    _textController.clear();
    
    // 触发震动反馈
    HapticFeedback.lightImpact();

    try {
      await _messageService.sendMessage(
        conversationId: _conversation.id,
        content: text,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('发送失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  /// 启动视频通话
  void _startVideoCall() {
    // 从会话信息创建TravelBlogger对象
    final blogger = TravelBlogger(
      id: int.tryParse(_conversation.userId) ?? 0,
      name: _conversation.userName,
      avatar: _conversation.userAvatar,
      fans: 0, // 这些信息在聊天中不重要
      follows: 0,
      bio: '',
      tags: [],
      gender: '',
      posts: [],
    );

    // 启动视频通话页面
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoCallPage(blogger: blogger),
      ),
    );
  }
} 