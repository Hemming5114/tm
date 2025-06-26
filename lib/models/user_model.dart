class UserModel {
  final String id;
  final String name;
  final String gender;
  final String avatar;
  final int coins;
  final String memberExpiry;
  final String signature;
  final String createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.gender,
    required this.avatar,
    required this.coins,
    required this.memberExpiry,
    required this.signature,
    required this.createdAt,
  });

  // 从Map创建UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      gender: map['gender'] ?? '',
      avatar: map['avatar'] ?? '',
      coins: map['coins'] ?? 0,
      memberExpiry: map['memberExpiry'] ?? '',
      signature: map['signature'] ?? '',
      createdAt: map['createdAt'] ?? '',
    );
  }

  // 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'avatar': avatar,
      'coins': coins,
      'memberExpiry': memberExpiry,
      'signature': signature,
      'createdAt': createdAt,
    };
  }

  // 复制并修改部分字段
  UserModel copyWith({
    String? id,
    String? name,
    String? gender,
    String? avatar,
    int? coins,
    String? memberExpiry,
    String? signature,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      avatar: avatar ?? this.avatar,
      coins: coins ?? this.coins,
      memberExpiry: memberExpiry ?? this.memberExpiry,
      signature: signature ?? this.signature,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, gender: $gender, avatar: $avatar, coins: $coins, memberExpiry: $memberExpiry, signature: $signature, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.name == name &&
        other.gender == gender &&
        other.avatar == avatar &&
        other.coins == coins &&
        other.memberExpiry == memberExpiry &&
        other.signature == signature &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        gender.hashCode ^
        avatar.hashCode ^
        coins.hashCode ^
        memberExpiry.hashCode ^
        signature.hashCode ^
        createdAt.hashCode;
  }
} 