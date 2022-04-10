import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ayuprep/ui/screens/quiz/widgets/userCrownContainer.dart';

class UserDetailsContainer extends StatelessWidget {
  final String? userName;
  final String? profilePicture;
  final String? crownType;
  final bool startWithProfilePicture;
  final double userDetailsHeightPercentage;
  const UserDetailsContainer({Key? key, required this.userDetailsHeightPercentage, this.startWithProfilePicture = true, this.crownType, this.profilePicture, this.userName}) : super(key: key);

  Widget _buildProfilePicture(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5.0),
      width: MediaQuery.of(context).size.width * (0.215), //profile picture width
      child: CachedNetworkImage(
        imageUrl: "https://st.depositphotos.com/1787196/2514/i/600/depositphotos_25142717-stock-photo-3d-cartoon-cute-yellow-ball.jpg",
        fit: BoxFit.fill,
        placeholder: (context, _) => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
        ),
      ),
      decoration: BoxDecoration(border: Border.all(color: Theme.of(context).primaryColor), shape: BoxShape.circle),
    );
  }

  Widget _buildNameAndCrown(BuildContext context) {
    return Expanded(
      child: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: startWithProfilePicture ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            SizedBox(
              height: 2.5,
            ),
            UserCrownContainer(),
            SizedBox(
              height: 5.0,
            ),
            Text(
              "Safed Kapda",
              textAlign: startWithProfilePicture ? TextAlign.start : TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13.0),
              maxLines: 2,
            ),
            SizedBox(
              height: 2.5,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * userDetailsHeightPercentage,
      width: MediaQuery.of(context).size.width * (0.425), //userdetails container's width
      child: Row(
        children: [
          startWithProfilePicture ? _buildProfilePicture(context) : _buildNameAndCrown(context),
          SizedBox(
            width: 10.0,
          ),
          startWithProfilePicture ? _buildNameAndCrown(context) : _buildProfilePicture(context),
        ],
      ),
    );
  }
}
