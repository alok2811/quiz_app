import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/app/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/settings/settingsCubit.dart';
import 'package:ayuprep/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:ayuprep/ui/widgets/pageBackgroundGradientContainer.dart';

import 'package:ayuprep/utils/uiUtils.dart';

class Slide {
  final String title;
  final String description;

  Slide({
    required this.title,
    required this.description,
  });
}

class IntroSliderScreen extends StatefulWidget {
  @override
  _GettingStartedScreenState createState() => _GettingStartedScreenState();
}

class _GettingStartedScreenState extends State<IntroSliderScreen> with TickerProviderStateMixin {
  late AnimationController buttonController = AnimationController(vsync: this, duration: Duration(milliseconds: 400));
  late Animation<double> buttonSqueezeanimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: buttonController, curve: Curves.easeInOut));

  late AnimationController circleAnimationController = AnimationController(vsync: this, duration: Duration(seconds: 500))..forward();
  late Animation<double> circleAnimation = Tween<double>().animate(CurvedAnimation(
    parent: circleAnimationController,
    curve: Curves.easeInCubic,
  ));

  late AnimationController imageSlideAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500))..repeat(reverse: true);
  late Animation<Offset> imageSlideAnimation = Tween<Offset>(begin: Offset.zero, end: Offset(0.0, -0.025)).animate(CurvedAnimation(parent: imageSlideAnimationController, curve: Curves.easeInOut));

  late AnimationController pageIndicatorAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
  late Tween<Alignment> pageIndicator = AlignmentTween(begin: Alignment.centerLeft, end: Alignment.centerLeft);
  late Animation<Alignment> pageIndicatorAnimation = pageIndicator.animate(CurvedAnimation(parent: pageIndicatorAnimationController, curve: Curves.easeInOut));
  late AnimationController animationController;
  late Animation animation;

  late AnimationController animationController1;
  late Animation animation1;
  late List<Slide> slideList = [
    Slide(
      title: AppLocalization.of(context)!.getTranslatedValues("title1")!,
      description: AppLocalization.of(context)!.getTranslatedValues("description1")!,
    ),
    Slide(
      title: AppLocalization.of(context)!.getTranslatedValues("title2")!,
      description: AppLocalization.of(context)!.getTranslatedValues("description2")!,
    ),
    Slide(
      title: AppLocalization.of(context)!.getTranslatedValues("title3")!,
      description: AppLocalization.of(context)!.getTranslatedValues("description3")!,
    ),
  ];
  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: Duration(
        seconds: 2,
      ),
      vsync: this,
    );
    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInCubic,
    );
    animationController.addStatusListener(animationStatusListener);
    animationController.forward();

    animationController1 = AnimationController(
      duration: Duration(
        seconds: 2,
      ),
      vsync: this,
    );
    animation1 = CurvedAnimation(
      parent: animationController1,
      curve: Curves.easeInCubic,
    );
    animationController1.addStatusListener(animationStatusListener1);
    animationController1.forward();
  }

  @override
  void dispose() {
    buttonController.dispose();
    imageSlideAnimationController.dispose();
    pageIndicatorAnimationController.dispose();
    circleAnimationController.dispose();
    animationController1.dispose();
    animationController.dispose();
    super.dispose();
  }

  void animationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      animationController.reverse();
    } else if (status == AnimationStatus.dismissed) {
      animationController.forward();
    }
  }

  void animationStatusListener1(AnimationStatus stat) {
    if (stat == AnimationStatus.completed) {
      animationController1.reverse();
    } else if (stat == AnimationStatus.dismissed) {
      animationController1.forward();
    }
  }

  void onPageChanged(int index) {
    if (index == 0) {
      buttonController.reverse();
      pageIndicator.begin = pageIndicator.end;
      pageIndicator.end = Alignment.centerLeft;
    } else if (index == 1) {
      buttonController.reverse();
      pageIndicator.begin = pageIndicator.end;
      pageIndicator.end = Alignment.center;
    } else {
      pageIndicator.begin = pageIndicator.end;
      pageIndicator.end = Alignment.centerRight;
      buttonController.forward();
    }
    Future.delayed(Duration.zero, () {
      pageIndicatorAnimationController.forward(from: 0.0);
    });
  }

  Widget _buildPageIndicator() {
    final double widthAndHeight = 15.0;
    final double borderRadius = 7.5;
    return Align(
      alignment: AlignmentDirectional.bottomCenter,
      child: Container(
        height: MediaQuery.of(context).size.height * (0.1),
        width: MediaQuery.of(context).size.width * (0.175),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * (0.025)),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                height: widthAndHeight,
                width: widthAndHeight,
                decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.5), borderRadius: BorderRadius.circular(borderRadius)),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Container(
                height: widthAndHeight,
                width: widthAndHeight,
                decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.5), borderRadius: BorderRadius.circular(borderRadius)),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Container(
                height: widthAndHeight,
                width: widthAndHeight,
                decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.5), borderRadius: BorderRadius.circular(borderRadius)),
              ),
            ),
            AnimatedBuilder(
              animation: pageIndicatorAnimationController,
              builder: (context, child) {
                return Align(
                  alignment: pageIndicatorAnimation.value,
                  child: child,
                );
              },
              child: Container(
                height: widthAndHeight,
                width: widthAndHeight,
                decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(borderRadius)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFilledCircle(double radius, Color color) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
    );
  }

  Widget _buildBorderedCircle(double radius, double borderWidth, Color color, double padding) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: borderWidth),
      ),
      padding: EdgeInsets.all(padding),
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: radius,
      ),
    );
  }

  Widget _buildIntroSlider(List<String> images) {
    return PageView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      onPageChanged: onPageChanged,
      itemBuilder: (context, index) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * (0.175),
            ),
            SlideTransition(
              position: imageSlideAnimation,
              child: Container(
                height: MediaQuery.of(context).size.height * (0.4),
                alignment: Alignment.center,
                child: Image.asset(
                  UiUtils.getImagePath(images[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * (0.01),
            ),
            Text(
              slideList[index].title,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 25.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * (0.0175),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                slideList[index].description,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 17.0),
              ),
            ),
          ],
        );
      },
      itemCount: slideList.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: AnimatedBuilder(
          builder: (context, child) {
            return Transform.scale(
              scale: buttonSqueezeanimation.value,
              child: child,
            );
          },
          animation: buttonController,
          child: FloatingActionButton(
              child: Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).backgroundColor,
              ),
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () async {
                context.read<SettingsCubit>().changeShowIntroSlider();
                Navigator.of(context).pushReplacementNamed(Routes.login);
              })),
      body: Stack(
        children: [
          PageBackgroundGradientContainer(),
          Positioned(
              top: -55,
              left: -55,
              child: CircleAvatar(
                radius: 60.0,
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              )),
          Positioned(
            top: MediaQuery.of(context).size.height * (0.22), left: -20,
            child: AnimatedBuilder(
              child: _buildFilledCircle(60, Theme.of(context).primaryColor.withOpacity(0.4)),
              animation: animationController,
              builder: (BuildContext context, Widget? child) {
                return Transform.rotate(
                  child: child,
                  angle: math.pi / 12 * animation.value,
                  origin: Offset(0, 180),
                );
              },
            ),
            //_buildFilledCircle(60, Theme.of(context).primaryColor.withOpacity(0.4))
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * (0.22), right: 70,
            child: AnimatedBuilder(
              child: _buildFilledCircle(50, Theme.of(context).primaryColor.withOpacity(0.6)),
              animation: animationController1,
              builder: (BuildContext context, Widget? child) {
                return Transform.rotate(
                  child: child,
                  angle: math.pi / 12 * animation1.value,
                  origin: Offset(-0, -180),
                );
              },
            ),
            //_buildFilledCircle(50, Theme.of(context).primaryColor.withOpacity(0.6))
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * (0.075), left: 70,
            child: AnimatedBuilder(
              child: _buildBorderedCircle(30, 8, Theme.of(context).primaryColor.withOpacity(0.5), 5),
              animation: animationController,
              builder: (BuildContext context, Widget? child) {
                return Transform.rotate(
                  child: child,
                  angle: math.pi / 12 * animation.value,
                  origin: Offset(0, 280),
                );
              },
            ),
            //_buildBorderedCircle(30, 8, Theme.of(context).primaryColor.withOpacity(0.5), 5)
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * (0.045), right: -20,
            child: AnimatedBuilder(
              child: _buildBorderedCircle(35, 6, Theme.of(context).primaryColor.withOpacity(0.45), 5),
              animation: animationController1,
              builder: (BuildContext context, Widget? child) {
                return Transform.rotate(
                  child: child,
                  angle: math.pi / 12 * animation1.value,
                  origin: Offset(-0, -280),
                );
              },
            ),

            //_buildBorderedCircle(35, 6, Theme.of(context).primaryColor.withOpacity(0.45), 5)
          ),
          _buildIntroSlider((context.read<SystemConfigCubit>().state as SystemConfigFetchSuccess).introSliderImages),
          _buildPageIndicator(),
        ],
      ),
    );
  }
}
