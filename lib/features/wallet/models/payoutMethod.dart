class PayoutMethod {
  final String type;
  final String image;
  final List<String> inputDetailsFromUser; //how many detials to get from user

  PayoutMethod({
    required this.inputDetailsFromUser,
    required this.image,
    required this.type,
  });
}
