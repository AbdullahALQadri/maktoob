import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/text_utils.dart';
import 'app_colors.dart';
import 'app_font_weight.dart';
import 'app_images.dart';

class Constants {
  static bool isAdmin = false;

  static const String emptyImage =
      "https://envothemes.com/envo-magazine-pro/wp-content/uploads/sites/8/2018/04/no-image.jpg";
  static String validationEmail =
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";

  static void showErrorDialog({
    required BuildContext context,
    required String msg,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: Text(
              msg,
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Ok'),
              ),
            ],
          ),
    );
  }

  // static void showToast({
  //   required String msg,
  //   Color? color,
  //   ToastGravity? gravity,
  // }) {
  //   Fluttertoast.showToast(
  //     toastLength: Toast.LENGTH_LONG,
  //     msg: msg,
  //     backgroundColor: color ?? AppColors.primaryColor,
  //     gravity: gravity ?? ToastGravity.BOTTOM,
  //   );
  // }

  static Widget scaffoldComponent({
    required String appBarTitle,
    bool centerTitle = true,
    Widget? body,
    Widget? bottomNavigationBar,
    Widget? leading,
    List<Widget>? actions,
  }) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      // backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade300,
        // backgroundColor: AppColors.white,
        elevation: 0,
        // leading: leading ,
        leading: leading,
        title: Text(
          appBarTitle,
          style: TextStyle(
            // color: AppColors.appBarTextColor,
            fontSize: 18,
            fontWeight: AppFontWeight.bold,
          ),
        ),
        centerTitle: centerTitle,
        actions: actions,
      ),
      bottomNavigationBar: bottomNavigationBar,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: body,
      ),
    );
  }

  static Widget scaffoldComponentForSearch({
    required Widget appBar,
    bool centerTitle = true,
    Widget? body,
    Widget? bottomNavigationBar,
    Widget? leading,
    List<Widget>? actions,
  }) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: leading,
        title: appBar,
        centerTitle: centerTitle,
        actions: actions,
      ),
      bottomNavigationBar: bottomNavigationBar,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: body,
      ),
    );
  }

  static Widget scaffoldComponent1({
    // required String appBarTitle ,
    PreferredSizeWidget? appBar,
    // bool centerTitle = true,
    Widget? body,
    Widget? bottomNavigationBar,
    // Widget? leading,
    // List<Widget>? actions,
    Color? backgroundColor,
  }) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      // appBar: AppBar(
      //   leading: leading,
      //   title: textUtils(
      //     text: appBarTitle,
      //     color: AppColors.black,
      //     fontWeight: FontWeight.w500,
      //     fontSize: 17,
      //   ),
      //   centerTitle: centerTitle,
      //   actions: actions,
      // ),
      bottomNavigationBar: bottomNavigationBar,

      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: body,
      ),
    );
  }

  static Widget scaffoldComponent2({
    String appBarTitle = "",
    bool centerTitle = true,
    Widget? body,
    Widget? bottomNavigationBar,
    Widget? leading,
    List<Widget>? actions,
    PreferredSizeWidget? bottom,
    Key? key,
    Widget? floatingActionButton,
  }) {
    return Scaffold(
      backgroundColor: AppColors.white,
      key: key,
      floatingActionButton: floatingActionButton,
      appBar: AppBar(
        elevation: 0,
        // toolbarHeight: 60,
        toolbarHeight: 8,
        leading: leading,
        bottom: bottom,

        title: textUtils(
          text: appBarTitle,
          color: AppColors.black,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        // Text(
        //   appBarTitle,
        //   style: TextStyle(
        //     color: AppColors.black,
        //     fontSize: 17,
        //     fontWeight: FontWeight.w500,
        //   ),
        // ),
        centerTitle: centerTitle,
        actions: actions,
      ),
      bottomNavigationBar: bottomNavigationBar,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: body,
      ),
    );
  }

  static Widget scaffoldComponentverificationsScreen({
    required Widget body,
    required String nameText,
    required Widget actionWidget,
    Widget? bottomNavigationBar,
    Color? backgroundColor,
    double? height = 105,
  }) {
    return Scaffold(
      backgroundColor: backgroundColor,
      bottomNavigationBar: bottomNavigationBar,
      body: Column(
        children: [
          // 🔹 Custom AppBar
          Container(
            height: height,
            width: double.infinity,
            // color: Colors.lightBlueAccent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: SafeArea(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        textUtils(
                          text: 'Hello,',
                          color: AppColors.primaryColor,
                          fontWeight: AppFontWeight.medium,
                          fontSize: 16,
                        ),
                        SizedBox(
                          width: 150,
                          child: textUtils(
                            text: nameText,
                            color: AppColors.black,
                            fontWeight: AppFontWeight.bold,
                            fontSize: 20,
                            overFlow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Image.asset(
                      AppImages.logoPrimaryWithOutText,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Align(alignment: Alignment.centerRight, child: actionWidget),
                ],
              ),
            ),
          ),

          // 🔹 Body with clip + background respect
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: Container(
                width: double.infinity,
                color: AppColors.white,
                child: body,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget scaffoldComponent3({
    required Widget body,
    required String nameText,
    required Widget actionWidget,
    Widget? bottomNavigationBar,
    Color? backgroundColor,
    double? height = 105,
  }) {
    return Scaffold(
      backgroundColor: backgroundColor,
      bottomNavigationBar: bottomNavigationBar,
      body: Column(
        children: [
          Container(
            height: height,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// 🔸 Top Bar (Name, Logo, Action)
                  SizedBox(
                    height: 60,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        /// Left: Hello + Name
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              textUtils(
                                text: 'Hello,',
                                color: AppColors.primaryColor,
                                fontWeight: AppFontWeight.medium,
                                fontSize: 16,
                              ),
                              SizedBox(
                                width: 150,
                                child: textUtils(
                                  text: nameText,
                                  color: AppColors.black,
                                  fontWeight: AppFontWeight.bold,
                                  fontSize: 20,
                                  overFlow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// Center: Logo
                        Center(
                          child: Image.asset(
                            AppImages.logoPrimaryWithOutText,
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                        ),

                        /// Right: Notification Icon
                        Align(
                          alignment: Alignment.centerRight,
                          child: actionWidget,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔴 Red image or banner below top bar
                  Image.asset(
                    AppImages.counter, // or any image asset
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),

          /// 🔹 Body Content (rounded top corners)
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: Container(
                color: AppColors.white,
                width: double.infinity,
                child: body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
