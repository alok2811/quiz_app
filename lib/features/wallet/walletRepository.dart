import 'package:ayuprep/features/wallet/models/paymentRequest.dart';
import 'package:ayuprep/features/wallet/walletException.dart';
import 'package:ayuprep/features/wallet/walletRemoteDataSource.dart';

class WalletRepository {
  static final WalletRepository _walletRepository =
      WalletRepository._internal();

  late WalletRemoteDataSource _walletRemoteDataSource;

  factory WalletRepository() {
    _walletRepository._walletRemoteDataSource = WalletRemoteDataSource();
    return _walletRepository;
  }

  WalletRepository._internal();

  Future<void> makePaymentRequest({
    required String userId,
    required String paymentType,
    required String paymentAddress,
    required String paymentAmount,
    required String coinUsed,
    required String details,
  }) async {
    try {
      await _walletRemoteDataSource.makePaymentRequest(
          userId: userId,
          paymentType: paymentType,
          paymentAddress: paymentAddress,
          paymentAmount: paymentAmount,
          coinUsed: coinUsed,
          details: details);
    } catch (e) {
      throw WalletException(errorMessageCode: e.toString());
    }
  }

  Future<Map<String, dynamic>> getTransactions({
    required String userId,
    required String limit,
    required String offset,
  }) async {
    try {
      final result = await _walletRemoteDataSource.getTransactions(
          userId: userId, limit: limit, offset: offset);
      return {
        "total": result['total'],
        "transactions": (result['data'] as List)
            .map((e) => PaymentRequest.fromJson(e))
            .toList(),
      };
    } catch (e) {
      throw WalletException(errorMessageCode: e.toString());
    }
  }
}
