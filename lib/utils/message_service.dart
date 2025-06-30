import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/message_model.dart';
import '../constants/app_constants.dart';

/// 消息服务类
class MessageService extends ChangeNotifier {
  static final MessageService _instance = MessageService._internal();
  static MessageService get instance => _instance;
  MessageService._internal();

  // 智谱AI配置
  static String get _zhipuApiKey => AppConstants.zhipuApiKey;
  static String get _zhipuApiUrl => AppConstants.zhipuApiUrl;
  
  // 缓存键前缀
  static const String _conversationsKey = 'chat_conversations';
  
  // 内存中的会话列表
  List<ChatConversation> _conversations = [];
  
  /// 获取所有会话
  List<ChatConversation> get conversations => List.unmodifiable(_conversations);
  
  /// 初始化服务，从本地存储加载会话
  Future<void> initialize() async {
    await _loadConversations();
  }
  
  /// 从本地存储加载会话
  Future<void> _loadConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conversationsJson = prefs.getString(_conversationsKey);
      
      if (conversationsJson != null) {
        final List<dynamic> conversationsList = json.decode(conversationsJson);
        _conversations = conversationsList
            .map((json) => ChatConversation.fromJson(json))
            .toList();
        
        // 按最后消息时间排序
        _conversations.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
        
        notifyListeners();
      }
    } catch (e) {
      print('加载会话失败: $e');
    }
  }
  
  /// 保存会话到本地存储
  Future<void> _saveConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conversationsJson = json.encode(
        _conversations.map((conv) => conv.toJson()).toList(),
      );
      await prefs.setString(_conversationsKey, conversationsJson);
    } catch (e) {
      print('保存会话失败: $e');
    }
  }
  
  /// 获取或创建会话
  Future<ChatConversation> getOrCreateConversation({
    required String userId,
    required String userName,
    required String userAvatar,
  }) async {
    // 查找现有会话
    final existingIndex = _conversations.indexWhere((conv) => conv.userId == userId);
    
    if (existingIndex != -1) {
      return _conversations[existingIndex];
    }
    
    // 创建新会话
    final conversation = ChatConversation(
      title: '与 $userName 的对话',
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
    );
    
    _conversations.insert(0, conversation);
    await _saveConversations();
    notifyListeners();
    
    return conversation;
  }
  
  /// 发送消息
  Future<ChatMessage?> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    try {
      // 找到对话
      final conversationIndex = _conversations.indexWhere((conv) => conv.id == conversationId);
      if (conversationIndex == -1) {
        throw Exception('会话不存在');
      }
      
      final conversation = _conversations[conversationIndex];
      
      // 创建用户消息
      final userMessage = ChatMessage(
        content: content,
        type: type,
        sender: MessageSender.user,
      );
      
      // 创建AI加载消息
      final aiLoadingMessage = ChatMessage(
        content: '正在思考中...',
        type: MessageType.text,
        sender: MessageSender.ai,
        isLoading: true,
      );
      
      // 更新会话
      final updatedMessages = [...conversation.messages, userMessage, aiLoadingMessage];
      final updatedConversation = conversation.copyWith(
        messages: updatedMessages,
        lastMessageTime: DateTime.now(),
        lastMessageContent: content,
      );
      
      _conversations[conversationIndex] = updatedConversation;
      _conversations.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      notifyListeners();
      await _saveConversations();
      
      // 调用AI接口
      final aiResponse = await _callZhipuAPI(content, conversation.messages);
      
      if (aiResponse != null) {
        // 替换加载消息为实际回复
        final finalMessages = [...updatedMessages];
        finalMessages.removeLast(); // 移除加载消息
        finalMessages.add(aiResponse);
        
        final finalConversation = updatedConversation.copyWith(
          messages: finalMessages,
          lastMessageTime: aiResponse.timestamp,
          lastMessageContent: aiResponse.content,
        );
        
        _conversations[conversationIndex] = finalConversation;
        notifyListeners();
        await _saveConversations();
        
        return aiResponse;
      } else {
        // AI回复失败，移除加载消息并添加错误消息
        final errorMessage = ChatMessage(
          content: '抱歉，我现在无法回复，请稍后再试。',
          type: MessageType.system,
          sender: MessageSender.system,
        );
        
        final finalMessages = [...updatedMessages];
        finalMessages.removeLast();
        finalMessages.add(errorMessage);
        
        final finalConversation = updatedConversation.copyWith(
          messages: finalMessages,
          lastMessageTime: errorMessage.timestamp,
          lastMessageContent: errorMessage.content,
        );
        
        _conversations[conversationIndex] = finalConversation;
        notifyListeners();
        await _saveConversations();
        
        return errorMessage;
      }
    } catch (e) {
      print('发送消息失败: $e');
      return null;
    }
  }
  
  /// 调用智谱AI接口
  Future<ChatMessage?> _callZhipuAPI(String userMessage, List<ChatMessage> history) async {
    try {
      // 检查API密钥是否已配置
      if (_zhipuApiKey.isEmpty || _zhipuApiKey == 'YOUR_ZHIPU_API_KEY') {
        print('智谱AI API密钥未配置，返回默认回复');
        return ChatMessage(
          content: '你好！我是AI助手。目前智谱AI API密钥未配置，无法提供智能回复。请联系开发者配置API密钥。',
          type: MessageType.text,
          sender: MessageSender.ai,
        );
      }
      // 构建对话历史
      final messages = <Map<String, dynamic>>[];
      
      // 添加系统提示
      messages.add({
        'role': 'system',
        'content': '你是一个友善、有趣的AI助手，专门帮助用户解决旅行相关的问题。请用简洁、友善的语气回复用户。',
      });
      
      // 添加历史消息（最近10条）
      final recentHistory = history.where((msg) => 
        msg.sender != MessageSender.system && !msg.isLoading
      ).toList();
      
      final historyToInclude = recentHistory.length > 10 
          ? recentHistory.sublist(recentHistory.length - 10)
          : recentHistory;
      
      for (final msg in historyToInclude) {
        messages.add({
          'role': msg.sender == MessageSender.user ? 'user' : 'assistant',
          'content': msg.content,
        });
      }
      
      // 添加当前用户消息
      messages.add({
        'role': 'user',
        'content': userMessage,
      });
      
             // 准备请求
       final requestBody = {
         'model': AppConstants.zhipuModel,
         'messages': messages,
         'max_tokens': 1000,
         'temperature': 0.7,
       };
      
      final response = await http.post(
        Uri.parse(_zhipuApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_zhipuApiKey',
        },
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final aiContent = responseData['choices']?[0]?['message']?['content'];
        
        if (aiContent != null && aiContent.isNotEmpty) {
          return ChatMessage(
            content: aiContent,
            type: MessageType.text,
            sender: MessageSender.ai,
          );
        }
      } else {
        print('智谱AI接口错误: ${response.statusCode}, ${response.body}');
      }
      
      return null;
    } catch (e) {
      print('调用智谱AI接口失败: $e');
      return null;
    }
  }
  
  /// 获取指定会话
  ChatConversation? getConversation(String conversationId) {
    try {
      return _conversations.firstWhere((conv) => conv.id == conversationId);
    } catch (e) {
      return null;
    }
  }
  
  /// 删除会话
  Future<void> deleteConversation(String conversationId) async {
    _conversations.removeWhere((conv) => conv.id == conversationId);
    await _saveConversations();
    notifyListeners();
  }
  
  /// 清空所有会话
  Future<void> clearAllConversations() async {
    _conversations.clear();
    await _saveConversations();
    notifyListeners();
  }
  
  /// 标记会话为已读
  Future<void> markConversationAsRead(String conversationId) async {
    final index = _conversations.indexWhere((conv) => conv.id == conversationId);
    if (index != -1) {
      _conversations[index] = _conversations[index].copyWith(unreadCount: 0);
      await _saveConversations();
      notifyListeners();
    }
  }
  
  /// 获取未读消息总数
  int get totalUnreadCount {
    return _conversations.fold(0, (sum, conv) => sum + conv.unreadCount);
  }
  

} 