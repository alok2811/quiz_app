import 'dart:convert';
import 'dart:io';

import 'package:ayuprep/features/wallet/walletException.dart';
import 'package:ayuprep/utils/apiBodyParameterLabels.dart';
import 'package:ayuprep/utils/apiUtils.dart';
import 'package:ayuprep/utils/constants.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:http/http.dart' as http;

class WalletRemoteDataSource {
  /*

        access_key:8525
        user_id:1
        payment_type:paypal
        payment_address:abc@gmail.com
        payment_amount:10
        coin_used:100
        details:details



  */

  Future<dynamic> makePaymentRequest({
    required String userId,
    required String paymentType,
    required String paymentAddress,
    required String paymentAmount,
    required String coinUsed,
    required String details,
  }) async {
    try {
      //body of post request
      final body = {
        accessValueKey: accessValue,
        userIdKey: userId,
        paymentTypeKey: paymentType,
        paymentAddressKey: paymentAddress,
        paymentAmountKey: paymentAmount,
        coinUsedKey: coinUsed,
        detailsKey: details,
      };

      print("Parameters : $body");

      final response = await http.post(Uri.parse(makePaymentRequestUrl),
          body: body, headers: await ApiUtils.getHeaders());

      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw WalletException(
          errorMessageCode: responseJson['message'].toString() == "126"
              ? accountHasBeenDeactiveCode
              : responseJson['message'].toString() == "127"
                  ? canNotMakeRequestCode
                  : responseJson['message'].toString(),
        );
      }

      return responseJson;
    } on SocketException catch (_) {
      throw WalletException(errorMessageCode: noInternetCode);
    } on WalletException catch (e) {
      throw WalletException(errorMessageCode: e.toString());
    } catch (e) {
      throw WalletException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<dynamic> getTransactions({
    required String userId,
    required String limit,
    required String offset,
  }) async {
    try {
      //body of post request
      final body = {
        accessValueKey: accessValue,
        userIdKey: userId,
        limitKey: limit,
        offsetKey: offset,
      };

      final response = await http.post(Uri.parse(getTransactionsUrl),
          body: body, headers: await ApiUtils.getHeaders());

      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw WalletException(
          errorMessageCode: responseJson['message'] == "102"
              ? noTransactionsCode
              : responseJson['message'],
        );
      }

      return responseJson;
    } on SocketException catch (_) {
      throw WalletException(errorMessageCode: noInternetCode);
    } on WalletException catch (e) {
      throw WalletException(errorMessageCode: e.toString());
    } catch (e) {
      throw WalletException(errorMessageCode: defaultErrorMessageCode);
    }
  }
}
