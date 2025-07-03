import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../utils/storage_util.dart';
import '../utils/toast_util.dart';

/// 金币充值页面
class CoinPage extends StatefulWidget {
  const CoinPage({Key? key}) : super(key: key);

  @override
  State<CoinPage> createState() => _CoinPageState();
}

class _CoinPageState extends State<CoinPage> {
  UserModel? _userInfo;
  int _selectedIndex = 0;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _coinPlans = [
    {
      'coins': 60,
      'price': '6',
      'productId': 'com.kuailiao.changs60',
      'bonus': null,
    },
    {
      'coins': 300,
      'price': '28',
      'productId': 'com.kuailiao.changs300',
      'bonus': null,
    },
    {
      'coins': 1130,
      'price': '98',
      'productId': 'com.kuailiao.changs1130',
      'bonus': '送130金币',
    },
    {
      'coins': 2350,
      'price': '198',
      'productId': 'com.kuailiao.changs2350',
      'bonus': '送350金币',
    },
    {
      'coins': 3070,
      'price': '268',
      'productId': 'com.kuailiao.changs3070',
      'bonus': '送1070金币',
    },
    {
      'coins': 3600,
      'price': '298',
      'productId': 'com.kuailiao.changs3600',
      'bonus': '送1600金币',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
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

  /// 处理金币购买
  Future<void> _handleCoinPurchase() async {
    if (_isLoading) return;

    final selectedPlan = _coinPlans[_selectedIndex];

    setState(() {
      _isLoading = true;
    });

    try {
      // 调用iOS内购
      await _performInAppPurchase(selectedPlan['productId']);
      
      // 更新用户金币信息
      await _updateUserCoins(selectedPlan['coins']);
      
      if (mounted) {
        ToastUtil.showSuccess(context, '金币充值成功！');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ToastUtil.showError(context, '充值失败: $e');
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

  /// 更新用户金币
  Future<void> _updateUserCoins(int coins) async {
    if (_userInfo == null) return;

    final updatedUser = _userInfo!.copyWith(
      coins: _userInfo!.coins + coins,
    );

    await StorageUtil.saveUserInfo(updatedUser);
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
              // 顶部标题
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                        '金币充值',
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
              
              // 当前金币显示
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '当前金币: ${_userInfo?.coins ?? 0}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 金币档位选择
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
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
                        '选择充值套餐',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // 档位列表
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.2,
                          ),
                          itemCount: _coinPlans.length,
                          itemBuilder: (context, index) {
                            final plan = _coinPlans[index];
                            final isSelected = index == _selectedIndex;
                            
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedIndex = index;
                                });
                              },
                              child: Container(
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
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // 金币图标
                                    Icon(
                                      Icons.monetization_on,
                                      size: 32,
                                      color: isSelected 
                                          ? AppConstants.primaryColor
                                          : Colors.amber,
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // 金币数量
                                    Text(
                                      '${plan['coins']}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected 
                                            ? AppConstants.primaryColor
                                            : Colors.black87,
                                      ),
                                    ),
                                    const Text(
                                      '金币',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 4),
                                    
                                    // 价格
                                    Text(
                                      '¥${plan['price']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected 
                                            ? AppConstants.primaryColor
                                            : Colors.black87,
                                      ),
                                    ),
                                    
                                    // 赠送金币
                                    if (plan['bonus'] != null)
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          plan['bonus'],
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // 立即充值按钮
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleCoinPurchase,
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
                                  '立即充值',
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