import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_app_project/core/constants/app_assets.dart';

class ReadlyBottomNavigation extends StatelessWidget {
  const ReadlyBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavigationItem(
              index: 0,
              selectedAsset: AppAssets.homeIconSel,
              unselectedAsset: AppAssets.homeIcon,
            ),
            _buildNavigationItem(
              index: 1,
              selectedAsset: AppAssets.routinesIconSel,
              unselectedAsset: AppAssets.routinesIcon,
            ),

            _buildNavigationItem(
              index: 1,
              selectedAsset: AppAssets.quizIconSel,
              unselectedAsset: AppAssets.quizIcon,
            ),

            _buildNavigationItem(
              index: 2,
              selectedAsset: AppAssets.gameIconSel,
              unselectedAsset: AppAssets.gameIcon,
            ),
            _buildNavigationItem(
              index: 3,
              selectedAsset: AppAssets.profileIconSel,
              unselectedAsset: AppAssets.profileIcon,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationItem({
    required int index,
    required String selectedAsset,
    required String unselectedAsset,
  }) {
    final bool isSelected = selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => onItemTapped(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              isSelected ? selectedAsset : unselectedAsset,
              width: 22.w,
              height: 22.h,
            ),
            SizedBox(height: 4.h),
            
          ],
        ),
      ),
    );
  }
}