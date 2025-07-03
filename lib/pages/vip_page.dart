import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../utils/storage_util.dart';
import '../utils/toast_util.dart';

/// VIP充值页面
class VipPage extends StatefulWidget {
  const VipPage({Key? key}) : super(key: key);

  @override
  State<VipPage> createState() => _VipPageState();
}

class _VipPageState extends State<VipPage> {
  UserModel? _userInfo;
  int _selectedIndex = 0;
  bool _isLoading = false;
  bool _isFirstPurchase = false;

  final List<Map<String, dynamic>> _vipPlans = [
    {
      'title': '月会员首充',
      'price': '88',
      'originalPrice': '99',
      'duration': '1个月',
      'productId': 'com.kuailiao.changs0',
      'isFirstPurchase': true,
    },
    {
      'title': '月会员',
      'price': '99',
      'originalPrice': null,
      'duration': '1个月',
      'productId': 'com.kuailiao.changs0',
      'isFirstPurchase': false,
    },
    {
      'title': '季会员',
      'price': '268',
      'originalPrice': null,
      'duration': '3个月',
      'productId': 'com.kuailiao.changs3',
      'isFirstPurchase': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _checkFirstPurchase();
  }

  /// 加载用户信息
  Future<void> _loadUserInfo() async {
    try {
      final userInfo = await StorageUtil.getUserInfo();
      if (mounted) {
        setState(() {
          _userInfo = userInfo;
        });
      }
    } catch (e) {
      print('加载用户信息失败: $e');
    }
  }

  /// 检查是否首次购买
  Future<void> _checkFirstPurchase() async {
    try {
      final hasPurchased = await StorageUtil.getBool('has_purchased_vip') ?? false;
      if (mounted) {
        setState(() {
          _isFirstPurchase = !hasPurchased;
        });
      }
    } catch (e) {
      print('检查首次购买状态失败: $e');
    }
  }

  /// 处理VIP购买
  Future<void> _handleVipPurchase() async {
    if (_isLoading) return;

    final selectedPlan = _vipPlans[_selectedIndex];
    
    // 检查是否是首充档位但用户已经购买过
    if (selectedPlan['isFirstPurchase'] && !_isFirstPurchase) {
      _showFirstPurchaseDialog();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 调用iOS内购
      await _performInAppPurchase(selectedPlan['productId']);
      
      // 更新用户会员信息
      await _updateUserVipStatus(selectedPlan);
      
      if (mounted) {
        ToastUtil.showSuccess(context, 'VIP开通成功！');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ToastUtil.showError(context, '购买失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 执行内购
  Future<void> _performInAppPurchase(String productId) async {
    // 这里应该调用实际的iOS内购SDK
    // 目前使用模拟实现
    await Future.delayed(const Duration(seconds: 2));
    
    // 模拟内购成功
    print('内购成功: $productId');
  }

  /// 更新用户VIP状态
  Future<void> _updateUserVipStatus(Map<String, dynamic> plan) async {
    if (_userInfo == null) return;

    final now = DateTime.now();
    DateTime newExpiryDate;

    if (_userInfo!.memberExpiry.isNotEmpty) {
      // 如果已有会员，在现有到期时间基础上延长
      final currentExpiry = DateTime.tryParse(_userInfo!.memberExpiry) ?? now;
      newExpiryDate = currentExpiry.isAfter(now) 
          ? currentExpiry.add(Duration(days: plan['duration'] == '1个月' ? 30 : 90))
          : now.add(Duration(days: plan['duration'] == '1个月' ? 30 : 90));
    } else {
      // 首次开通会员
      newExpiryDate = now.add(Duration(days: plan['duration'] == '1个月' ? 30 : 90));
    }

    final updatedUser = _userInfo!.copyWith(
      memberExpiry: newExpiryDate.toIso8601String(),
    );

    await StorageUtil.saveUserInfo(updatedUser);
    
    // 标记已购买过VIP
    if (plan['isFirstPurchase']) {
      await StorageUtil.setBool('has_purchased_vip', true);
    }
  }

  /// 显示首充提示对话框
  void _showFirstPurchaseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: const Text('您已经购买过VIP，无法享受首充优惠。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/user/bg_vip.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 顶部图片
              Container(
                width: double.infinity,
                height: 200,
                child: Image.asset(
                  'assets/images/user/vip_top.png',
                  fit: BoxFit.cover,
                ),
              ),
              
              // VIP档位选择
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '选择VIP套餐',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // 档位列表
                      Expanded(
                        child: ListView.builder(
                          itemCount: _vipPlans.length,
                          itemBuilder: (context, index) {
                            final plan = _vipPlans[index];
                            final isSelected = index == _selectedIndex;
                            final isFirstPurchasePlan = plan['isFirstPurchase'];
                            
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedIndex = index;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? AppConstants.primaryColor.withOpacity(0.1)
                                      : Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected 
                                        ? AppConstants.primaryColor
                                        : Colors.grey[300]!,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // 选择指示器
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected 
                                            ? AppConstants.primaryColor
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isSelected 
                                              ? AppConstants.primaryColor
                                              : Colors.grey[400]!,
                                          width: 2,
                                        ),
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check,
                                              size: 14,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    
                                    // 档位信息
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                plan['title'],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              if (isFirstPurchasePlan && _isFirstPurchase)
                                                Container(
                                                  margin: const EdgeInsets.only(left: 8),
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: const Text(
                                                    '首充特惠',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '有效期: ${plan['duration']}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // 价格信息
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              '¥${plan['price']}',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected 
                                                    ? AppConstants.primaryColor
                                                    : Colors.black87,
                                              ),
                                            ),
                                            if (plan['originalPrice'] != null)
                                              Padding(
                                                padding: const EdgeInsets.only(left: 8),
                                                child: Text(
                                                  '¥${plan['originalPrice']}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[500],
                                                    decoration: TextDecoration.lineThrough,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        if (plan['originalPrice'] != null)
                                          Text(
                                            '省¥${int.parse(plan['originalPrice']) - int.parse(plan['price'])}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.orange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // 立即开通按钮
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleVipPurchase,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 3,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  '立即开通',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 