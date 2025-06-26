class TravelBlogger {
  final int id;         // 用户ID
  final String name;
  final String avatar;  // 头像文件路径
  final int fans;       // 粉丝数
  final int follows;    // 关注数
  final String bio;     // 个人简介
  final List<String> tags; // 标签（如：旅行博主、诗人等）
  final String gender;  // 性别
  final List<TravelPost> posts; // 旅行帖子

  TravelBlogger({
    required this.id,
    required this.name,
    required this.avatar,
    required this.fans,
    required this.follows,
    required this.bio,
    required this.tags,
    required this.gender,
    required this.posts,
  });

  // 从文件夹数据创建
  factory TravelBlogger.fromFolderData(Map<String, dynamic> data) {
    return TravelBlogger(
      id: data['id'] ?? 0,
      name: data['name'] ?? '',
      avatar: data['avatar'] ?? '',
      fans: data['fans'] ?? 0,
      follows: data['follows'] ?? 0,
      bio: data['bio'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      gender: data['gender'] ?? '',
      posts: (data['posts'] as List<dynamic>?)
          ?.map((post) => TravelPost.fromMap(post))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'fans': fans,
      'follows': follows,
      'bio': bio,
      'tags': tags,
      'gender': gender,
      'posts': posts.map((post) => post.toMap()).toList(),
    };
  }

  // 格式化粉丝数显示
  String get fansDisplay {
    if (fans >= 10000) {
      return '${(fans / 10000).toStringAsFixed(1)}w';
    }
    return fans.toString();
  }

  // 格式化关注数显示
  String get followsDisplay {
    if (follows >= 10000) {
      return '${(follows / 10000).toStringAsFixed(1)}w';
    }
    return follows.toString();
  }
}

class TravelPost {
  final String title;
  final String content;
  final List<String> images; // 图片文件路径列表
  final int likes;
  final int comments;
  final DateTime publishTime;

  TravelPost({
    required this.title,
    required this.content,
    required this.images,
    required this.likes,
    required this.comments,
    required this.publishTime,
  });

  factory TravelPost.fromMap(Map<String, dynamic> map) {
    return TravelPost(
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
      publishTime: DateTime.tryParse(map['publishTime'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'images': images,
      'likes': likes,
      'comments': comments,
      'publishTime': publishTime.toIso8601String(),
    };
  }

  // 格式化点赞数显示
  String get likesDisplay {
    if (likes >= 1000) {
      return '${(likes / 1000).toStringAsFixed(1)}k';
    }
    return likes.toString();
  }

  // 格式化评论数显示
  String get commentsDisplay {
    if (comments >= 1000) {
      return '${(comments / 1000).toStringAsFixed(1)}k';
    }
    return comments.toString();
  }
} 