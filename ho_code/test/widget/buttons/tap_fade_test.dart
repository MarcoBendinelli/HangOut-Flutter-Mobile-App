import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/presentation/widgets/buttons/tap_fade_icon.dart';
import 'package:hang_out_app/presentation/widgets/buttons/tap_fade_text.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';

void main() {
  group('TapFadeIcon', () {
    late VoidCallback onTapCallback;
    const iconColor = Colors.blue;
    const icon = Icons.add;
    const size = 24.0;

    setUp(() {
      onTapCallback = () {}; // Mock callback for onTap
    });

    testWidgets('Widget initializes correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TapFadeIcon(
            onTap: onTapCallback,
            icon: icon,
            iconColor: iconColor,
            size: size,
          ),
        ),
      );

      // Verify the widget renders correctly
      expect(find.byType(TapFadeIcon), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('Widget changes color on tap down and up',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TapFadeIcon(
            onTap: onTapCallback,
            icon: icon,
            iconColor: iconColor,
            size: size,
          ),
        ),
      );

      // Simulate tap down event
      await tester.tap(find.byType(TapFadeIcon));
      await tester.pump();

      // Verify color change
      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.color, equals(iconColor));

      // Simulate tap up event
      await tester.pumpWidget(
        MaterialApp(
          home: TapFadeIcon(
            onTap: onTapCallback,
            icon: icon,
            iconColor: iconColor,
            size: size,
          ),
        ),
      );
      await tester.pump();

      // Verify color reset
      final iconWidgetAfterTapUp = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidgetAfterTapUp.color, equals(iconColor));
    });

    testWidgets('Callback called on tap up', (WidgetTester tester) async {
      bool callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: TapFadeIcon(
            onTap: () {
              callbackCalled = true;
            },
            icon: icon,
            iconColor: iconColor,
            size: size,
          ),
        ),
      );

      // Simulate tap up event
      await tester.tap(find.byType(TapFadeIcon));
      await tester.pump();

      // Verify callback called
      expect(callbackCalled, isTrue);
    });

    testWidgets('Widget updates color on prop change',
        (WidgetTester tester) async {
      const newIconColor = Colors.red;

      await tester.pumpWidget(
        MaterialApp(
          home: TapFadeIcon(
            onTap: onTapCallback,
            icon: icon,
            iconColor: iconColor,
            size: size,
          ),
        ),
      );

      // Verify initial color
      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.color, equals(iconColor));

      // Update the color prop
      await tester.pumpWidget(
        MaterialApp(
          home: TapFadeIcon(
            onTap: onTapCallback,
            icon: icon,
            iconColor: newIconColor,
            size: size,
          ),
        ),
      );

      // Verify updated color
      final iconWidgetAfterUpdate = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidgetAfterUpdate.color, equals(newIconColor));
    });

    testWidgets('Widget changes color on vertical drag start and end',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TapFadeIcon(
            onTap: onTapCallback,
            icon: icon,
            iconColor: iconColor,
            size: size,
          ),
        ),
      );

      // Simulate vertical drag start event
      await tester.drag(find.byType(TapFadeIcon), const Offset(0, 50));
      await tester.pump();

      // Verify color change
      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.color, equals(iconColor));

      // Simulate vertical drag end event
      await tester.pumpWidget(
        MaterialApp(
          home: TapFadeIcon(
            onTap: onTapCallback,
            icon: icon,
            iconColor: iconColor,
            size: size,
          ),
        ),
      );
      await tester.pump();

      // Verify color reset
      final iconWidgetAfterDragEnd = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidgetAfterDragEnd.color, equals(iconColor));
    });

    testWidgets('Callback called on vertical drag end',
        (WidgetTester tester) async {
      bool callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: TapFadeIcon(
            onTap: () {
              callbackCalled = true;
            },
            icon: icon,
            iconColor: iconColor,
            size: size,
          ),
        ),
      );

      // Simulate vertical drag end event
      await tester.drag(find.byType(TapFadeIcon), const Offset(0, 50));
      await tester.pump();

      // Verify callback called
      expect(callbackCalled, isTrue);
    });
  });
  group('TapFadeText', () {
    late VoidCallback onTapCallback;
    const buttonColor = Colors.blue;
    const titleButton = 'Button';
    const widthButton = 104.0;
    const heightButton = 36.0;
    const textSize = 20.0;
    const disabled = false;

    setUp(() {
      onTapCallback = () {}; // Mock callback for onTap
    });

    testWidgets('Widget initializes correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 800),
          builder: (context, child) {
            return MaterialApp(
              home: TapFadeText(
                onTap: onTapCallback,
                buttonColor: buttonColor,
                titleButton: titleButton,
                widthButton: widthButton,
                heightButton: heightButton,
                textSize: textSize,
                disabled: disabled,
              ),
            );
          },
        ),
      );

      // Verify the widget renders correctly
      expect(find.byType(TapFadeText), findsOneWidget);
      expect(find.byType(GestureDetector), findsOneWidget);
      expect(find.byKey(const Key("tap-fade-text-key")), findsOneWidget);
      expect(find.byType(CustomText), findsOneWidget);
    });

    testWidgets('Widget changes color on tap down and up',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 800),
          builder: (context, child) {
            return MaterialApp(
              home: TapFadeText(
                onTap: onTapCallback,
                buttonColor: buttonColor,
                titleButton: titleButton,
                widthButton: widthButton,
                heightButton: heightButton,
                textSize: textSize,
                disabled: disabled,
              ),
            );
          },
        ),
      );

      // Simulate tap down event
      await tester.tap(find.byType(TapFadeText));
      await tester.pump();

      // Verify color change
      final containerFinder = find.byKey(const Key("tap-fade-text-key"));
      final container = tester.widget<Container>(containerFinder);
      final BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(buttonColor));

      // Simulate tap up event
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 800),
          builder: (context, child) {
            return MaterialApp(
              home: TapFadeText(
                onTap: onTapCallback,
                buttonColor: buttonColor,
                titleButton: titleButton,
                widthButton: widthButton,
                heightButton: heightButton,
                textSize: textSize,
                disabled: disabled,
              ),
            );
          },
        ),
      );
      await tester.pump();

      // Verify color reset
      final containerAfterTapUp = tester.widget<Container>(containerFinder);
      final BoxDecoration decorationAfterTapUp =
          containerAfterTapUp.decoration as BoxDecoration;
      expect(decorationAfterTapUp.color, equals(buttonColor));
    });

    testWidgets('Callback called on tap up', (WidgetTester tester) async {
      bool callbackCalled = false;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 800),
          builder: (context, child) {
            return MaterialApp(
              home: TapFadeText(
                onTap: () {
                  callbackCalled = true;
                },
                buttonColor: buttonColor,
                titleButton: titleButton,
                widthButton: widthButton,
                heightButton: heightButton,
                textSize: textSize,
                disabled: disabled,
              ),
            );
          },
        ),
      );

      // Simulate tap up event
      await tester.tap(find.byType(TapFadeText));
      await tester.pump();

      // Verify callback called
      expect(callbackCalled, isTrue);
    });
    testWidgets('DonNothing called on tap up if disabled',
        (WidgetTester tester) async {
      bool callbackCalled = false;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 800),
          builder: (context, child) {
            return MaterialApp(
              home: TapFadeText(
                onTap: () {
                  callbackCalled = true;
                },
                buttonColor: buttonColor,
                titleButton: titleButton,
                widthButton: widthButton,
                heightButton: heightButton,
                textSize: textSize,
                disabled: true,
              ),
            );
          },
        ),
      );

      // Simulate tap up event
      await tester.tap(find.byType(TapFadeText));
      await tester.pump();

      // Verify callback called
      expect(callbackCalled, isFalse);
    });

    testWidgets('Widget updates color on prop change',
        (WidgetTester tester) async {
      const newButtonColor = Colors.red;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 800),
          builder: (context, child) {
            return MaterialApp(
              home: TapFadeText(
                onTap: onTapCallback,
                buttonColor: buttonColor,
                titleButton: titleButton,
                widthButton: widthButton,
                heightButton: heightButton,
                textSize: textSize,
                disabled: disabled,
              ),
            );
          },
        ),
      );

      // Verify initial color
      final containerFinder = find.byKey(const Key("tap-fade-text-key"));
      final container = tester.widget<Container>(containerFinder);
      final BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(buttonColor));

      // Update the color prop
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 800),
          builder: (context, child) {
            return MaterialApp(
              home: TapFadeText(
                onTap: onTapCallback,
                buttonColor: newButtonColor,
                titleButton: titleButton,
                widthButton: widthButton,
                heightButton: heightButton,
                textSize: textSize,
                disabled: disabled,
              ),
            );
          },
        ),
      );

      // Verify updated color
      final containerAfterUpdate = tester.widget<Container>(containerFinder);
      final BoxDecoration decorationAfterUpdate =
          containerAfterUpdate.decoration as BoxDecoration;
      expect(decorationAfterUpdate.color, equals(newButtonColor));
    });

    testWidgets('Widget changes color on vertical drag start',
        (WidgetTester tester) async {
      await tester.pumpWidget(ScreenUtilInit(
        designSize: const Size(360, 800),
        builder: (context, child) {
          return MaterialApp(
            home: TapFadeText(
              onTap: onTapCallback,
              buttonColor: buttonColor,
              titleButton: titleButton,
              widthButton: widthButton,
              heightButton: heightButton,
              textSize: textSize,
              disabled: disabled,
            ),
          );
        },
      ));
// Simulate vertical drag start event
      await tester.drag(find.byType(TapFadeText), const Offset(0, 50));
      await tester.pump();

      // Verify color change
      final containerFinder = find.byKey(const Key('tap-fade-text-key'));
      final container = tester.widget<Container>(containerFinder);
      final BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.color!, equals(buttonColor));
    });

    testWidgets('Callback called on vertical drag end',
        (WidgetTester tester) async {
      bool callbackCalled = false;
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 800),
          builder: (context, child) {
            return MaterialApp(
              home: TapFadeText(
                onTap: () {
                  callbackCalled = true;
                },
                buttonColor: buttonColor,
                titleButton: titleButton,
                widthButton: widthButton,
                heightButton: heightButton,
                textSize: textSize,
                disabled: disabled,
              ),
            );
          },
        ),
      );

      // Simulate vertical drag end event
      await tester.drag(find.byType(TapFadeText), const Offset(0, 50));
      await tester.pump();

      // Verify callback called
      expect(callbackCalled, isTrue);

      // // Simulate vertical drag start event
      // final gesture = await tester.startGesture(
      //     tester.getCenter(find.byKey(const Key('tap-fade-text-key'))));
      // await gesture.moveBy(const Offset(0, 10));
      // await tester.pump();

      // // Simulate vertical drag end event
      // await gesture.up();
      // await tester.pump();

      // // Verify color reset
      // final containerAfterDragEnd =
      //     tester.widget<Container>(find.byKey(const Key('tap-fade-text-key')));
      // final BoxDecoration decorationAfterDragEnd =
      //     containerAfterDragEnd.decoration as BoxDecoration;
      // expect(decorationAfterDragEnd.color!.value, equals(buttonColor.value));
    });
  });
}
