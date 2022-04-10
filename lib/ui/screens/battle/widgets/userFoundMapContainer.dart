import 'package:flutter/material.dart';
import 'package:ayuprep/utils/uiUtils.dart';

class UserFoundMapContainer extends StatefulWidget {
  UserFoundMapContainer({Key? key}) : super(key: key);

  @override
  _UserFoundMapContainerState createState() => _UserFoundMapContainerState();
}

class _UserFoundMapContainerState extends State<UserFoundMapContainer> {
  late double scale = 1.275;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      setState(() {
        scale = 1.0;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      transformAlignment: Alignment.center,
      transform: Matrix4.identity()..scale(scale),
      duration: Duration(milliseconds: 300),
      child: Image.asset(
        UiUtils.getImagePath("map_finded.png"),
        fit: BoxFit.cover,
      ),
    );
  }
}
