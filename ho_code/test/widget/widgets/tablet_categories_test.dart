import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/presentation/utils/colors.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/tablet_grid_categories/tablet_landscape_grid_categories.dart';
import 'package:hang_out_app/presentation/widgets/tablet_grid_categories/tablet_portrait_grid_categories.dart';

void main() {
  const Size tabletLandscapeSize = Size(1374, 1024);
  const Size tabletPortraitSize = Size(1024, 1374);
  group('landscape grid categories', () {
    late Color primaryColor;
    late Color cardColor;
    testWidgets('check with empty interest given', (WidgetTester tester) async {
      await tester.runAsync(() async {
        tester.binding.window.physicalSizeTestValue = tabletLandscapeSize;
        tester.binding.window.devicePixelRatioTestValue = 1.0;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
                size: tabletLandscapeSize, devicePixelRatio: 1.0),
            child: ScreenUtilInit(
              designSize: tabletLandscapeSize,
              builder: (context, child) {
                cardColor = Theme.of(context).cardColor;
                primaryColor = Theme.of(context).primaryColor;
                TabletConstants.setDimensions(context);
                PopupTabletConstants.setSmallestDimension(context);
                return MaterialApp(
                    home: TabletLandscapeGridCategories(
                  callback: (selectedInterests) {},
                  interests: const [],
                ));
              },
            ),
          ),
        );
        //find a filter button for each category
        for (IconData icon in CategoryIcons.mapper.values) {
          expect(find.byIcon(icon), findsOneWidget);
        }
        //check that no one is selected
        for (IconData icon in CategoryIcons.mapper.values) {
          expect(
              (tester.firstWidget(find.byIcon(icon)) as Icon).color, cardColor);
          // expect(find.byIcon(icon).at(0)., findsOneWidget);
        }
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
    testWidgets('check with one interest given', (WidgetTester tester) async {
      await tester.runAsync(() async {
        tester.binding.window.physicalSizeTestValue = tabletLandscapeSize;
        tester.binding.window.devicePixelRatioTestValue = 1.0;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
                size: tabletLandscapeSize, devicePixelRatio: 1.0),
            child: ScreenUtilInit(
              designSize: tabletLandscapeSize,
              builder: (context, child) {
                primaryColor = Theme.of(context).primaryColor;
                cardColor = Theme.of(context).cardColor;
                TabletConstants.setDimensions(context);
                PopupTabletConstants.setSmallestDimension(context);
                return MaterialApp(
                    home: TabletLandscapeGridCategories(
                  callback: (selectedInterests) {},
                  interests: const ["food"],
                ));
              },
            ),
          ),
        );
        //find a filter button for each category
        for (IconData icon in CategoryIcons.mapper.values) {
          expect(find.byIcon(icon), findsOneWidget);
        }
        //check that only food is selected
        for (IconData icon in CategoryIcons.mapper.values) {
          if (icon == AppIcons.food) {
            expect((tester.firstWidget(find.byIcon(icon)) as Icon).color,
                primaryColor);
          } else {
            expect((tester.firstWidget(find.byIcon(icon)) as Icon).color,
                cardColor);
          }
        }
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
    testWidgets('check with 2 interest given', (WidgetTester tester) async {
      await tester.runAsync(() async {
        tester.binding.window.physicalSizeTestValue = tabletLandscapeSize;
        tester.binding.window.devicePixelRatioTestValue = 1.0;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
                size: tabletLandscapeSize, devicePixelRatio: 1.0),
            child: ScreenUtilInit(
              designSize: tabletLandscapeSize,
              builder: (context, child) {
                primaryColor = Theme.of(context).primaryColor;
                cardColor = Theme.of(context).cardColor;
                TabletConstants.setDimensions(context);
                PopupTabletConstants.setSmallestDimension(context);
                return MaterialApp(
                    home: TabletLandscapeGridCategories(
                  callback: (selectedInterests) {},
                  interests: const ["food", "sport"],
                ));
              },
            ),
          ),
        );
        //find a filter button for each category
        for (IconData icon in CategoryIcons.mapper.values) {
          expect(find.byIcon(icon), findsOneWidget);
        }
        //check that only food and sport are selected
        for (IconData icon in CategoryIcons.mapper.values) {
          if (icon == AppIcons.food || icon == AppIcons.sport) {
            expect((tester.firstWidget(find.byIcon(icon)) as Icon).color,
                primaryColor);
          } else {
            expect((tester.firstWidget(find.byIcon(icon)) as Icon).color,
                cardColor);
          }
        }
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
    testWidgets('tap from unselected to selected', (WidgetTester tester) async {
      await tester.runAsync(() async {
        tester.binding.window.physicalSizeTestValue = tabletLandscapeSize;
        tester.binding.window.devicePixelRatioTestValue = 1.0;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
                size: tabletLandscapeSize, devicePixelRatio: 1.0),
            child: ScreenUtilInit(
              designSize: tabletLandscapeSize,
              builder: (context, child) {
                primaryColor = Theme.of(context).primaryColor;
                cardColor = Theme.of(context).cardColor;
                TabletConstants.setDimensions(context);
                PopupTabletConstants.setSmallestDimension(context);
                return MaterialApp(
                    home: TabletLandscapeGridCategories(
                  callback: (selectedInterests) {},
                  interests: const [],
                ));
              },
            ),
          ),
        );
        //find a filter button for each category
        for (IconData icon in CategoryIcons.mapper.values) {
          expect(find.byIcon(icon), findsOneWidget);
        }
        //check that no icon is selected
        for (IconData icon in CategoryIcons.mapper.values) {
          expect(
              (tester.firstWidget(find.byIcon(icon)) as Icon).color, cardColor);
        }
        //tap on food icon
        await tester.tap(find.byIcon(AppIcons.food));
        await tester.pumpAndSettle();
        //check that only food is selected
        for (IconData icon in CategoryIcons.mapper.values) {
          if (icon == AppIcons.food) {
            expect((tester.firstWidget(find.byIcon(icon)) as Icon).color,
                primaryColor);
          } else {
            expect((tester.firstWidget(find.byIcon(icon)) as Icon).color,
                cardColor);
          }
        }
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
    testWidgets('tap from selected to unselected', (WidgetTester tester) async {
      await tester.runAsync(() async {
        tester.binding.window.physicalSizeTestValue = tabletLandscapeSize;
        tester.binding.window.devicePixelRatioTestValue = 1.0;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
                size: tabletLandscapeSize, devicePixelRatio: 1.0),
            child: ScreenUtilInit(
              designSize: tabletLandscapeSize,
              builder: (context, child) {
                primaryColor = Theme.of(context).primaryColor;
                cardColor = Theme.of(context).cardColor;
                TabletConstants.setDimensions(context);
                PopupTabletConstants.setSmallestDimension(context);
                return MaterialApp(
                    home: TabletLandscapeGridCategories(
                  callback: (selectedInterests) {},
                  interests: const ["food"],
                ));
              },
            ),
          ),
        );
        //find a filter button for each category
        for (IconData icon in CategoryIcons.mapper.values) {
          expect(find.byIcon(icon), findsOneWidget);
        }
        //check that only food is selected
        for (IconData icon in CategoryIcons.mapper.values) {
          if (icon == AppIcons.food) {
            expect((tester.firstWidget(find.byIcon(icon)) as Icon).color,
                primaryColor);
          } else {
            expect((tester.firstWidget(find.byIcon(icon)) as Icon).color,
                cardColor);
          }
        }
        //tap on food icon
        await tester.tap(find.byIcon(AppIcons.food));
        await tester.pumpAndSettle();

        //check that no icon is selected
        for (IconData icon in CategoryIcons.mapper.values) {
          expect(
              (tester.firstWidget(find.byIcon(icon)) as Icon).color, cardColor);
        }
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
  });

  group('portrait grid categories', () {
    late Color primaryColor;
    late Color cardColor;
    testWidgets('check with empty interest given', (WidgetTester tester) async {
      await tester.runAsync(() async {
        tester.binding.window.physicalSizeTestValue = tabletPortraitSize;
        tester.binding.window.devicePixelRatioTestValue = 0.9;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
                size: tabletPortraitSize, devicePixelRatio: 0.9),
            child: ScreenUtilInit(
              designSize: tabletPortraitSize,
              builder: (context, child) {
                cardColor = Theme.of(context).cardColor;
                primaryColor = Theme.of(context).primaryColor;
                TabletConstants.setDimensions(context);
                PopupTabletConstants.setSmallestDimension(context);
                return MaterialApp(
                    home: TabletPortraitGridCategories(
                  callback: (selectedInterests) {},
                  interests: const [],
                ));
              },
            ),
          ),
        );
        //find a filter button for each category
        for (IconData icon in CategoryIcons.mapper.values) {
          expect(find.byIcon(icon), findsOneWidget);
        }
        //check that no one is selected
        for (IconData icon in CategoryIcons.mapper.values) {
          expect(
              (tester.firstWidget(find.byIcon(icon)) as Icon).color, cardColor);
          // expect(find.byIcon(icon).at(0)., findsOneWidget);
        }
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
    testWidgets('check with one interest given', (WidgetTester tester) async {
      await tester.runAsync(() async {
        tester.binding.window.physicalSizeTestValue = tabletPortraitSize;
        tester.binding.window.devicePixelRatioTestValue = 1.0;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
                size: tabletPortraitSize, devicePixelRatio: 1.0),
            child: ScreenUtilInit(
              designSize: tabletPortraitSize,
              builder: (context, child) {
                primaryColor = Theme.of(context).primaryColor;
                cardColor = Theme.of(context).cardColor;
                TabletConstants.setDimensions(context);
                PopupTabletConstants.setSmallestDimension(context);
                return MaterialApp(
                    home: TabletPortraitGridCategories(
                  callback: (selectedInterests) {},
                  interests: const ["food"],
                ));
              },
            ),
          ),
        );
        //find a filter button for each category
        for (IconData icon in CategoryIcons.mapper.values) {
          expect(find.byIcon(icon), findsOneWidget);
        }
        //check that only food is selected
        for (IconData icon in CategoryIcons.mapper.values) {
          if (icon == AppIcons.food) {
            expect((tester.firstWidget(find.byIcon(icon)) as Icon).color,
                primaryColor);
          } else {
            expect((tester.firstWidget(find.byIcon(icon)) as Icon).color,
                cardColor);
          }
        }
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
    testWidgets('check with 2 interest given', (WidgetTester tester) async {
      await tester.runAsync(() async {
        tester.binding.window.physicalSizeTestValue = tabletPortraitSize;
        tester.binding.window.devicePixelRatioTestValue = 1.0;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
                size: tabletPortraitSize, devicePixelRatio: 1.0),
            child: ScreenUtilInit(
              designSize: tabletPortraitSize,
              builder: (context, child) {
                primaryColor = Theme.of(context).primaryColor;
                cardColor = Theme.of(context).cardColor;
                TabletConstants.setDimensions(context);
                PopupTabletConstants.setSmallestDimension(context);
                return MaterialApp(
                    home: TabletPortraitGridCategories(
                  callback: (selectedInterests) {},
                  interests: const ["food", "sport"],
                ));
              },
            ),
          ),
        );
        //find a filter button for each category
        for (IconData icon in CategoryIcons.mapper.values) {
          expect(find.byIcon(icon), findsOneWidget);
        }
        //check that only food and sport are selected
        for (IconData icon in CategoryIcons.mapper.values) {
          if (icon == AppIcons.food || icon == AppIcons.sport) {
            expect((tester.firstWidget(find.byIcon(icon)) as Icon).color,
                primaryColor);
          } else {
            expect((tester.firstWidget(find.byIcon(icon)) as Icon).color,
                cardColor);
          }
        }
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
    testWidgets('tap from unselected to selected', (WidgetTester tester) async {
      await tester.runAsync(() async {
        tester.binding.window.physicalSizeTestValue = tabletPortraitSize;
        tester.binding.window.devicePixelRatioTestValue = 1.0;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
                size: tabletPortraitSize, devicePixelRatio: 1.0),
            child: ScreenUtilInit(
              designSize: tabletPortraitSize,
              builder: (context, child) {
                primaryColor = Theme.of(context).primaryColor;
                cardColor = Theme.of(context).cardColor;
                TabletConstants.setDimensions(context);
                PopupTabletConstants.setSmallestDimension(context);
                return MaterialApp(
                    home: TabletPortraitGridCategories(
                  callback: (selectedInterests) {},
                  interests: const [],
                ));
              },
            ),
          ),
        );
        //find a filter button for each category
        for (IconData icon in CategoryIcons.mapper.values) {
          expect(find.byIcon(icon), findsOneWidget);
        }
        //check that no icon is selected
        for (IconData icon in CategoryIcons.mapper.values) {
          expect(
              (tester.firstWidget(find.byIcon(icon)) as Icon).color, cardColor);
        }
        //tap on food icon
        await tester.tap(find.byIcon(AppIcons.food));
        await tester.pumpAndSettle();
        //check that only food is selected
        for (IconData icon in CategoryIcons.mapper.values) {
          if (icon == AppIcons.food) {
            expect((tester.firstWidget(find.byIcon(icon)) as Icon).color,
                primaryColor);
          } else {
            expect((tester.firstWidget(find.byIcon(icon)) as Icon).color,
                cardColor);
          }
        }
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
    testWidgets('tap from selected to unselected', (WidgetTester tester) async {
      await tester.runAsync(() async {
        tester.binding.window.physicalSizeTestValue = tabletPortraitSize;
        tester.binding.window.devicePixelRatioTestValue = 1.0;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
                size: tabletPortraitSize, devicePixelRatio: 1.0),
            child: ScreenUtilInit(
              designSize: tabletPortraitSize,
              builder: (context, child) {
                primaryColor = Theme.of(context).primaryColor;
                cardColor = Theme.of(context).cardColor;
                TabletConstants.setDimensions(context);
                PopupTabletConstants.setSmallestDimension(context);
                return MaterialApp(
                    home: TabletPortraitGridCategories(
                  callback: (selectedInterests) {},
                  interests: const ["food"],
                ));
              },
            ),
          ),
        );
        //find a filter button for each category
        for (IconData icon in CategoryIcons.mapper.values) {
          expect(find.byIcon(icon), findsOneWidget);
        }
        //check that only food is selected
        for (IconData icon in CategoryIcons.mapper.values) {
          if (icon == AppIcons.food) {
            expect((tester.firstWidget(find.byIcon(icon)) as Icon).color,
                primaryColor);
          } else {
            expect((tester.firstWidget(find.byIcon(icon)) as Icon).color,
                cardColor);
          }
        }
        //tap on food icon
        await tester.tap(find.byIcon(AppIcons.food));
        await tester.pumpAndSettle();

        //check that no icon is selected
        for (IconData icon in CategoryIcons.mapper.values) {
          expect(
              (tester.firstWidget(find.byIcon(icon)) as Icon).color, cardColor);
        }
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
  });
}
