import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CircularProgressContainer extends StatelessWidget {
  final bool useWhiteLoader;
  final double? heightAndWidth;
  CircularProgressContainer({Key? key, required this.useWhiteLoader, this.heightAndWidth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: heightAndWidth ?? 75.0,
      height: heightAndWidth ?? 75.0,
      child: Lottie.asset(
        useWhiteLoader ? "assets/animations/whiteLoading.json" : "assets/animations/loading.json",
      ),
    );
  }
}
