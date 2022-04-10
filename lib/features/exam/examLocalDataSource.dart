import 'package:ayuprep/utils/constants.dart';
import 'package:hive_flutter/adapters.dart';

class ExamLocalDataSource {
  Future<void> addExamModuleId(String examModuleId) async {
    await Hive.box(examBox).put(examModuleId, examModuleId);
  }

  Future<void> removeExamModuleId(String examModuleId) async {
    await Hive.box(examBox).delete(examModuleId);
  }

  List<String> getAllExamModuleIds() {
    List<String> examModuleIds = [];
    //get all exam module ids
    for (var i = 0; i < Hive.box(examBox).length; i++) {
      examModuleIds.add(Hive.box(examBox).getAt(i));
    }
    print("Total pending exams are : ${examModuleIds.length}");
    return examModuleIds;
  }
}
