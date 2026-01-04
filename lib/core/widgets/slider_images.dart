// import 'package:flutter/material.dart';
//
// import '../../core/utils/app_colors.dart';
//
//
// class SliderImages extends StatefulWidget {
//   const SliderImages({
//     Key? key,
//     required this.imgList,
//     this.height = 261,
//   }) : super(key: key);
//   final List<String> imgList;
//   final double height;
//
//   @override
//   State<SliderImages> createState() => _SliderImagesState();
// }
//
// class _SliderImagesState extends State<SliderImages> {
//   int count = 0;
//   final CarouselController _carouselController = CarouselController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         ConstrainedBox(
//           constraints: BoxConstraints(
//             maxHeight: widget.height,
//             maxWidth: double.infinity,
//           ),
//           child: Stack(
//             alignment: AlignmentDirectional.bottomCenter,
//             children: [
//               CarouselSlider(
//                 options: CarouselOptions(
//                   onPageChanged: (index, reason) {
//                     setState(() {
//                       count = index;
//                     });
//                   },
//                   aspectRatio: 2,
//                   viewportFraction: 1,
//                   height: double.infinity,
//                   pageSnapping: true,
//                   initialPage: 0,
//                   enableInfiniteScroll: true,
//                   reverse: false,
//                   enlargeStrategy: CenterPageEnlargeStrategy.scale,
//                   autoPlay: true,
//                   autoPlayInterval: const Duration(seconds: 3),
//                   autoPlayAnimationDuration: const Duration(milliseconds: 800),
//                   autoPlayCurve: Curves.decelerate,
//                   enlargeCenterPage: true,
//                 ),
//                 items: widget.imgList
//                     .map(
//                       (item) => Stack(
//                         children: [
//                           Container(
//                             clipBehavior: Clip.antiAlias,
//                             width: double.infinity,
//                             decoration: BoxDecoration(
//                                 image: DecorationImage(
//                               fit: BoxFit.cover,
//                               // image: AssetImage(item),
//                               image: NetworkImage(item),
//                             )),
//                           ),
//                         ],
//                       ),
//                     )
//                     .toList(),
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: widget.imgList.asMap().entries.map((entry) {
//                   return GestureDetector(
//                     onTap: () => _carouselController.animateToPage(entry.key),
//                     child: Container(
//                       width: count != entry.key ? 8.0 : 12,
//                       height: count != entry.key ? 8.0 : 12,
//                       margin: EdgeInsets.symmetric(
//                         vertical: 12.h,
//                         horizontal: 5.w,
//                       ),
//                       decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color:
//                               (Theme.of(context).brightness == Brightness.dark
//                                       ? AppColors.white
//                                       : AppColors.white)
//                                   .withOpacity(count == entry.key ? 0.9 : 0.4)),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
