import 'package:flutter/material.dart';

class UserCrownContainer extends StatelessWidget {
  final String? crownType;
  const UserCrownContainer({Key? key, this.crownType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      height: 28.0,
      width: 28.0,
    );
  }
}
