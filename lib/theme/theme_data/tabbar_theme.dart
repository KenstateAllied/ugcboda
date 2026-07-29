import 'package:flutter/material.dart';
import 'package:ride_share/theme/theme_data/text_theme_data.dart';
import 'package:ride_share/utils/constants/colors.dart';


class GoRideAppTabBarTheme {
  GoRideAppTabBarTheme._();

  static TabBarThemeData tabBarLightTheme = TabBarThemeData(
    dividerColor: kTabDividerLightColor,
    labelColor: kTextDarkColor,
    labelStyle: GoRideAppTextTheme.lightTextTheme.titleMedium,
    unselectedLabelColor: Colors.grey,
    unselectedLabelStyle: GoRideAppTextTheme.darkTextTheme.titleMedium,
  );

  static TabBarThemeData tabBarDarkTheme = TabBarThemeData(
    dividerColor: kTabDividerDarkColor,
    labelColor: kTextLightColor,
    labelStyle: GoRideAppTextTheme.lightTextTheme.titleMedium,
    unselectedLabelColor: Colors.grey,
    unselectedLabelStyle: GoRideAppTextTheme.darkTextTheme.titleMedium,
  );
}