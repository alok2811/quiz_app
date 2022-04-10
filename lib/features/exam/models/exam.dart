class Exam {
  Exam({
    required this.id,
    required this.languageId,
    required this.title,
    required this.date,
    required this.examKey,
    required this.duration,
    required this.status,
    required this.noOfQue,
    required this.answerAgain,
    required this.examStatus, //(status: 1-Not in Exam, 2-In exam, 3-Completed)
  });
  late final String id;
  late final String languageId;
  late final String title;
  late final String date;
  late final String examKey;
  late final String duration;
  late final String status;
  late final String noOfQue;
  late final String examStatus;
  late final String totalMarks;
  late final String answerAgain;

  Exam.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    languageId = json['language_id'];
    title = json['title'];
    date = json['date'];
    examKey = json['exam_key'];
    duration = json['duration'];
    status = json['status'];
    noOfQue = json['no_of_que'];
    examStatus = json['exam_status'];
    totalMarks = json['total_marks'];
    answerAgain = json['answer_again'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['language_id'] = languageId;
    _data['title'] = title;
    _data['date'] = date;
    _data['exam_key'] = examKey;
    _data['duration'] = duration;
    _data['status'] = status;
    _data['no_of_que'] = noOfQue;
    _data['exam_status'] = examStatus;
    _data['total_marks'] = totalMarks;
    _data['answer_again'] = answerAgain;
    return _data;
  }
}
