// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class LanguageSwitcher extends StatelessWidget {
//   final VoidCallback? onLanguageChanged;

//   const LanguageSwitcher({
//     super.key,
//     this.onLanguageChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final languageManager = LanguageManager();
//     final isEnglish = languageManager.isEnglish;

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: AppBorderRadius.xl,
//         boxShadow: AppShadows.small,
//       ),
//       child: ReusableMaterialButton(
//         onPressed: () => _showLanguageDialog(context),
//         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//         shape: ReusableButtonShape.pill,
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               Icons.language,
//               size: 16.sp,
//               color: ColorManager.white,
//             ),
//             AppSpacing.hXs,
//             BuildText(
//               txt: isEnglish ? 'English' : 'العربية',
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//               color: ColorManager.white,
//             ),
//             AppSpacing.hXs,
//             Icon(
//               Icons.keyboard_arrow_down,
//               size: 16.sp,
//               color: ColorManager.white,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showLanguageDialog(BuildContext context) {
//     final languageManager = LanguageManager();
//     final isEnglish = languageManager.isEnglish;

//     showReusableAlertDialog(
//       context: context,
//       dialog: ReusableAlertDialogExtensions.custom(
//         title: "Select Language",
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _buildLanguageOption(context, 'English', 'en', isEnglish),
//             AppSpacing.vMd,
//             _buildLanguageOption(context, 'العربية', 'ar', !isEnglish),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLanguageOption(
//     BuildContext context,
//     String title,
//     String languageCode,
//     bool isSelected,
//   ) {
//     return ReusableMaterialButton(
//       onPressed: () async {
//         final navigator = Navigator.of(context);
//         await LanguageManager().changeLanguage(context, languageCode);
//         onLanguageChanged?.call();
//         navigator.pop();
//       },
//       padding: AppPaddings.md,
//       backgroundColor: isSelected 
//           ? ColorManager.primaryColor.withValues(alpha: 0.1)
//           : Colors.transparent,
//       shape: ReusableButtonShape.rounded,
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: AppBorderRadius.sm,
//           border: Border.all(
//             color: isSelected 
//                 ? ColorManager.primaryColor
//                 : ColorManager.gray300,
//             width: 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               Icons.flag,
//               size: 20.sp,
//               color: isSelected 
//                   ? ColorManager.primaryColor
//                   : ColorManager.textSecondary,
//             ),
//             AppSpacing.hMd,
//             Expanded(
//               child: BuildText(
//                 txt: title,
//                 fontSize: 16,
//                 fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
//                 color: isSelected 
//                     ? ColorManager.primaryColor
//                     : ColorManager.textPrimary,
//               ),
//             ),
//             if (isSelected)
//               Icon(
//                 Icons.check,
//                 size: 20.sp,
//                 color: ColorManager.primaryColor,
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
