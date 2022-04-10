import 'package:flutter/material.dart';
import 'package:ayuprep/ui/widgets/circularImageContainer.dart';
import 'package:ayuprep/ui/widgets/circularTimerContainer.dart';

final timerHeightAndWidthPercentage = 0.14;

class UserDetailsWithTimerContainer extends StatelessWidget {
  final String profileUrl;
  final String points;
  final String name;
  final AnimationController timerAnimationController;
  final bool isCurrentUser;
  const UserDetailsWithTimerContainer({
    Key? key,
    required this.name,
    required this.timerAnimationController,
    required this.profileUrl,
    required this.points,
    required this.isCurrentUser,
  }) : super(key: key);

  Widget _buildTimer(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircularTimerContainer(
          timerAnimationController: timerAnimationController,
          heightAndWidth: MediaQuery.of(context).size.width * timerHeightAndWidthPercentage,
        ),
        CircularImageContainer(height: MediaQuery.of(context).size.width * (timerHeightAndWidthPercentage - 0.015), imagePath: profileUrl, width: MediaQuery.of(context).size.width * (0.15))
      ],
    );
  }

  Widget _buildUserDetails(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * (0.2),
      child: Column(
        crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(
            "$name",
            style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.secondary),
            textAlign: isCurrentUser ? TextAlign.left : TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            mainAxisAlignment: isCurrentUser ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              Text("Points", style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.secondary)),
              SizedBox(
                width: 5.0,
              ),
              Text(": $points", style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.secondary))
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        isCurrentUser ? _buildTimer(context) : _buildUserDetails(context),
        SizedBox(
          width: 10.0,
        ),
        isCurrentUser ? _buildUserDetails(context) : _buildTimer(context),
      ],
    );
  }
}
