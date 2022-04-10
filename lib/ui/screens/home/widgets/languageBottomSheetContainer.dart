import 'package:flutter/material.dart';
import 'package:ayuprep/features/localization/appLocalizationCubit.dart';
import 'package:ayuprep/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/utils/uiUtils.dart';

class LanguageDailogContainer extends StatelessWidget {
  LanguageDailogContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final supportedLanguages = context.read<SystemConfigCubit>().getSupportedLanguages();
    return BlocBuilder<AppLocalizationCubit, AppLocalizationState>(
      bloc: context.read<AppLocalizationCubit>(),
      builder: (context, state) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: supportedLanguages.map((language) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  decoration: BoxDecoration(
                    color: state.language == UiUtils.getLocaleFromLanguageCode(language.languageCode) ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    trailing: state.language == UiUtils.getLocaleFromLanguageCode(language.languageCode)
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).backgroundColor,
                          )
                        : SizedBox(),
                    onTap: () {
                      if (state.language != UiUtils.getLocaleFromLanguageCode(language.languageCode)) {
                        context.read<AppLocalizationCubit>().changeLanguage(language.languageCode);
                      }
                    },
                    title: Text(
                      language.language,
                      style: TextStyle(
                        color: Theme.of(context).backgroundColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

/*

 */