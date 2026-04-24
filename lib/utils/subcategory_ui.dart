import 'package:flutter/material.dart';

import '../services/subcategory_classifier.dart';
import '../theme/app_theme_colors.dart';

/// 소카테고리 아이콘 (연습 시트 · 학습 시트 공유).
IconData iconForSubcategory(String id) {
  switch (id) {
    case SubcategoryIds.alcohol:
      return Icons.local_bar_outlined;
    case SubcategoryIds.childZone:
      return Icons.child_care_outlined;
    case SubcategoryIds.emergency:
      return Icons.medical_services_outlined;
    case SubcategoryIds.license:
      return Icons.badge_outlined;
    case SubcategoryIds.signSignal:
      return Icons.traffic_outlined;
    case SubcategoryIds.speedLane:
      return Icons.speed_outlined;
    case SubcategoryIds.parking:
      return Icons.local_parking_outlined;
    case SubcategoryIds.highway:
      return Icons.alt_route_outlined;
    case SubcategoryIds.vehicleEco:
      return Icons.eco_outlined;
    case SubcategoryIds.general:
    default:
      return Icons.menu_book_outlined;
  }
}

/// 소카테고리 아이콘 배경색 (파스텔 순환).
Color colorForSubcategory(BuildContext context, String id) {
  switch (id) {
    case SubcategoryIds.alcohol:
      return const Color(0xFFFFE3E3);
    case SubcategoryIds.childZone:
      return const Color(0xFFFFF3D6);
    case SubcategoryIds.emergency:
      return const Color(0xFFFFE8E8);
    case SubcategoryIds.license:
      return const Color(0xFFE9F3FF);
    case SubcategoryIds.signSignal:
      return const Color(0xFFE9F3FF);
    case SubcategoryIds.speedLane:
      return const Color(0xFFFFF3D6);
    case SubcategoryIds.parking:
      return context.appColors.chipBg;
    case SubcategoryIds.highway:
      return const Color(0xFFEFFBF1);
    case SubcategoryIds.vehicleEco:
      return const Color(0xFFEFFBF1);
    case SubcategoryIds.general:
    default:
      return context.appColors.chipBg;
  }
}
