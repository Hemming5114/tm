import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'image_preview_page.dart';

/// Banner详情页面
class BannerDetailPage extends StatefulWidget {
  const BannerDetailPage({Key? key}) : super(key: key);

  @override
  State<BannerDetailPage> createState() => _BannerDetailPageState();
}

class _BannerDetailPageState extends State<BannerDetailPage> {
  late PageController _pageController;
  int _currentIndex = 0;
  
  // Banner图片列表
  final List<String> _bannerImages = [
    'assets/images/baner/banner_icon1.jpg',
    'assets/images/baner/banner_icon2.jpg',
    'assets/images/baner/banner_icon3.jpg',
    'assets/images/baner/banner_icon4.jpg',
    'assets/images/baner/banner_icon5.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 全屏图片轮播区域
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.6,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // 轮播图
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemCount: _bannerImages.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImagePreviewPage(
                                imageUrls: _bannerImages,
                                initialIndex: index,
                                heroTag: 'banner',
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: 'banner_$index',
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(_bannerImages[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.3),
                                    Colors.transparent,
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                  stops: const [0.0, 0.3, 0.7, 1.0],
                                ),
                              ),
                              child: Stack(
                                children: [
                                  // 顶部文字 - 居中显示
                                  Positioned(
                                    top: 120,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: const Text(
                                          '四季探索计划',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  // 底部标题
                                  Positioned(
                                    bottom: 120,
                                    left: 20,
                                    right: 20,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '南华寺',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'nan hua si',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w300,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // 底部缩略图区域
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _bannerImages.length,
                        itemBuilder: (context, index) {
                          final isSelected = index == _currentIndex;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _currentIndex = index;
                              });
                              _pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            onLongPress: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ImagePreviewPage(
                                    imageUrls: _bannerImages,
                                    initialIndex: index,
                                    heroTag: 'thumbnail',
                                  ),
                                ),
                              );
                            },
                            child: Container(
                                width: 60,
                                height: 60,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? AppConstants.primaryColor : Colors.white.withOpacity(0.6),
                                    width: isSelected ? 3 : 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.asset(
                                  _bannerImages[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
            
            // 四季探索计划卡片 - 简化版
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/baner/banner_icon.png'),
                      fit: BoxFit.cover,
                    ),
                    ),
                  ),
                ),
              ),
            ),
            
            // 内容区域
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  const Text(
                    '本季优选——南华古寺',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 内容文字
                  const Text(
                    '南华寺是中国佛教禅宗的重要祖庭之一，位于广东省韶关市曲江区马坝镇东南郊的曹溪河畔，素有"东粤第一宝刹"之称。其历史可追溯至南北朝时期，历经多次兴衰与重建，至今已有1500多年的历史。\n\n南华寺不仅是禅宗的重要发源地，还保存了大量珍贵文物，如六祖慧能真身像、唐代千佛袈裟、北宋木雕五百罗汉等。如今，它仍是佛教徒朝圣和游客探访的重要文化圣地。\n\n作为一位旅游爱好者，去过很多次新疆了，经验充足，对这方面绝对有发言权：\n\n第一次是带爸妈去的，在深圳当地组的团，价格贵就不说了，行程也不满意，很多精华景点都没有玩到，而且后期导游会让我们做很多自费的项目。（行程死板，价格偏高，不建议）\n\n第二次是和朋友自驾游，首先做攻略就很费时费力，再就是开车累，新疆路程太长途径很多山区，中途出点什么事会很危险。开销大（人均达到六七千），买景点门票特别麻烦，酒店要不就是订不到房要不就是特别贵，还遇到有的景区限流，玩得也不是很好。（劳心劳力，开销大，特别不建议）',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppConstants.textPrimary,
                      height: 1.6,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 实用信息卡片
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppConstants.primaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '实用信息',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.confirmation_number,
                              color: AppConstants.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '门票：20元',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppConstants.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: AppConstants.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '开放时间：08:00-17:00（全年开放）',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppConstants.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 游览建议
                  const Text(
                    '游览路线建议',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  const Text(
                    '1. 曹溪门→ 五香亭 & 放生池→ 宝林门→ 天王殿→ 大雄宝殿→ 藏经阁→ 灵照塔→ 六祖殿→ 九龙泉。\n\n全程游览约 1-2小时，若深度参拜可能需要更长时间。',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppConstants.textPrimary,
                      height: 1.6,
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // 重点景点介绍
                  const Text(
                    '重点景点介绍',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 景点列表
                  _buildSpotCard(
                    '曹溪门',
                    '南华寺的正门，古朴庄严，门额题有"曹溪"二字，为游览的起点。',
                    Icons.door_front_door,
                    AppConstants.primaryColor,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildSpotCard(
                    '五香亭 & 放生池',
                    '位于曹溪门后，池中有桥和八角亭，寓意"自性五分法身香"，环境清幽，适合拍照留念。',
                    Icons.water,
                    Colors.blue,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildSpotCard(
                    '宝林门',
                    '进入寺院主体的重要门户，建筑精美，彰显佛教文化的庄重与神圣。',
                    Icons.temple_buddhist,
                    Colors.orange,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildSpotCard(
                    '天王殿',
                    '供奉四大天王，保护佛法，是进入大雄宝殿前的重要殿堂。',
                    Icons.security,
                    Colors.red,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildSpotCard(
                    '大雄宝殿',
                    '南华寺的核心建筑，供奉三尊大佛，四周墙壁有500罗汉木雕，为北宋文物，极为珍贵。',
                    Icons.account_balance,
                    Colors.deepPurple,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildSpotCard(
                    '藏经阁',
                    '收藏大量佛教经典和文物，是佛教文化的宝库，部分区域可能不对外开放。',
                    Icons.library_books,
                    Colors.teal,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildSpotCard(
                    '灵照塔',
                    '南华寺最古老的建筑之一，为八角五层砖塔，历史悠久，游客仅可在一层礼佛。',
                    Icons.architecture,
                    Colors.brown,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildSpotCard(
                    '六祖殿',
                    '供奉六祖惠能真身，是南华寺最重要的殿堂之一，游客无法进入殿内，但可在殿外参拜。',
                    Icons.person,
                    Colors.green,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildSpotCard(
                    '九龙泉',
                    '传说中的神泉，泉水清澈甘甜，是游览路线的终点，也是洗涤心灵的圣地。',
                    Icons.waves,
                    Colors.cyan,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 时间标签
                  const Text(
                    '5-17',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppConstants.textTertiary,
                    ),
                  ),
                ],
              ),
              ),
            ),
          ],
      ),
    );
  }

  /// 构建景点卡片
  Widget _buildSpotCard(String title, String description, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 6),
                
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppConstants.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 