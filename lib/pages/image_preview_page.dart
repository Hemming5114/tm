import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:io';
import '../constants/app_constants.dart';
import '../utils/ios_photos_service.dart';

/// 图片预览页面
class ImagePreviewPage extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String? heroTag;

  const ImagePreviewPage({
    Key? key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.heroTag,
  }) : super(key: key);

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isVisible = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 切换UI显示/隐藏
  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  /// 保存图片到相册
  Future<void> _saveImage() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // 获取当前图片数据
      final currentImageUrl = widget.imageUrls[_currentIndex];
      Uint8List? imageBytes;

      // 判断是网络图片还是本地资源图片
      if (currentImageUrl.startsWith('http')) {
        // 网络图片
        imageBytes = await _downloadNetworkImage(currentImageUrl);
      } else {
        // 本地资源图片
        imageBytes = await _loadAssetImage(currentImageUrl);
      }

      if (imageBytes == null) {
        _showMessage('图片加载失败，请重试');
        return;
      }

      _showMessage('正在保存图片...');

      if (Platform.isIOS) {
        // iOS: 使用原生Photos框架
        await _saveImageIOS(imageBytes);
      } else if (Platform.isAndroid) {
        // Android: 使用权限处理
        await _saveImageAndroid(imageBytes);
      } else {
        _showMessage('不支持的平台');
      }
    } catch (e) {
      print('保存图片失败: $e');
      _showMessage('保存失败，请重试');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// iOS保存图片方法
  Future<void> _saveImageIOS(Uint8List imageBytes) async {
    try {
      // 请求iOS相册权限
      final permissionStatus = await IOSPhotosService.requestPhotosPermission();
      
      if (!IOSPhotosService.isPermissionGranted(permissionStatus)) {
        final statusDesc = IOSPhotosService.getPermissionStatusDescription(permissionStatus);
        _showMessage('无法保存图片：$statusDesc');
        return;
      }

      // 使用原生Photos框架保存图片
      final result = await IOSPhotosService.saveImageToPhotos(imageBytes);
      
      if (result['success'] == true) {
        _showMessage(result['message'] ?? '图片已保存到相册');
      } else {
        _showMessage('保存失败，请重试');
      }
    } catch (e) {
      print('iOS保存图片失败: $e');
      if (e is PlatformException) {
        _showMessage('保存失败：${e.message}');
      } else {
        _showMessage('保存失败，请重试');
      }
    }
  }

  /// Android保存图片方法
  Future<void> _saveImageAndroid(Uint8List imageBytes) async {
    try {
      // Android权限处理
      final permissionResult = await _requestAndroidPermission();
      
      if (permissionResult != PermissionStatus.granted) {
        if (permissionResult == PermissionStatus.denied) {
          _showMessage('需要相册权限才能保存图片');
        } else if (permissionResult == PermissionStatus.permanentlyDenied) {
          _showMessage('权限被拒绝，请在系统设置中开启相册权限');
        } else {
          _showMessage('权限申请失败，请重试');
        }
        return;
      }

      // 使用image_gallery_saver保存图片
      final result = await ImageGallerySaver.saveImage(
        imageBytes,
        quality: 100,
        name: 'tm_image_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (result['isSuccess'] == true) {
        _showMessage('图片已保存到相册');
      } else {
        _showMessage('保存失败：${result['errorMessage'] ?? '未知错误'}');
      }
    } catch (e) {
      print('Android保存图片失败: $e');
      _showMessage('保存失败，请重试');
    }
  }

  /// Android权限申请
  Future<PermissionStatus> _requestAndroidPermission() async {
    Permission permission;
    
    // Android 根据版本选择权限
    if (await _getAndroidVersion() >= 33) {
      // Android 13+ 使用 photos 权限
      permission = Permission.photos;
    } else {
      // Android 12 及以下使用 storage 权限
      permission = Permission.storage;
    }

    // 直接请求权限，系统会自动显示权限对话框
    final status = await permission.request();
    
    print('Android权限申请结果: $status');
    return status;
  }

  /// 获取Android版本
  Future<int> _getAndroidVersion() async {
    try {
      final info = await Process.run('getprop', ['ro.build.version.sdk']);
      return int.tryParse(info.stdout.toString().trim()) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// 下载网络图片
  Future<Uint8List?> _downloadNetworkImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      print('下载网络图片失败: $e');
    }
    return null;
  }

  /// 加载本地资源图片
  Future<Uint8List?> _loadAssetImage(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      return data.buffer.asUint8List();
    } catch (e) {
      print('加载资源图片失败: $e');
    }
    return null;
  }

  /// 显示提示消息
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 图片画廊
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: AssetImage(widget.imageUrls[index]),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 3.0,
                heroAttributes: widget.heroTag != null
                    ? PhotoViewHeroAttributes(tag: '${widget.heroTag}_$index')
                    : null,
              );
            },
            itemCount: widget.imageUrls.length,
            loadingBuilder: (context, event) => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
              ),
            ),
            backgroundDecoration: const BoxDecoration(
              color: Colors.black,
            ),
            pageController: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            scrollDirection: Axis.horizontal,
          ),

          // 手势检测器 - 点击切换UI显示
          GestureDetector(
            onTap: _toggleVisibility,
            behavior: HitTestBehavior.translucent,
            child: Container(
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // 顶部工具栏
          AnimatedOpacity(
            opacity: _isVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 返回按钮
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),

                    // 页码显示
                    if (widget.imageUrls.length > 1)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentIndex + 1} / ${widget.imageUrls.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    // 保存按钮
                    GestureDetector(
                      onTap: _isSaving ? null : _saveImage,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(
                                Icons.download,
                                color: Colors.white,
                                size: 20,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 底部指示器（仅在多张图片时显示）
          if (widget.imageUrls.length > 1)
            AnimatedOpacity(
              opacity: _isVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.imageUrls.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentIndex
                            ? AppConstants.primaryColor
                            : Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
} 