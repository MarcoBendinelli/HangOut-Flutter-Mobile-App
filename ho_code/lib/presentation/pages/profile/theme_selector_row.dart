import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/business_logic/blocs/theme/theme_bloc.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    if (getSize(context) == ScreenSize.normal) {
      return BlocBuilder<ThemeBloc, bool>(
        builder: (context, state) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: "Dark mode",
                fontFamily: "Raleway",
                fontWeight: Fonts.bold,
                size: 14.h,
              ),
              IconButton(
                key: const Key("theme_selector_button"),
                padding: EdgeInsets.zero,
                iconSize: Constants.iconDimension,
                constraints: const BoxConstraints(),
                enableFeedback: false,
                onPressed: () {
                  BlocProvider.of<ThemeBloc>(context)
                      .add(ThemeChanged(isThemeDark: !state));
                },
                icon: state
                    ? Icon(
                        AppIcons.radioButtonOn,
                        size: Constants.iconDimension,
                      )
                    : Icon(
                        AppIcons.radioButtonOffOutline,
                        size: Constants.iconDimension,
                      ),
              ),
            ],
          );
        },
      );
    }
    return BlocBuilder<ThemeBloc, bool>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              text: "Dark mode",
              fontFamily: "Raleway",
              fontWeight: Fonts.bold,
              size: TabletConstants.textDimensionGroupName(),
            ),
            IconButton(
              key: const Key("theme_selector_button"),
              padding: EdgeInsets.zero,
              iconSize: TabletConstants.iconDimension(),
              constraints: const BoxConstraints(),
              enableFeedback: false,
              onPressed: () {
                BlocProvider.of<ThemeBloc>(context)
                    .add(ThemeChanged(isThemeDark: !state));
              },
              icon: state
                  ? Icon(
                      AppIcons.radioButtonOn,
                      size: TabletConstants.iconDimension(),
                    )
                  : Icon(
                      AppIcons.radioButtonOffOutline,
                      size: TabletConstants.iconDimension(),
                    ),
            ),
          ],
        );
      },
    );
  }
}
