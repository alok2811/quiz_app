import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/features/bookmark/cubits/bookmarkCubit.dart';
import 'package:ayuprep/features/bookmark/cubits/updateBookmarkCubit.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/features/quiz/models/question.dart';
import 'package:ayuprep/features/quiz/models/quizType.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:ayuprep/utils/uiUtils.dart';

class BookmarkButton extends StatelessWidget {
  final Question question;
  final QuizTypes quizType;
  final Color? bookmarkButtonColor;
  final Color? bookmarkFillColor;

  const BookmarkButton(
      {Key? key,
      required this.question,
      this.bookmarkFillColor,
      required this.quizType,
      this.bookmarkButtonColor})
      : super(key: key);

  String _getBookmarkType() {
    if (quizType == QuizTypes.quizZone) {
      return "1";
    }
    if (quizType == QuizTypes.guessTheWord) {
      return "3";
    }
    return "4";
  }

  @override
  Widget build(BuildContext context) {
    final bookmarkCubit = context.read<BookmarkCubit>();
    final updateBookmarkcubit = context.read<UpdateBookmarkCubit>();

    return BlocListener<UpdateBookmarkCubit, UpdateBookmarkState>(
      bloc: updateBookmarkcubit,
      listener: (context, state) {
        //if failed to update bookmark status
        if (state is UpdateBookmarkFailure) {
          //remove bookmark question
          if (state.failedStatus == "0") {
            //if unable to remove question from bookmark then add question
            //add again
            bookmarkCubit.addBookmarkQuestion(
                question, context.read<UserDetailsCubit>().getUserId());
          } else {
            //remove again
            //if unable to add question to bookmark then remove question
            bookmarkCubit.removeBookmarkQuestion(
                question.id, context.read<UserDetailsCubit>().getUserId());
          }
          UiUtils.setSnackbar(
              AppLocalization.of(context)!.getTranslatedValues(
                  convertErrorCodeToLanguageKey(updateBookmarkFailureCode))!,
              context,
              false);
        }
        if (state is UpdateBookmarkSuccess) {
          print("Success");
        }
      },
      child: BlocBuilder<BookmarkCubit, BookmarkState>(
        bloc: bookmarkCubit,
        builder: (context, state) {
          if (state is BookmarkFetchSuccess) {
            return InkWell(
              onTap: () {
                if (bookmarkCubit.hasQuestionBookmarked(question.id)) {
                  //remove
                  bookmarkCubit.removeBookmarkQuestion(question.id,
                      context.read<UserDetailsCubit>().getUserId());
                  updateBookmarkcubit.updateBookmark(
                      context.read<UserDetailsCubit>().getUserId(),
                      question.id!,
                      "0",
                      _getBookmarkType());
                } else {
                  //add
                  bookmarkCubit.addBookmarkQuestion(
                      question, context.read<UserDetailsCubit>().getUserId());
                  updateBookmarkcubit.updateBookmark(
                      context.read<UserDetailsCubit>().getUserId(),
                      question.id!,
                      "1",
                      _getBookmarkType());
                }
              },
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.transparent),
                ),
                child: bookmarkCubit.hasQuestionBookmarked(question.id)
                    ? Icon(
                        CupertinoIcons.bookmark_fill,
                        color: bookmarkFillColor ??
                            Theme.of(context).backgroundColor,
                        size: 20,
                      )
                    : Icon(
                        CupertinoIcons.bookmark,
                        color: bookmarkButtonColor ??
                            Theme.of(context).backgroundColor,
                        size: 20,
                      ),
              ),
            );
          }
          if (state is BookmarkFetchFailure) {
            return SizedBox();
          }

          return SizedBox();
        },
      ),
    );
  }
}
