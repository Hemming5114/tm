import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/travel_blogger.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../utils/message_service.dart';
import '../utils/storage_util.dart';


/// 视频通话页面
class VideoCallPage extends StatefulWidget {
  final TravelBlogger blogger;

  const VideoCallPage({
    Key? key,
    required this.blogger,
  }) : super(key: key);

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> with TickerProviderStateMixin {
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  
  Timer? _callTimer;
  int _callDuration = 0;
  final bool _isCallConnected = false;
  
  UserModel? _currentUser;
  
  // 动画控制器
  late AnimationController _rippleController;
  late AnimationController _rotationController;
  late Animation<double> _rippleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    // 初始化动画控制器
    _rippleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    // 波纹动画 - 从0.5到1.5的缩放
    _rippleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
    
    // 旋转动画 - 360度旋转
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    // 启动动画
    _rippleController.repeat();
    _rotationController.repeat();
    
    _initializeCall();
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _stopRingtone();
    _audioPlayer?.dispose();
    
    // 释放动画控制器
    _rippleController.dispose();
    _rotationController.dispose();
    
    super.dispose();
  }

  /// 初始化通话
  Future<void> _initializeCall() async {
    // 获取当前用户信息
    try {
      _currentUser = await StorageUtil.getUserInfo();
      print('📱 视频通话 - 当前用户信息: ${_currentUser?.name}, 头像: ${_currentUser?.avatar}');
      print('📱 视频通话 - 对方信息: ${widget.blogger.name}, 头像: ${widget.blogger.avatar}');
      
      // 刷新UI以显示头像
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('❌ 获取用户信息失败: $e');
    }
    
    // 延迟启动功能，避免初始化时的问题
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _startRingtone();
        _startCallTimer();
      }
    });
  }

  /// 开始播放铃声
  Future<void> _startRingtone() async {
    // 先检查音频文件是否存在，如果不存在直接使用震动
    bool hasAudioFile = false;
    try {
      await rootBundle.load('assets/audio/call.mp3');
      hasAudioFile = true;
    } catch (e) {
      // 文件不存在，使用震动作为铃声
      print('🔔 未找到音频文件，使用震动作为铃声');
      _startVibrateRingtone();
      return;
    }

    // 如果音频文件存在，尝试播放
    if (hasAudioFile) {
      try {
        _audioPlayer = AudioPlayer();
        await _audioPlayer!.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer!.play(AssetSource('audio/call.mp3'));
        
        setState(() {
          _isPlaying = true;
        });
        
        print('🎵 开始播放铃声');
      } catch (e) {
        print('❌ 播放铃声失败: $e');
        // 如果音频播放失败，使用震动作为备选方案
        _startVibrateRingtone();
      }
    }
  }

  /// 开始震动铃声（备选方案）
  void _startVibrateRingtone() {
    print('🔔 使用震动作为铃声备选方案');
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isPlaying || _isCallConnected || !mounted) {
        timer.cancel();
        return;
      }
      
      try {
        HapticFeedback.lightImpact();
        print('📳 震动铃声');
      } catch (e) {
        print('震动失败: $e');
      }
    });
  }

  /// 停止播放铃声
  Future<void> _stopRingtone() async {
    try {
      await _audioPlayer?.stop();
      setState(() {
        _isPlaying = false;
      });
      print('🔇 停止播放铃声');
    } catch (e) {
      print('❌ 停止铃声失败: $e');
    }
  }

  /// 开始通话计时器
  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _callDuration++;
      });
      
      // 1分钟后自动挂断
      if (_callDuration >= 60) {
        _endCall(isTimeout: true);
      }
    });
  }

  /// 结束通话
  Future<void> _endCall({bool isTimeout = false, bool isUserHangup = false}) async {
    await _stopRingtone();
    _callTimer?.cancel();
    
    // 插入通话记录到消息
    try {
      final conversation = await MessageService.instance.getOrCreateConversation(
        userId: widget.blogger.id.toString(),
        userName: widget.blogger.name,
        userAvatar: widget.blogger.avatar,
      );
      
      String messageContent;
      if (isTimeout) {
        messageContent = '视频通话 对方未接通';
      } else if (isUserHangup) {
        messageContent = '视频通话 已挂断';
      } else {
        messageContent = '视频通话 已结束';
      }
      
      await MessageService.instance.sendMessage(
        conversationId: conversation.id,
        content: messageContent,
        type: MessageType.system,
      );
    } catch (e) {
      print('插入通话记录失败: $e');
    }
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  /// 格式化通话时间
  String _formatCallDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _endCall(isUserHangup: true);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 背景图（对方头像）
            _buildBackground(),
            
            // 自己的头像预览
            _buildUserAvatarPreview(),
            
            // 顶部信息栏
            _buildTopBar(),
            
            // 底部挂断按钮
            _buildHangUpButton(),
            
            // 通话状态
            _buildCallStatus(),
          ],
        ),
      ),
    );
  }

  /// 构建背景图
  Widget _buildBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 对方头像作为背景
          Image.asset(
            widget.blogger.avatar,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('❌ 加载对方头像失败: ${widget.blogger.avatar}');
              print('错误详情: $error');
              return Container(
                color: Colors.grey[800],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person,
                        size: 100,
                        color: Colors.white54,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.blogger.name,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // 半透明遮罩
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  /// 构建用户头像预览窗口
  Widget _buildUserAvatarPreview() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 80,
      right: 16,
      child: Container(
        width: 120,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: _buildUserAvatar(),
        ),
      ),
    );
  }

  /// 构建用户头像Widget
  Widget _buildUserAvatar() {
    if (_currentUser?.avatar == null) {
      // 没有头像信息，显示默认图标
      return Container(
        color: Colors.grey[800],
        child: const Center(
          child: Icon(
            Icons.person,
            color: Colors.white54,
            size: 40,
          ),
        ),
      );
    }

    // 检查是否是自定义头像（以custom_开头）
    final avatar = _currentUser!.avatar!;
    if (avatar.startsWith('custom_')) {
      // 自定义头像，从本地存储加载
      return FutureBuilder<String?>(
        future: _loadCustomAvatar(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            try {
              final imageBytes = base64Decode(snapshot.data!);
              return Image.memory(
                imageBytes,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultAvatar();
                },
              );
            } catch (e) {
              return _buildDefaultAvatar();
            }
          }
          return _buildDefaultAvatar();
        },
      );
    } else {
      // 系统预设头像
      return Image.asset(
        'assets/images/head/$avatar',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('❌ 加载用户头像失败: assets/images/head/$avatar');
          return _buildDefaultAvatar();
        },
      );
    }
  }

  /// 加载自定义头像
  Future<String?> _loadCustomAvatar() async {
    try {
      return SharedPreferences.getInstance().then((prefs) {
        return prefs.getString('user_custom_avatar');
      });
    } catch (e) {
      print('❌ 加载自定义头像失败: $e');
      return null;
    }
  }

  /// 构建默认头像
  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(
          Icons.person,
          color: Colors.white54,
          size: 40,
        ),
      ),
    );
  }

  /// 构建顶部信息栏
  Widget _buildTopBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 16,
      right: 16,
      child: Column(
        children: [
          // 用户名
          Text(
            widget.blogger.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 3,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // 通话状态
          Text(
            _isCallConnected ? _formatCallDuration(_callDuration) : '正在呼叫中...',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              shadows: [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 3,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建挂断按钮（拨打中只显示这一个按钮）
  Widget _buildHangUpButton() {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 80,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: () => _endCall(isUserHangup: true),
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建通话状态指示器
  Widget _buildCallStatus() {
    if (_isCallConnected) return const SizedBox.shrink();
    
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 180,
      left: 0,
      right: 0,
      child: Column(
        children: [
          // 呼叫动画效果
          SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 外层波纹动画1
                AnimatedBuilder(
                  animation: _rippleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _rippleAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(
                              1.0 - _rippleAnimation.value + 0.5
                            ),
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                // 外层波纹动画2（延迟效果）
                AnimatedBuilder(
                  animation: _rippleAnimation,
                  builder: (context, child) {
                    final delayedValue = (_rippleAnimation.value + 0.3) % 1.0;
                    return Transform.scale(
                      scale: 0.5 + delayedValue,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(
                              (1.0 - delayedValue + 0.5).clamp(0.0, 1.0)
                            ),
                            width: 1.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                // 中间固定圆圈
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.8),
                      width: 2,
                    ),
                    color: Colors.white.withOpacity(0.1),
                  ),
                  child: AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation.value * 2 * 3.14159,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.transparent,
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.videocam,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 文字闪烁效果
          AnimatedBuilder(
            animation: _rippleAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: 0.5 + 0.5 * (1.0 - _rippleAnimation.value).abs(),
                child: const Text(
                  '正在连接中...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
} 