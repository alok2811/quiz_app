import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/features/quiz/models/userBattleRoomDetails.dart';
import 'package:ayuprep/ui/screens/quiz/widgets/userCrownContainer.dart';

class MultipleUserDetailsContainer extends StatelessWidget {
  final List<UserBattleRoomDetails?> usersDetails;
  final int totalQuestion;
  MultipleUserDetailsContainer({Key? key, required this.usersDetails, required this.totalQuestion}) : super(key: key);
  final double userDetailsHeightPercentage = 0.095;

  Widget _buildNameAndCrown({required UserBattleRoomDetails userBattleRoomDetails, required BuildContext context, required bool startWithProfilePicture, required placeAtTopSide}) {
    return Expanded(
      child: SizedBox(
          child: Column(
        crossAxisAlignment: startWithProfilePicture ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        mainAxisAlignment: placeAtTopSide ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          Text(
            "${userBattleRoomDetails.name}",
            textAlign: startWithProfilePicture ? TextAlign.start : TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.0),
            maxLines: 1,
          ),
          SizedBox(
            height: 5.0,
          ),
          //
          UserCrownContainer(),
          SizedBox(
            height: 5.0,
          ),
          Text(
            userBattleRoomDetails.answers.length == totalQuestion ? AppLocalization.of(context)!.getTranslatedValues("completedLbl")! : AppLocalization.of(context)!.getTranslatedValues("playingLbl")!,
            textAlign: startWithProfilePicture ? TextAlign.start : TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11.50),
            maxLines: 1,
          ),
        ],
      )),
    );
  }

  Widget _buildProfilePicture(BuildContext context, String profileUrl) {
    return Container(
      width: MediaQuery.of(context).size.width * (0.195), //profile picture width
      decoration: BoxDecoration(border: Border.all(color: Theme.of(context).backgroundColor)),
      padding: EdgeInsets.all(5.0),
      child: CachedNetworkImage(
        imageUrl: profileUrl,
        placeholder: (context, _) => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
        ),
      ),
    );
  }

  //
  Widget _buildUserDetails({required UserBattleRoomDetails? userBattleRoomDetails, required BuildContext context, required bool startWithProfilePicture, required bool placeAtTopSide}) {
    return Container(
      height: MediaQuery.of(context).size.height * userDetailsHeightPercentage, //userDetails
      width: MediaQuery.of(context).size.width * 0.4,
      child: Row(
        children: [
          startWithProfilePicture
              ? _buildProfilePicture(context, userBattleRoomDetails!.profileUrl)
              : _buildNameAndCrown(userBattleRoomDetails: userBattleRoomDetails!, context: context, startWithProfilePicture: startWithProfilePicture, placeAtTopSide: placeAtTopSide),
          SizedBox(
            width: 5.0,
          ),
          startWithProfilePicture
              ? _buildNameAndCrown(userBattleRoomDetails: userBattleRoomDetails, context: context, startWithProfilePicture: startWithProfilePicture, placeAtTopSide: placeAtTopSide)
              : _buildProfilePicture(context, userBattleRoomDetails.profileUrl)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top, //status bar padding
      ),
      child: Stack(
        children: [
          Align(
            alignment: usersDetails.length > 2 ? Alignment.topLeft : Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 20.0, top: 10.0),
              child: _buildUserDetails(userBattleRoomDetails: usersDetails.first, context: context, placeAtTopSide: true, startWithProfilePicture: true),
            ),
          ),

          // if there is only one user left in game room
          //show only
          usersDetails.length == 1
              ? Container()
              : Align(
                  alignment: usersDetails.length > 2 ? Alignment.topRight : Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 20.0, top: 10.0),
                    child: _buildUserDetails(userBattleRoomDetails: usersDetails[1], context: context, placeAtTopSide: true, startWithProfilePicture: false),
                  ),
                ),
          usersDetails.length > 2
              ? Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 20.0, bottom: 10.0),
                    child: _buildUserDetails(userBattleRoomDetails: usersDetails[2], context: context, placeAtTopSide: false, startWithProfilePicture: true),
                  ),
                )
              : Container(),
          usersDetails.length == 4
              ? Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 20.0, bottom: 10.0),
                    child: _buildUserDetails(userBattleRoomDetails: usersDetails.last, context: context, placeAtTopSide: false, startWithProfilePicture: false),
                  ),
                )
              : Container(),

          /*
          usersDetails.length == 4
              ? Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 20.0, top: 10.0),
                    child: _buildUserDetails(userIndex: 3, context: context, placeAtTopSide: true, startWithProfilePicture: false),
                  ),
                )
              : Container()
              */
        ],
      ),
    );
  }
}
