import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../utils/toast_util.dart';

class PostTravelPage extends StatefulWidget {
  const PostTravelPage({super.key});

  @override
  State<PostTravelPage> createState() => _PostTravelPageState();
}

class _PostTravelPageState extends State<PostTravelPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  bool _isLoading = false;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    // 添加监听器来实时更新字符计数
    _titleController.addListener(() {
      setState(() {});
    });
    _contentController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // 选择图片
  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 80,
      );
      
      if (images.isNotEmpty) {
        // 限制最多9张图片
        List<XFile> selectedImages = [..._selectedImages];
        for (var image in images) {
          if (selectedImages.length < 9) {
            selectedImages.add(image);
          } else {
            break;
          }
        }
        
        if (selectedImages.length >= 9 && images.length > (9 - _selectedImages.length)) {
          ToastUtil.showWarning(context, '最多只能选择9张图片');
        }
        
        setState(() {
          _selectedImages = selectedImages;
        });
      }
    } catch (e) {
      ToastUtil.showError(context, '选择图片失败：$e');
    }
  }

  // 删除图片
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // 调用智谱AI生成内容
  Future<String?> _generateContentWithAI(String title) async {
    try {
      setState(() {
        _isGenerating = true;
      });

      final requestBody = {
        'model': 'GLM-4-Flash',
        'messages': [
          {
            'role': 'user',
            'content': '''
请根据游记标题"$title"生成一段优美的游记内容，要求：
1. 内容生动有趣，富有感染力
2. 字数控制在200-500字之间
3. 体现旅行的美好和感悟
4. 语言优美，适合分享
5. 不要包含具体的时间和地点细节

请直接返回游记内容，不要其他说明文字。
            '''
          }
        ],
        'temperature': 0.8,
      };

      final response = await http.post(
        Uri.parse('https://open.bigmodel.cn/api/paas/v4/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer 2b74dd4009944bb4a231ee9a7d50eab2.gRo4uOUiDz91hHkH',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'].trim();
        return content;
      } else {
        print('AI生成失败，状态码: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('AI生成异常: $e');
      return null;
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  // 保存游记
  Future<void> _savePost() async {
    if (_titleController.text.trim().isEmpty) {
      ToastUtil.showWarning(context, '请输入标题');
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      ToastUtil.showWarning(context, '请分享您的心情');
      return;
    }

    if (_selectedImages.isEmpty) {
      ToastUtil.showWarning(context, '请至少选择一张图片');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 调用AI生成内容
      final aiContent = await _generateContentWithAI(_titleController.text.trim());
      
      if (aiContent != null) {
        // 模拟保存到服务器
        await Future.delayed(const Duration(seconds: 2));
        
        // 显示成功提示
        ToastUtil.showSuccess(context, '已提交审核，审核成功将会展示在推荐');
        
        // 延迟返回
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      } else {
        ToastUtil.showError(context, '内容生成失败，请重试');
      }
    } catch (e) {
      ToastUtil.showError(context, '保存失败：$e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '游记动态',
          style: TextStyle(
            color: AppConstants.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppConstants.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片选择区域 - 新设计
            _buildImageSection(),
            
            const SizedBox(height: 24),
            
            // 标题输入
            _buildTitleSection(),
            
            const SizedBox(height: 24),
            
            // 心情分享
            _buildContentSection(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).padding.bottom + 20,
          top: 20,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading || _isGenerating ? null : _savePost,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isLoading || _isGenerating ? Colors.grey[400] : Colors.grey[800],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 0,
            ),
            child: _isLoading || _isGenerating
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(_isGenerating ? '正在生成内容...' : '保存中...'),
                    ],
                  )
                : const Text(
                    '保存',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 图片网格展示（包含空状态的小+号）
        Container(
          width: double.infinity,
          child: _buildImageGrid(),
        ),
      ],
    );
  }

  Widget _buildImageGrid() {
    // 计算网格布局
    int crossAxisCount = 3; // 每行3张图片
    
    // 如果没有图片，显示一个小的+号
    if (_selectedImages.isEmpty) {
      return Container(
        height: 120, // 小的高度
        child: Row(
          children: [
            _buildAddImageButton(),
            // 空白填充
            Expanded(child: Container()),
            Expanded(child: Container()),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0, // 正方形
      ),
      itemCount: _selectedImages.length + (_selectedImages.length < 9 ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _selectedImages.length) {
          return _buildImageItem(_selectedImages[index], index);
        } else {
          return _buildAddImageButton();
        }
      },
    );
  }

  Widget _buildImageItem(XFile image, int index) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: FileImage(File(image.path)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.close,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: _selectedImages.isEmpty ? 120 : double.infinity,
        height: _selectedImages.isEmpty ? 120 : double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey[300]!,
            style: BorderStyle.solid,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.add,
            size: 30,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '标题',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _titleController,
            maxLength: 40,
            decoration: const InputDecoration(
              hintText: '添加标题',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              counterText: '',
            ),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '分享心情',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _contentController,
            maxLines: 8,
            maxLength: 1000,
            decoration: const InputDecoration(
              hintText: '分享下出游心情吧',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              counterText: '',
            ),
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${_contentController.text.length}/1000',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
} 