import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/ui/styles/theme/appTheme.dart';
import 'package:ayuprep/ui/styles/theme/themeCubit.dart';
import 'package:ayuprep/utils/uiUtils.dart';

class ThemeDialog extends StatelessWidget {
  const ThemeDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      bloc: context.read<ThemeCubit>(),
      builder: (context, state) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: appThemeData.keys.map((theme) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                decoration: BoxDecoration(
                  color: state.appTheme == theme ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  trailing: state.appTheme == theme
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).backgroundColor,
                        )
                      : SizedBox(),
                  onTap: () {
                    //
                    context.read<ThemeCubit>().changeTheme(theme);
                  },
                  title: Text(
                    AppLocalization.of(context)!.getTranslatedValues(UiUtils.getThemeLabelFromAppTheme(theme))!,
                    style: TextStyle(
                      color: Theme.of(context).backgroundColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
