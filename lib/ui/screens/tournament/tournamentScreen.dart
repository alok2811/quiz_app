import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/app/routes.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/features/tournament/cubits/tournamentBattleCubit.dart';
import 'package:ayuprep/features/tournament/cubits/tournamentCubit.dart';
import 'package:ayuprep/features/tournament/model/tournament.dart';
import 'package:ayuprep/features/tournament/model/tournamentBattle.dart';
import 'package:ayuprep/features/tournament/model/tournamentDetails.dart';
import 'package:ayuprep/features/tournament/model/tournamentPlayerDetails.dart';
import 'package:ayuprep/ui/widgets/circularProgressContainner.dart';
import 'package:ayuprep/ui/widgets/errorContainer.dart';
import 'package:ayuprep/ui/widgets/exitGameDailog.dart';
import 'package:ayuprep/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:ayuprep/utils/uiUtils.dart';

class TournamentScreen extends StatefulWidget {
  final TournamentDetails tournamentDetails;
  TournamentScreen({Key? key, required this.tournamentDetails}) : super(key: key);

  @override
  _TournamentScreenState createState() => _TournamentScreenState();

  static Route<TournamentScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => TournamentScreen(
        tournamentDetails: routeSettings.arguments as TournamentDetails,
      ),
    );
  }
}

class _TournamentScreenState extends State<TournamentScreen> {
  @override
  void initState() {
    super.initState();
    searchTournament();
  }

  void searchTournament() {
    Future.delayed(Duration.zero, () {
      UserDetailsCubit userDetailsCubit = context.read<UserDetailsCubit>();
      context.read<TournamentCubit>().serachTournament(
            tournamentTitle: widget.tournamentDetails.title,
            languageId: UiUtils.getCurrentQuestionLanguageId(context),
            entryFee: widget.tournamentDetails.entryFee.toString(),
            uid: userDetailsCubit.getUserId(),
            profileUrl: userDetailsCubit.getUserProfile().profileUrl!,
            name: userDetailsCubit.getUserName(),
          );
    });
  }

  Widget _buildQuaterFinalContainer(TournamentPlayerDetails user1, TournamentPlayerDetails user2) {
    //
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(user1.profileUrl),
        ),
        SizedBox(
          width: 25.0,
        ),
        CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(user2.profileUrl),
        ),
      ],
    );
  }

  Widget _buildQuaterFinalsContainer(Tournament tournament) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            //
            tournament.quaterFinals.length >= 1
                ? _buildQuaterFinalContainer(
                    tournament.players[context.read<TournamentCubit>().getUserIndex(tournament.quaterFinals.first['user1'])], tournament.players[context.read<TournamentCubit>().getUserIndex(tournament.quaterFinals.first['user2'])])
                : Container(),
          ],
        ),
        Row(
          children: [],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tournamentCubit = context.read<TournamentCubit>();

    return MultiBlocListener(
        listeners: [
          BlocListener<TournamentCubit, TournamentState>(
              bloc: tournamentCubit,
              listener: (context, state) {
                print("Tournament state is ${state.toString()}");

                //if tournament started
                if (state is TournamentStarted) {
                  final tournamentBattleCubit = context.read<TournamentBattleCubit>();

                  if (state.tournament.quaterFinalsResult.isEmpty && state.tournament.semiFinals.isEmpty) {
                    //if quater finals result is empty then create or quater finals
                    int userIndex = tournamentCubit.getUserIndex(context.read<UserDetailsCubit>().getUserId());
                    if (userIndex == 0 || userIndex == 2 || userIndex == 4 || userIndex == 6) {
                      //this will determine that quater finals created only once
                      if (tournamentBattleCubit.state is TournamentBattleInitial) {
                        //
                        //then create quater final
                        tournamentBattleCubit.createTournamentBattle(
                          tournamentBattleType: TournamentBattleType.quaterFinal,
                          tournamentId: state.tournament.id,
                          user1: state.tournament.players[userIndex],
                          user2: state.tournament.players[userIndex + 1],
                        );
                      }
                    } else {
                      //subscribe to tournament battle
                      if (tournamentBattleCubit.state is TournamentBattleInitial) {
                        print("Join user");
                        // && state.tournament.quaterFinals.length <= 4

                        //user2 uid will be the user who will join or will not created the quater final battle
                        String tournamentBattleId = tournamentCubit.getQuaterFinalBattleId(state.tournament.players[userIndex].uid);
                        //if tournament battle
                        if (tournamentBattleId.isNotEmpty) {
                          tournamentBattleCubit.joinTournamentBattle(tournamentBattleType: TournamentBattleType.quaterFinal, tournamentBattleId: tournamentBattleId, tournamentPlayerDetails: state.tournament.players[userIndex]);
                        }
                      }
                    }
                  } else {
                    //do not create quater final
                  }
                }
              }),
          BlocListener<TournamentBattleCubit, TournamentBattleState>(
            listener: (context, state) {
              print("Tournament Battle state is ${state.toString()}");
              if (state is TournamentBattleStarted) {
                if (state.tournamentBattle.battleType == TournamentBattleType.quaterFinal) {
                  //if tournament is ready to play and both users have not submitted the any answer
                  if (state.tournamentBattle.readyToPlay && state.tournamentBattle.user1.answers.isEmpty && state.tournamentBattle.user2.answers.isEmpty) {
                    Navigator.of(context).pushNamed(Routes.battleRoomQuiz, arguments: {
                      "isTournamentBattle": true,
                    });
                  }
                }
              }
            },
            bloc: context.read<TournamentBattleCubit>(),
          )
        ],
        child: WillPopScope(
          onWillPop: () {
            showDialog(
                context: context,
                builder: (_) {
                  return ExitGameDailog(
                    onTapYes: () {
                      //reset tournament battle resource
                      context.read<TournamentBattleCubit>().resetTournamentBattleResource();
                      //reset tournament resource
                      context.read<TournamentCubit>().removeUserFromTournament(userId: context.read<UserDetailsCubit>().getUserId());
                      context.read<TournamentCubit>().resetTournamentResource();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                  );
                });

            return Future.value(false);
          },
          child: Scaffold(
            body: Stack(
              children: [
                PageBackgroundGradientContainer(),
                BlocBuilder(
                    bloc: tournamentCubit,
                    builder: (context, state) {
                      if (state is TournamentStarted) {
                        return Center(child: _buildQuaterFinalsContainer(state.tournament));
                      }
                      if (state is TournamentCreated) {
                        return Center(
                          child: Text("Waiting for players"),
                        );
                      }
                      if (state is TournamentJoined) {
                        return Center(
                          child: Text("Waiting for players"),
                        );
                      }

                      if (state is TournamentCreationFailure) {
                        return Center(
                          child: ErrorContainer(
                            errorMessage: AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(state.errorMessageCode))!,
                            onTapRetry: () {
                              searchTournament();
                            },
                            showErrorImage: true,
                          ),
                        );
                      }
                      if (state is TournamentJoiningFailure) {
                        return Center(
                          child: ErrorContainer(
                            errorMessage: AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(state.errorMessageCode))!,
                            onTapRetry: () {
                              searchTournament();
                            },
                            showErrorImage: true,
                          ),
                        );
                      }

                      return Center(
                        child: CircularProgressContainer(useWhiteLoader: false),
                      );
                    }),
              ],
            ),
          ),
        ));
  }
}
