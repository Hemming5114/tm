/// 消息类型枚举
enum MessageType {
  text,
  image,
  system,
}

/// 消息发送者类型
enum MessageSender {
  user,
  ai,
  system,
}

/// 单条消息模型
class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final MessageSender sender;
  final DateTime timestamp;
  final String? imageUrl;
  final bool isLoading;

  ChatMessage({
    String? id,
    required this.content,
    required this.type,
    required this.sender,
    DateTime? timestamp,
    this.imageUrl,
    this.isLoading = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       timestamp = timestamp ?? DateTime.now();

  /// 从JSON创建消息对象
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['content'],
      type: MessageType.values[json['type']],
      sender: MessageSender.values[json['sender']],
      timestamp: DateTime.parse(json['timestamp']),
      imageUrl: json['imageUrl'],
      isLoading: json['isLoading'] ?? false,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.index,
      'sender': sender.index,
      'timestamp': timestamp.toIso8601String(),
      'imageUrl': imageUrl,
      'isLoading': isLoading,
    };
  }

  /// 创建副本
  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    MessageSender? sender,
    DateTime? timestamp,
    String? imageUrl,
    bool? isLoading,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      imageUrl: imageUrl ?? this.imageUrl,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 会话模型
class ChatConversation {
  final String id;
  final String title;
  final String userId;
  final String userName;
  final String userAvatar;
  final List<ChatMessage> messages;
  final DateTime lastMessageTime;
  final String lastMessageContent;
  final int unreadCount;

  ChatConversation({
    String? id,
    required this.title,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    List<ChatMessage>? messages,
    DateTime? lastMessageTime,
    String? lastMessageContent,
    this.unreadCount = 0,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       messages = messages ?? [],
       lastMessageTime = lastMessageTime ?? DateTime.now(),
       lastMessageContent = lastMessageContent ?? '';

  /// 从JSON创建会话对象
  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'],
      title: json['title'],
      userId: json['userId'],
      userName: json['userName'],
      userAvatar: json['userAvatar'],
      messages: (json['messages'] as List<dynamic>?)
          ?.map((msg) => ChatMessage.fromJson(msg))
          .toList() ?? [],
      lastMessageTime: DateTime.parse(json['lastMessageTime']),
      lastMessageContent: json['lastMessageContent'] ?? '',
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'lastMessageContent': lastMessageContent,
      'unreadCount': unreadCount,
    };
  }

  /// 创建副本
  ChatConversation copyWith({
    String? id,
    String? title,
    String? userId,
    String? userName,
    String? userAvatar,
    List<ChatMessage>? messages,
    DateTime? lastMessageTime,
    String? lastMessageContent,
    int? unreadCount,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      title: title ?? this.title,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      messages: messages ?? this.messages,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
} 