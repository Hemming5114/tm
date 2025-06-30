import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'home_page.dart';
import 'dynamic_page.dart';
import 'message_page.dart';
import 'profile_page.dart';

/// 主页面
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const HomePage(),
    const DynamicPage(),
    const MessagePage(),
    const ProfilePage(),
  ];

  Widget _buildTabIcon(String assetPath, bool isSelected) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Image.asset(
        assetPath,
        width: 24,
        height: 24,
        color: isSelected ? AppConstants.primaryColor : AppConstants.textTertiary,
        colorBlendMode: BlendMode.srcIn,
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: AppConstants.textTertiary,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: _buildTabIcon('assets/images/tabbar/btn_tab_home_nor.png', false),
            activeIcon: _buildTabIcon('assets/images/tabbar/btn_tab_home_pre.png', true),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildTabIcon('assets/images/tabbar/btn_tab_avatar_nor.png', false),
            activeIcon: _buildTabIcon('assets/images/tabbar/btn_tab_avatar_pre.png', true),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildTabIcon('assets/images/tabbar/btn_tab_chats_nor.png', false),
            activeIcon: _buildTabIcon('assets/images/tabbar/btn_tab_chats_pre.png', true),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildTabIcon('assets/images/tabbar/btn_tab_me_nor.png', false),
            activeIcon: _buildTabIcon('assets/images/tabbar/btn_tab_me_pre.png', true),
            label: '',
          ),
        ],
      ),
    );
  }
} 