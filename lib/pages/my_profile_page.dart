import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../utils/storage_util.dart';
import '../utils/toast_util.dart';
import '../utils/image_storage_service.dart';

/// 用户设置页面
class MyProfilePage extends StatefulWidget {
  const MyProfilePage({Key? key}) : super(key: key);

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  UserModel? _userInfo;
  bool _isLoading = true;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _signatureController = TextEditingController();
  
  Uint8List? _customAvatarData;
  bool _hasCustomAvatar = false;
  
  final ImagePicker _imagePicker = ImagePicker();
  final int _maxNameLength = 10;
  final int _maxSignatureLength = 40;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadCustomAvatar();
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

  /// 加载自定义头像
  Future<void> _loadCustomAvatar() async {
    try {
      final hasCustom = await ImageStorageService.hasCustomAvatar();
      if (hasCustom) {
        final avatarData = await ImageStorageService.getUserAvatarData();
        setState(() {
          _hasCustomAvatar = true;
          _customAvatarData = avatarData;
        });
      }
    } catch (e) {
      print('加载自定义头像失败: $e');
    }
  }



  /// 选择头像
  Future<void> _pickAvatar() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        final success = await ImageStorageService.saveUserAvatar(imageFile);

        if (success) {
          // 重新加载头像数据
          final avatarData = await ImageStorageService.getUserAvatarData();
          setState(() {
            _customAvatarData = avatarData;
            _hasCustomAvatar = true;
          });
          ToastUtil.showInfo(context, '头像上传成功，正在审核中');
        } else {
          ToastUtil.showInfo(context, '头像保存失败，请重试');
        }
      }
    } catch (e) {
      print('选择头像失败: $e');
      ToastUtil.showInfo(context, '选择头像失败，请重试');
    }
  }



  /// 保存用户信息
  Future<void> _saveUserInfo() async {
    if (_nameController.text.trim().isEmpty) {
      ToastUtil.showInfo(context, '请输入昵称');
      return;
    }

    if (_nameController.text.trim().length > _maxNameLength) {
      ToastUtil.showInfo(context, '昵称长度不能超过${_maxNameLength}个字符');
      return;
    }

    if (_signatureController.text.length > _maxSignatureLength) {
      ToastUtil.showInfo(context, '签名长度不能超过${_maxSignatureLength}个字符');
      return;
    }

    try {
      ToastUtil.showLoading(context, '保存中...');

      if (_userInfo != null) {
        final updatedUser = _userInfo!.copyWith(
          name: _nameController.text.trim(),
          signature: _signatureController.text.trim(),
        );

        final success = await StorageUtil.saveUserInfo(updatedUser);
        if (success) {
          setState(() {
            _userInfo = updatedUser;
          });
          ToastUtil.showSuccess(context, '保存成功');
          Navigator.pop(context);
        } else {
          ToastUtil.showError(context, '保存失败，请重试');
        }
      }
    } catch (e) {
      print('保存用户信息失败: $e');
      ToastUtil.showError(context, '保存失败，请重试');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('编辑资料'),
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '设置',
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
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                   // 头像部分
                   _buildAvatarSection(),
                   const SizedBox(height: 32),
                   
                   // 昵称部分
                   _buildNicknameSection(),
                   const SizedBox(height: 32),
                   
                   // 签名部分
                   _buildSignatureSection(),
                 ],
              ),
            ),
          ),
          
          // 保存按钮
          _buildSaveButton(),
        ],
      ),
    );
  }

  /// 构建头像选择区域
  Widget _buildAvatarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '头像',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: GestureDetector(
            onTap: _pickAvatar,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
                             child: _hasCustomAvatar && _customAvatarData != null
                   ? Stack(
                       children: [
                         ClipRRect(
                           borderRadius: BorderRadius.circular(7),
                           child: Image.memory(
                             _customAvatarData!,
                             width: 98,
                             height: 98,
                             fit: BoxFit.cover,
                           ),
                         ),
                         Positioned(
                           top: 4,
                           right: 4,
                           child: Container(
                             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                             decoration: BoxDecoration(
                               color: Colors.orange,
                               borderRadius: BorderRadius.circular(8),
                             ),
                             child: const Text(
                               '审核中',
                               style: TextStyle(
                                 color: Colors.white,
                                 fontSize: 10,
                                 fontWeight: FontWeight.w500,
                               ),
                             ),
                           ),
                         ),
                       ],
                     )
                  : (_userInfo?.avatar != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Image.asset(
                            'assets/images/head/${_userInfo!.avatar}',
                            width: 98,
                            height: 98,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.add,
                                size: 40,
                                color: Colors.grey,
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.add,
                          size: 40,
                          color: Colors.grey,
                        )),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建昵称部分
  Widget _buildNicknameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '昵称',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _nameController,
            maxLength: _maxNameLength,
            decoration: InputDecoration(
              hintText: '请输入',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              counterText: '${_nameController.text.length}/$_maxNameLength',
              counterStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  /// 构建签名部分
  Widget _buildSignatureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '签名',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _signatureController,
            maxLength: _maxSignatureLength,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '请输入',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              counterText: '${_signatureController.text.length}/$_maxSignatureLength',
              counterStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
      ],
    );
  }



  /// 构建保存按钮
  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _saveUserInfo,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 0,
          ),
          child: const Text(
            '保存',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
} 