import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/features/ads/interstitialAdCubit.dart';
import 'package:ayuprep/features/badges/cubits/badgesCubit.dart';
import 'package:ayuprep/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';

import 'package:ayuprep/features/profileManagement/profileManagementRepository.dart';
import 'package:ayuprep/features/quiz/models/userBattleRoomDetails.dart';

import 'package:ayuprep/ui/widgets/customRoundedButton.dart';
import 'package:ayuprep/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';

import 'package:ayuprep/utils/stringLabels.dart';
import 'package:ayuprep/utils/uiUtils.dart';

class MultiUserBattleRoomResultScreen extends StatefulWidget {
  final List<UserBattleRoomDetails?> users;
  final int entryFee;

  MultiUserBattleRoomResultScreen(
      {Key? key, required this.users, required this.entryFee})
      : super(key: key);

  @override
  _MultiUserBattleRoomResultScreenState createState() =>
      _MultiUserBattleRoomResultScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>?;
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<UpdateScoreAndCoinsCubit>(
              create: (context) =>
                  UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
              child: MultiUserBattleRoomResultScreen(
                users: arguments!['user'],
                entryFee: arguments['entryFee'],
              ),
            ));
  }
}

class _MultiUserBattleRoomResultScreenState
    extends State<MultiUserBattleRoomResultScreen> {
  List<Map<String, dynamic>> usersWithRank = [];
  int _winAmount = -1; //if amount is -1 then show nothing

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      context.read<InterstitialAdCubit>().showAd(context);
    });
    getResultAndUpdateCoins();
    super.initState();
  }

  void getResultAndUpdateCoins() {
    //create new array of map that creates user and rank
    widget.users.forEach((element) {
      usersWithRank.add({
        "user": element,
      });
    });
    var points = usersWithRank.map((details) {
      return (details['user'] as UserBattleRoomDetails).correctAnswers;
    }).toList();

    points = points.toSet().toList();
    points.sort((first, second) => second.compareTo(first));

    usersWithRank.forEach((userDetails) {
      int rank = points.indexOf(
              (userDetails['user'] as UserBattleRoomDetails).correctAnswers) +
          1;
      userDetails.addAll({"rank": rank});
    });
    usersWithRank.sort((first, second) => int.parse(first['rank'].toString())
        .compareTo(int.parse(second['rank'].toString())));
    //
    Future.delayed(Duration.zero, () {
      final currentUser = usersWithRank
          .where((element) =>
              (element['user'] as UserBattleRoomDetails).uid ==
              context.read<UserDetailsCubit>().getUserId())
          .toList()
          .first;
      final totalWinner = usersWithRank
          .where((element) => (element['rank'] == 1))
          .toList()
          .length;
      final winAmount = widget.entryFee * (widget.users.length / totalWinner);

      if (currentUser['rank'] == 1) {
        //update badge if locked
        if (context.read<BadgesCubit>().isBadgeLocked("clash_winner")) {
          context.read<BadgesCubit>().setBadge(
              badgeType: "clash_winner",
              userId: context.read<UserDetailsCubit>().getUserId());
        }

        //add coins
        //update coins
        context.read<UpdateScoreAndCoinsCubit>().updateCoins(
              context.read<UserDetailsCubit>().getUserId(),
              winAmount.toInt(),
              true,
              wonGroupBattleKey,
            );
        context.read<UserDetailsCubit>().updateCoins(
              addCoin: true,
              coins: winAmount.toInt(),
            );
        //update winAmount in ui as well
        _winAmount = winAmount.toInt();
        setState(() {});
        //
      }
    });
  }

  Widget _buildUserDetailsContainer(
      UserBattleRoomDetails userBattleRoomDetails,
      int rank,
      Size size,
      bool showStars,
      AlignmentGeometry alignment,
      EdgeInsetsGeometry edgeInsetsGeometry,
      Color color) {
    return Align(
      alignment: alignment,
      child: Container(
        margin: edgeInsetsGeometry,
        height: size.height,
        width: size.width,
        child: Stack(
          children: [
            Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 15.0,
                  ),
                  child: Container(
                    height: size.height - size.width * (0.925),
                    width: size.width * (0.5),
                    child: CustomPaint(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 7.5),
                          child: Text(
                            userBattleRoomDetails.correctAnswers.toString(),
                            style: TextStyle(
                                color: Theme.of(context).backgroundColor,
                                fontSize: showStars ? 20.0 : 18.0),
                          ),
                        ),
                      ),
                      painter: PointsPainter(color),
                    ),
                  ),
                )),
            Container(
              height: size.width,
              width: size.width,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.contain,
                    image: CachedNetworkImageProvider(
                        userBattleRoomDetails.profileUrl),
                  ),
                  borderRadius: BorderRadius.circular(size.width * (0.5)),
                ),
                margin: const EdgeInsets.all(5.0),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size.width * (0.5)),
                color: color,
              ),
            ),
            Align(
              alignment: showStars
                  ? AlignmentDirectional.topStart
                  : AlignmentDirectional.topEnd,
              child: CircleAvatar(
                child: Center(
                  child: Text(
                    rank.toString(),
                    style: TextStyle(
                      fontSize: showStars ? 22 : 18.0,
                      color: Theme.of(context).backgroundColor,
                    ),
                  ),
                ),
                backgroundColor: Theme.of(context).primaryColor,
                radius: showStars ? 25 : 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultLabel() {
    final currentUser = usersWithRank
        .where((element) =>
            (element['user'] as UserBattleRoomDetails).uid ==
            context.read<UserDetailsCubit>().getUserId())
        .toList()
        .first;

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * (0.06),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              currentUser['rank'] == 1
                  ? AppLocalization.of(context)!
                      .getTranslatedValues('youWonLbl')!
                      .toUpperCase()
                  : AppLocalization.of(context)!
                      .getTranslatedValues('youLostLbl')!,
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 22.0,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 2.5,
            ),
            _winAmount != -1
                ? Text(
                    "$_winAmount ${AppLocalization.of(context)!.getTranslatedValues(coinsLbl)!} ",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 20.0),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdateScoreAndCoinsCubit, UpdateScoreAndCoinsState>(
      listener: (context, state) {
        if (state is UpdateScoreAndCoinsFailure) {
          if (state.errorMessage == unauthorizedAccessCode) {
            UiUtils.showAlreadyLoggedInDialog(context: context);
          }
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            PageBackgroundGradientContainer(),

            _buildResultLabel(),

            //user 1
            _buildUserDetailsContainer(
              usersWithRank.first['user'] as UserBattleRoomDetails,
              usersWithRank.first['rank'],
              Size(MediaQuery.of(context).size.width * (0.475),
                  MediaQuery.of(context).size.height * (0.35)),
              true,
              AlignmentDirectional.centerStart,
              EdgeInsetsDirectional.only(
                start: 10.0,
                top: MediaQuery.of(context).size.height * (0.125),
              ),
              Colors.green,
            ),
            //user 2

            usersWithRank.length == 2
                ? _buildUserDetailsContainer(
                    usersWithRank[1]['user'] as UserBattleRoomDetails,
                    usersWithRank[1]['rank'],
                    Size(MediaQuery.of(context).size.width * (0.36),
                        MediaQuery.of(context).size.height * (0.25)),
                    false,
                    AlignmentDirectional.centerEnd,
                    EdgeInsetsDirectional.only(
                      end: 10.0,
                      top: MediaQuery.of(context).size.height * (0.1),
                    ),
                    Colors.redAccent,
                  )
                : _buildUserDetailsContainer(
                    usersWithRank[1]['user'] as UserBattleRoomDetails,
                    usersWithRank[1]['rank'],
                    Size(MediaQuery.of(context).size.width * (0.38),
                        MediaQuery.of(context).size.height * (0.28)),
                    false,
                    AlignmentDirectional.center,
                    EdgeInsetsDirectional.only(
                      start: MediaQuery.of(context).size.width * (0.3),
                      bottom: MediaQuery.of(context).size.height * (0.42),
                    ),
                    Colors.redAccent,
                  ),

            //user 3
            usersWithRank.length > 2
                ? _buildUserDetailsContainer(
                    usersWithRank[2]['user'] as UserBattleRoomDetails,
                    usersWithRank[2]['rank'],
                    Size(MediaQuery.of(context).size.width * (0.36),
                        MediaQuery.of(context).size.height * (0.25)),
                    false,
                    AlignmentDirectional.centerEnd,
                    EdgeInsetsDirectional.only(
                      end: 10.0,
                      top: MediaQuery.of(context).size.height * (0.1),
                    ),
                    Colors.redAccent,
                  )
                : Container(),

            //user 4
            usersWithRank.length == 4
                ? _buildUserDetailsContainer(
                    usersWithRank.last['user'] as UserBattleRoomDetails,
                    usersWithRank.last['rank'],
                    Size(MediaQuery.of(context).size.width * (0.35),
                        MediaQuery.of(context).size.height * (0.25)),
                    false,
                    AlignmentDirectional.center,
                    EdgeInsetsDirectional.only(
                      start: MediaQuery.of(context).size.width * (0.3),
                      top: MediaQuery.of(context).size.height * (0.575),
                    ),
                    Colors.redAccent,
                  )
                : Container(),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: usersWithRank.length == 4
                        ? 20
                        : 50.0), //if total 4 user than padding will be 20 else 50
                child: CustomRoundedButton(
                  widthPercentage: 0.85,
                  backgroundColor: Theme.of(context).primaryColor,
                  buttonTitle: AppLocalization.of(context)!
                      .getTranslatedValues("homeBtn")!,
                  radius: 5.0,
                  showBorder: false,
                  fontWeight: FontWeight.bold,
                  height: 40.0,
                  elevation: 5.0,
                  titleColor: Theme.of(context).backgroundColor,
                  onTap: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  textSize: 17.0,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PointsPainter extends CustomPainter {
  final Color color;
  PointsPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = color;
    Path path = Path();

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width * (0.5), size.height * (0.8));
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

/*
To decide result

  List<Map<String,dynamic>> users = [{
    "id" : 1,
    "points" : 0
  },{
    "id" : 2,
    "points" : 1
  },{
    "id" : 3,
    "points" : 2
  },{
    "id" : 4,
    "points" : 0
  }
  ];
  var points = users.map((details) => details['points']).toList();
 
  points = points.toSet().toList();
  points.sort((first,second) => second.compareTo(first));
  
  users.forEach((userDetails) {
    int rank = points.indexOf(userDetails['points']) + 1;
    userDetails.addAll({
      "rank" : rank
    });
  }); 
  
  print(users);


 */
