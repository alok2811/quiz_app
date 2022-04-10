class UserProfile {
  final String? name;
  final String? userId;
  final String? firebaseId;
  final String? profileUrl;
  final String? email;
  final String? mobileNumber;
  final String? status;
  final String? allTimeScore;
  final String? allTimeRank;
  final String? coins;
  final String? registeredDate;
  final String? referCode;
  final String? fcmToken;

  UserProfile({this.email, this.fcmToken, this.referCode, this.firebaseId, this.mobileNumber, this.name, this.profileUrl, this.userId, this.allTimeRank, this.allTimeScore, this.coins, this.registeredDate, this.status});

  static UserProfile fromJson(Map<String, dynamic> jsonData) {
    //torefer keys go profileMan.remoteRepo
    return UserProfile(
        allTimeRank: jsonData['all_time_rank'],
        mobileNumber: jsonData['mobile'],
        name: jsonData['name'],
        profileUrl: jsonData['profile'],
        registeredDate: jsonData['date_registered'],
        status: jsonData['status'],
        userId: jsonData['id'],
        firebaseId: jsonData['firebase_id'],
        allTimeScore: jsonData['all_time_score'],
        coins: jsonData['coins'],
        referCode: jsonData['refer_code'],
        fcmToken: jsonData['fcm_id'],
        email: jsonData['email']);
  }

  UserProfile copyWith({String? profileUrl, String? name, String? allTimeRank, String? allTimeScore, String? coins, String? status, String? mobile, String? email}) {
    return UserProfile(
        fcmToken: this.fcmToken,
        userId: this.userId,
        profileUrl: profileUrl ?? this.profileUrl,
        email: email ?? this.email,
        name: name ?? this.name,
        firebaseId: this.firebaseId,
        referCode: this.referCode,
        allTimeRank: allTimeRank ?? this.allTimeRank,
        allTimeScore: allTimeScore ?? this.allTimeScore,
        coins: coins ?? this.coins,
        mobileNumber: mobile ?? this.mobileNumber,
        registeredDate: this.registeredDate,
        status: status ?? this.status);
  }

  UserProfile copyWithProfileData(String? name, String? mobile, String? email) {
    return UserProfile(
      fcmToken: this.fcmToken,
      referCode: this.referCode,
      userId: this.userId,
      profileUrl: this.profileUrl,
      email: email,
      name: name,
      firebaseId: this.firebaseId,
      allTimeRank: this.allTimeRank,
      allTimeScore: this.allTimeScore,
      coins: this.coins,
      mobileNumber: mobile,
      registeredDate: this.registeredDate,
      status: this.status,
    );
  }
}
