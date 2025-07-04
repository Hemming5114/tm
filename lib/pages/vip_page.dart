import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
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
  bool _isRestoring = false;
  bool _isFirstPurchase = false;

  final List<Map<String, dynamic>> _vipPlans = [
    {
      'title': '月会员首充',
      'price': '88',
      'originalPrice': '99',
      'duration': '1个月',
      'productId': '88_ml_month',
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
    if (_isLoading || _isRestoring) return;

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
        // 刷新页面数据
        await _loadUserInfo();
        // 返回成功结果给profile_page，触发数据刷新
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

  /// 处理恢复购买
  Future<void> _handleRestorePurchase() async {
    if (_isLoading || _isRestoring) return;

    setState(() {
      _isRestoring = true;
    });

    try {
      // 恢复购买
      await InAppPurchase.instance.restorePurchases();
      
      if (mounted) {
        ToastUtil.showSuccess(context, '恢复购买成功！');
        // 刷新页面数据
        await _loadUserInfo();
        // 返回成功结果给profile_page，触发数据刷新
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ToastUtil.showError(context, '恢复购买失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRestoring = false;
        });
      }
    }
  }

  /// 执行内购
  Future<void> _performInAppPurchase(String productId) async {
    try {
      print('=== VIP内购流程开始 ===');
      print('产品ID: $productId');
      
      final InAppPurchase iap = InAppPurchase.instance;
      
      // 检查内购是否可用
      final bool isAvailable = await iap.isAvailable();
      print('内购服务可用性: $isAvailable');
      
      if (!isAvailable) {
        print('错误: 内购服务不可用');
        throw Exception('内购服务不可用');
      }

      // 获取产品信息
      print('正在查询产品信息...');
      final ProductDetailsResponse response = await iap.queryProductDetails({productId});
      
      print('查询结果:');
      print('- 找到产品数量: ${response.productDetails.length}');
      print('- 查询错误: ${response.error?.message ?? "无"}');
      print('- 未找到产品IDs: ${response.notFoundIDs}');
      
      if (response.error != null) {
        print('产品查询错误详情: ${response.error!.message}');
        print('错误代码: ${response.error!.code}');
        throw Exception('产品查询失败: ${response.error!.message}');
      }
      
      if (response.productDetails.isEmpty) {
        print('错误: 未找到产品ID: $productId');
        print('可能原因:');
        print('1. 产品未在App Store Connect中配置');
        print('2. 产品状态不是"准备销售"');
        print('3. Bundle ID不匹配');
        print('4. 需要使用沙盒测试账号');
        throw Exception('产品信息获取失败');
      }

      final ProductDetails productDetails = response.productDetails.first;
      print('产品详情:');
      print('- ID: ${productDetails.id}');
      print('- 标题: ${productDetails.title}');
      print('- 描述: ${productDetails.description}');
      print('- 价格: ${productDetails.price}');
      print('- 价格符号: ${productDetails.currencySymbol}');
      
      // 发起购买
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );
      
      print('开始发起购买请求...');
      await iap.buyNonConsumable(purchaseParam: purchaseParam);
      print('购买请求已发送');
      
    } catch (e) {
      print('=== VIP内购失败 ===');
      print('错误详情: $e');
      print('错误类型: ${e.runtimeType}');
      throw Exception('内购失败: $e');
    }
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

  /// 检查用户是否为VIP
  bool _isUserVip() {
    if (_userInfo?.memberExpiry.isEmpty ?? true) return false;
    
    final expiryDate = DateTime.tryParse(_userInfo!.memberExpiry);
    if (expiryDate == null) return false;
    
    return expiryDate.isAfter(DateTime.now());
  }

  /// 获取VIP到期时间
  DateTime? _getVipExpiryDate() {
    if (_userInfo?.memberExpiry.isEmpty ?? true) return null;
    return DateTime.tryParse(_userInfo!.memberExpiry);
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
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
    final isVip = _isUserVip();
    final expiryDate = _getVipExpiryDate();
    
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
              // 顶部导航栏
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'VIP会员',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // 平衡布局
                  ],
                ),
              ),
              
              // VIP信息展示区域
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    // VIP状态图标
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isVip ? Colors.amber : Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        isVip ? Icons.workspace_premium : Icons.star_outline,
                        size: 30,
                        color: isVip ? Colors.white : Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // VIP状态文字
                    Text(
                      isVip ? 'VIP会员' : '普通用户',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    
                    // VIP状态描述
                    if (isVip && expiryDate != null) ...[
                      Text(
                        '到期时间：${_formatDate(expiryDate)}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '享受VIP专属特权',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ] else ...[
                      Text(
                        '开通VIP享受更多特权',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '无限制使用AI助手等功能',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // VIP档位选择区域
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
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
                    ],
                  ),
                ),
              ),
              
              // 底部按钮区域
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 立即开通按钮
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: (_isLoading || _isRestoring) ? null : _handleVipPurchase,
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
                            : Text(
                                isVip ? '续费VIP' : '立即开通',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // 恢复购买按钮 - 弱化样式
                    GestureDetector(
                      onTap: (_isLoading || _isRestoring) ? null : _handleRestorePurchase,
                      child: Container(
                        width: double.infinity,
                        height: 36,
                        alignment: Alignment.center,
                        child: _isRestoring
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
                                ),
                              )
                            : Text(
                                '恢复购买',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 