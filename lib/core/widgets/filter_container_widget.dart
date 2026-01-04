import 'package:flutter/material.dart';

import '../../core/utils/app_colors.dart';




class FilterContainerWidget extends StatefulWidget {
  const FilterContainerWidget({super.key,
    required this.onPress,
    required this.icon,
  });
  final void Function()? onPress;
  final Widget icon;

  @override
  State<FilterContainerWidget> createState() => _FilterContainerWidgetState();
}

class _FilterContainerWidgetState extends State<FilterContainerWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onPress,
      child: Container(
        // width: 49.w,
        // height: 46.w,
        width: 49,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(12),
          // borderRadius: BorderRadius.circular(12.r),
        ),
        child: widget.icon,
      ),
    );
  }
}

