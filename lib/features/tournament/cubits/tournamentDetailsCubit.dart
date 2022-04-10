import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/tournament/model/tournamentDetails.dart';
import 'package:ayuprep/features/tournament/tournamentRepository.dart';

abstract class TournamentDetailsState {}

class TournamentDetailsInitial extends TournamentDetailsState {}

class TournamentDetailsFetchInProgress extends TournamentDetailsState {}

class TournamentDetailsFetchSuccess extends TournamentDetailsState {
  final List<TournamentDetails> tournaments;

  TournamentDetailsFetchSuccess(this.tournaments);
}

class TournamentDetailsFetchFailure extends TournamentDetailsState {
  final String errorMessage;

  TournamentDetailsFetchFailure(this.errorMessage);
}

class TournamentDetailsCubit extends Cubit<TournamentDetailsState> {
  final TournamentRepository _tournamentRepository;
  TournamentDetailsCubit(this._tournamentRepository) : super(TournamentDetailsInitial());

  void getTournaments() {
    emit(TournamentDetailsFetchInProgress());
    _tournamentRepository.getTournaments().then((value) => emit(TournamentDetailsFetchSuccess(value))).catchError((e) {
      emit(TournamentDetailsFetchFailure(e.toString()));
    });
  }
}
