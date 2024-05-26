import 'package:flutter/material.dart';

class FadePageRoute extends PageRouteBuilder {
  final Widget page;

  // 페이지 전환 방식..?

  FadePageRoute({required this.page})
      : super(
          pageBuilder: (
            context,
            animation,
            secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
}

// class CustomPageRoute extends PageRouteBuilder {
//   final Widget page;

//   CustomPageRoute({required this.page})
//       : super(
//             pageBuilder: (context, animation, secondaryAnimation) => page,
//             transitionsBuilder:
//                 (context, animation, secondaryAnimation, child) {
//               return child;
//             });
// }
