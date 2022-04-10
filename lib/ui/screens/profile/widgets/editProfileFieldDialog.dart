import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/features/profileManagement/cubits/updateUserDetailsCubit.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/ui/widgets/errorMessageDialog.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:ayuprep/utils/validators.dart';

class EditProfileFieldDialog extends StatefulWidget {
  final String fieldTitle; //value of fieldTitle will be from :  Email,Mobile Number,Name
  final String fieldValue; //
  final bool numericKeyboardEnable;
  final UpdateUserDetailCubit updateUserDetailCubit;

  EditProfileFieldDialog({Key? key, required this.numericKeyboardEnable, required this.updateUserDetailCubit, required this.fieldTitle, required this.fieldValue}) : super(key: key);

  @override
  _EditProfileFieldDialogState createState() => _EditProfileFieldDialogState();
}

class _EditProfileFieldDialogState extends State<EditProfileFieldDialog> {
  late TextEditingController textEditingController = TextEditingController(text: widget.fieldValue);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UpdateUserDetailCubit, UpdateUserDetailState>(
      bloc: widget.updateUserDetailCubit,
      listener: (context, state) {
        if (state is UpdateUserDetailSuccess) {
          context.read<UserDetailsCubit>().updateUserProfile(
                email: widget.fieldTitle == "Email" ? textEditingController.text.trim() : null,
                mobile: widget.fieldTitle == "Mobile Number" ? textEditingController.text.trim() : null,
                name: widget.fieldTitle == "Name" ? textEditingController.text.trim() : null,
              );
          Navigator.of(context).pop();
        }
        if (state is UpdateUserDetailFailure) {
          showDialog(context: context, builder: (_) => ErrorMessageDialog(errorMessage: AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(state.errorMessage))!));
        }
      },
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(true);
          },
          child: AlertDialog(
            title: Text(
              "${widget.fieldTitle}",
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
            content: TextField(
              decoration: InputDecoration(),
              keyboardType: widget.numericKeyboardEnable ? TextInputType.number : TextInputType.text,
              controller: textEditingController,
              cursorColor: Theme.of(context).colorScheme.secondary,
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
            actions: [
              TextButton(
                onPressed: state is UpdateUserDetailInProgress
                    ? () {}
                    : () {
                        final userProfile = context.read<UserDetailsCubit>().getUserProfile();
                        //means it is not
                        if (widget.fieldTitle == "Mobile Number") {
                          //Email,Mobile Number,Name
                          if (!Validators.isCorrectMobileNumber(textEditingController.text.trim())) {
                            showDialog(context: context, builder: (_) => ErrorMessageDialog(errorMessage: AppLocalization.of(context)!.getTranslatedValues("validMobMsg")!));
                            return;
                          }
                        } else if (widget.fieldTitle == "Email") {
                          if (!Validators.isValidEmail(textEditingController.text.trim())) {
                            showDialog(context: context, builder: (_) => ErrorMessageDialog(errorMessage: AppLocalization.of(context)!.getTranslatedValues("enterValidEmailMsg")!));
                            return;
                          }
                        } else if (widget.fieldTitle == "Name") {
                          if (!Validators.isValidName(textEditingController.text.trim())) {
                            showDialog(context: context, builder: (_) => ErrorMessageDialog(errorMessage: AppLocalization.of(context)!.getTranslatedValues("enterValidNameMsg")!));
                            return;
                          }
                        }

                        widget.updateUserDetailCubit.updateProfile(
                          userId: userProfile.userId!,
                          email: widget.fieldTitle == "Email" ? textEditingController.text.trim() : userProfile.email ?? "",
                          mobile: widget.fieldTitle == "Mobile Number" ? textEditingController.text.trim() : userProfile.mobileNumber ?? "",
                          name: widget.fieldTitle == "Name" ? textEditingController.text.trim() : userProfile.name ?? "",
                        );
                      },
                child: Text(state is UpdateUserDetailInProgress ? AppLocalization.of(context)!.getTranslatedValues("updatingLbl")! : AppLocalization.of(context)!.getTranslatedValues("updateLbl")!,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    )),
              ),
              TextButton(
                onPressed: state is UpdateUserDetailInProgress
                    ? () {}
                    : () {
                        Navigator.of(context).pop();
                      },
                child: Text(AppLocalization.of(context)!.getTranslatedValues("exitLbl")!,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    )),
              ),
            ],
          ),
        );
      },
    );
  }
}
