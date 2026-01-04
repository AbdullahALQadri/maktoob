//
// import 'package:flutter/material.dart';
// import 'package:takata/features/widgets/sized_box_widget.dart';
// import 'package:takata/features/widgets/text_utils.dart';
//
// import '../../core/utils/app_colors.dart';
// import '../../core/utils/app_font_weight.dart';
// import '../../core/utils/app_icons.dart';
//
// class CardWidget extends StatefulWidget {
//   CardWidget({
//     Key? key,
//     required this.index,
//     required this.image,
//     required this.statusText,
//     required this.statusColor,
//     required this.titleText,
//     required this.locationText,
//     required this.amText,
//     required this.pmText,
//     // this.priceWidget,
//     this.priceText = '',
//     this.price = '',
//     // required this.iconWidget,
//     // required this.iconOnPressed,
//     this.cardOnPressed,
//   }) : super(key: key);
//
//   final String image;
//   final String statusText;
//   final Color statusColor;
//
//   final String titleText;
//   final String locationText;
//   final String amText;
//   final String pmText;
//
//   // Widget? priceWidget;
//
//   String priceText;
//   String price;
//
//   // final Widget iconWidget;
//   // final Function() iconOnPressed;
//   final void Function()? cardOnPressed;
//
//   final int index;
//
//   @override
//   State<CardWidget> createState() => _CardWidgetState();
// }
//
// class _CardWidgetState extends State<CardWidget> {
//   bool isFav = false;
//
//   final PlaceController _placeController = Get.put(PlaceController());
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: widget.cardOnPressed,
//       child: Container(
//         width: double.infinity,
//         // height: 211.h,
//         margin: EdgeInsetsDirectional.only(top: 10.h, bottom: 10.h),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10.r),
//           border: Border.all(
//             color: AppColors.borderColor1,
//             width: 0.5,
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Stack(
//               children: [
//                 Container(
//                   height: 129.h,
//                   width: double.infinity,
//                   clipBehavior: Clip.antiAlias,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(12.r),
//                       topRight: Radius.circular(12.r),
//                     ),
//                     border: Border.all(
//                       color: AppColors.borderColor1,
//                       width: 0.5,
//                     ),
//                   ),
//                   child: Image.network(
//                     widget.image,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: Container(
//                     height: 26.w,
//                     width: 72.w,
//                     alignment: Alignment.center,
//                     margin: EdgeInsetsDirectional.only(
//                       top: 89.h,
//                       start: 16.h,
//                       end: 14.h,
//                     ),
//                     decoration: BoxDecoration(
//                       color: widget.statusColor,
//                       borderRadius: BorderRadius.circular(5.r),
//                     ),
//                     child: textUtils(
//                       text: widget.statusText,
//                       // text: AppStrings.addPicture,
//                       color: AppColors.white,
//                       fontWeight: AppFontWeight.medium,
//                       fontSize: 8.sp,
//                     ),
//                   ),
//                 ),
//                 // Align(
//                 //   alignment: Alignment.topLeft,
//                 //   child: IconButton(
//                 //     icon: widget.iconWidget,
//                 //     onPressed: widget.iconOnPressed,
//                 //   ),
//                 // ),
//                 // Align(
//                 //   alignment: Alignment.topLeft,
//                 //   child: IconButton(
//                 //     icon: isFav
//                 //         ? Icon(
//                 //             Icons.favorite,
//                 //             color: AppColors.red,
//                 //             size: 4.h,
//                 //           )
//                 //         : Icon(
//                 //             Icons.favorite_border,
//                 //             color: AppColors.white,
//                 //             size: 4.h,
//                 //           ),
//                 //     onPressed: () {
//                 //       setState(() {
//                 //         isFav = !isFav;
//                 //       });
//                 //     },
//                 //   ),
//                 // ),
//                 Align(
//                   alignment: Alignment.topLeft,
//                   child: IconButton(
//                     icon: _placeController.isFavourites(
//                             _placeController.majlissPlaces[widget.index].id)
//                         ? SvgPicture.asset(
//                             AppIcons.favorite,
//                             width: 24.w,
//                             height: 24.w,
//                           )
//                         : SvgPicture.asset(
//                             AppIcons.favoriteBorder,
//                             width: 24.w,
//                             height: 24.w,
//                           ),
//                     onPressed: () {
//                       setState(() {
//                         _placeController.manageFavourites(
//                             _placeController.majlissPlaces[widget.index].id);
//                       });
//                     },
//                   ),
//                 ),
//
//               ],
//             ),
//             Padding(
//               padding: EdgeInsetsDirectional.only(
//                 start: 15.h,
//                 end: 15.h,
//                 bottom: 10.h,
//                 top: 15.h,
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 // crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: textUtils(
//                       text: widget.titleText,
//                       // text: AppStrings.addPicture,
//                       color: AppColors.black,
//                       fontWeight: AppFontWeight.bold,
//                       fontSize: 12.sp,
//                       overFlow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   sizedBoxWidget(
//                     height: 0,
//                     width: 10.w,
//                   ),
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.access_time_outlined,
//                         color: AppColors.primaryColor,
//                         // size: 2.h,
//                         size: 11.w,
//                       ),
//                       SizedBox(width: 8.w),
//                       textUtils(
//                         text: (widget.amText),
//                         color: AppColors.primaryColor,
//                         fontWeight: AppFontWeight.regular,
//                         fontSize: 8.sp,
//                         overFlow: TextOverflow.ellipsis,
//                       ),
//                       SizedBox(width: 2.w),
//                       textUtils(
//                         text: "-",
//                         color: AppColors.primaryColor,
//                         fontWeight: AppFontWeight.regular,
//                         fontSize: 8.sp,
//                       ),
//                       SizedBox(width: 2.w),
//                       textUtils(
//                         text: (widget.pmText),
//                         // +
//                         // (AppLocalizations.of(context)!
//                         //     .translate("pm")
//                         //     .toString()),
//                         color: AppColors.primaryColor,
//                         fontWeight: AppFontWeight.regular,
//                         fontSize: 8.sp,
//                         overFlow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: EdgeInsetsDirectional.only(
//                 start: 15.h,
//                 end: 15.h,
//                 bottom: 20.h,
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     flex: 2,
//                     child: Row(
//                       children: [
//                         SvgPicture.asset(
//                           AppIcons.location,
//                           width: 16.w,
//                           height: 16.w,
//                           colorFilter: ColorFilter.mode(
//                             AppColors.greyText,
//                             BlendMode.srcIn,
//                           ),
//                         ),
//                         sizedBoxWidget(
//                           height: 0,
//                           width: 7.w,
//                         ),
//                         Expanded(
//                           child: textUtils(
//                             text: widget.locationText,
//                             color: AppColors.greyText,
//                             fontWeight: AppFontWeight.regular,
//                             fontSize: 8.sp,
//                             overFlow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     flex: 1,
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Align(
//                             alignment: Alignment.centerLeft,
//                             child: textUtils(
//                               text: (widget.priceText.trim()),
//                               color: AppColors.black,
//                               fontWeight: AppFontWeight.bold,
//                               fontSize: 12.sp,
//                               overFlow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 2.w),
//                         textUtils(
//                           text: widget.price,
//                           color: AppColors.black,
//                           fontWeight: AppFontWeight.bold,
//                           fontSize: 12.sp,
//                           overFlow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
