import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/wallet/walletRepository.dart';

abstract class PaymentRequestState {}

class PaymentRequestInitial extends PaymentRequestState {}

class PaymentRequestInProgress extends PaymentRequestState {}

class PaymentRequestSuccess extends PaymentRequestState {}

class PaymentRequestFailure extends PaymentRequestState {
  final String errorMessage;

  PaymentRequestFailure(this.errorMessage);
}

class PaymentRequestCubit extends Cubit<PaymentRequestState> {
  final WalletRepository _walletRepository;

  PaymentRequestCubit(this._walletRepository) : super(PaymentRequestInitial());

  void makePaymentRequest({
    required String userId,
    required String paymentType,
    required String paymentAddress,
    required String paymentAmount,
    required String coinUsed,
    required String details,
  }) async {
    try {
      emit(PaymentRequestInProgress());
      await _walletRepository.makePaymentRequest(
          userId: userId,
          paymentType: paymentType,
          paymentAddress: paymentAddress,
          paymentAmount: paymentAmount,
          coinUsed: coinUsed,
          details: details);
      emit(PaymentRequestSuccess());
      //
    } catch (e) {
      //
      emit(PaymentRequestFailure(e.toString()));
    }
  }
}
