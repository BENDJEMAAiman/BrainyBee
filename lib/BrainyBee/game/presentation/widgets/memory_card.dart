
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_app_project/BrainyBee/game/model/game_card_model.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

class MemoryCard extends StatelessWidget {
  final GameCard card;
  final VoidCallback onTap;

  const MemoryCard({
    super.key,
    required this.card,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRevealed = card.isFlipped || card.isMatched;

    return GestureDetector(
      onTap: isRevealed ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: card.isMatched
              ? AppColors.amberMain.withValues(alpha: 0.25)
              : isRevealed
                  ? Colors.white
                  : AppColors.amberMain,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: card.isMatched
                ? AppColors.amberMain
                : Colors.white,
            width: 2.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isRevealed
                ? Text(
                    card.symbol,
                    key: ValueKey('symbol_${card.id}'),
                    style: TextStyle(fontSize: 32.sp),
                  )
                : Icon(
                    Icons.question_mark_rounded,
                    key: ValueKey('hidden_${card.id}'),
                    color: Colors.white,
                    size: 30.sp,
                  ),
          ),
        ),
      ),
    );
  }
}
