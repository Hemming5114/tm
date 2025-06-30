import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../utils/storage_util.dart';
import '../utils/toast_util.dart';

/// 我的资料页面
class MyProfilePage extends StatefulWidget {
  const MyProfilePage({Key? key}) : super(key: key);

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  UserModel? _userInfo;
  bool _isLoading = true;
  bool _isEditing = false;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _signatureController = TextEditingController();
  String _selectedGender = '男';
  String _selectedAvatar = 'user_head_11.jpg';

  // 头像选项
  final List<String> _avatarOptions = List.generate(10, (index) => 'user_head_${index + 11}.jpg');
  
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  /// 加载用户信息
  Future<void> _loadUserInfo() async {
    try {
      final userInfo = await StorageUtil.getUserInfo();
      if (mounted && userInfo != null) {
        setState(() {
          _userInfo = userInfo;
          _nameController.text = userInfo.name;
          _signatureController.text = userInfo.signature;
          _selectedGender = userInfo.gender;
          _selectedAvatar = userInfo.avatar;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('加载用户信息失败: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 保存用户信息
  Future<void> _saveUserInfo() async {
    if (_nameController.text.trim().isEmpty) {
      ToastUtil.showInfo(context, '请输入用户名');
      return;
    }

    try {
      if (_userInfo != null) {
        final updatedUser = _userInfo!.copyWith(
          name: _nameController.text.trim(),
          signature: _signatureController.text.trim(),
          gender: _selectedGender,
          avatar: _selectedAvatar,
        );

        await StorageUtil.saveUserInfo(updatedUser);
        
        setState(() {
          _userInfo = updatedUser;
          _isEditing = false;
        });

        ToastUtil.showInfo(context, '保存成功');
      }
    } catch (e) {
      print('保存用户信息失败: $e');
      ToastUtil.showInfo(context, '保存失败，请重试');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('我的资料'),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
          ),
        ),
      );
    }

    if (_userInfo == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('我的资料'),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text('加载用户信息失败'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '我的资料',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_isEditing) {
                _saveUserInfo();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
            child: Text(
              _isEditing ? '保存' : '编辑',
              style: TextStyle(
                color: AppConstants.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 头像选择
            _buildAvatarSection(),
            const SizedBox(height: 20),
            
            // 基本信息
            _buildInfoCard(),
            const SizedBox(height: 20),
            
            // 账户信息
            _buildAccountCard(),
          ],
        ),
      ),
    );
  }

  /// 构建头像选择区域
  Widget _buildAvatarSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 当前头像
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppConstants.primaryColor, width: 3),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/head/$_selectedAvatar',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: AppConstants.primaryColor,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          if (_isEditing) ...[
            const Text(
              '选择头像',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            // 头像选择网格
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _avatarOptions.length,
              itemBuilder: (context, index) {
                final avatar = _avatarOptions[index];
                final isSelected = avatar == _selectedAvatar;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAvatar = avatar;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppConstants.primaryColor : Colors.grey[300]!,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/head/$avatar',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.person, size: 20),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  /// 构建基本信息卡片
  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '基本信息',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // 用户名
          _buildInfoItem(
            '用户名',
            _isEditing ? TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ) : Text(
              _userInfo!.name,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 性别
          _buildInfoItem(
            '性别',
            _isEditing ? DropdownButton<String>(
              value: _selectedGender,
              items: ['男', '女'].map((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                }
              },
            ) : Text(
              _userInfo!.gender,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 个性签名
          _buildInfoItem(
            '个性签名',
            _isEditing ? TextField(
              controller: _signatureController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
                hintText: '写点什么介绍一下自己吧...',
              ),
            ) : Text(
              _userInfo!.signature.isEmpty ? '这个人很懒，什么都没写' : _userInfo!.signature,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建账户信息卡片
  Widget _buildAccountCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '账户信息',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // 用户ID
          _buildInfoItem(
            '用户ID',
            Row(
              children: [
                Expanded(
                  child: Text(
                    _userInfo!.id,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _userInfo!.id));
                    ToastUtil.showInfo(context, '用户ID已复制到剪贴板');
                  },
                  icon: const Icon(Icons.copy, size: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 注册时间
          _buildInfoItem(
            '注册时间',
            Text(
              DateTime.parse(_userInfo!.createdAt).toString().split('.')[0],
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 会员到期时间
          _buildInfoItem(
            '会员到期',
            Text(
              DateTime.parse(_userInfo!.memberExpiry).toString().split(' ')[0],
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建信息项
  Widget _buildInfoItem(String label, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }
} 