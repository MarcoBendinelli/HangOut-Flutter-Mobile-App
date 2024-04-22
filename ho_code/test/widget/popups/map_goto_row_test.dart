import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/presentation/widgets/popups/map_goto_row.dart';

void main() {
  group("Map go to row", () {
    testWidgets("renders correctly when location is present", (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(ScreenUtilInit(
          designSize: const Size(360, 800),
          builder: (context, child) {
            return const MaterialApp(
              home: MapGoToRow(
                  location: GeoPoint(0, 0), locationName: "locationName"),
            );
          },
        ));
        expect(find.text("Location:"), findsOneWidget);
        expect(find.text("locationName"), findsOneWidget);
        await tester.tap(find.text("locationName"));
        await tester.pumpAndSettle();
        expect(find.text("Location:"), findsOneWidget);
        expect(find.text("locationName"), findsOneWidget);
      });
    });
    testWidgets(
        "renders correctly when location is NOT present and tap does nothing",
        (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(ScreenUtilInit(
          designSize: const Size(360, 800),
          builder: (context, child) {
            return const MaterialApp(
              home: MapGoToRow(location: GeoPoint(0, 0), locationName: ""),
            );
          },
        ));
        expect(find.text("Location:"), findsOneWidget);
        expect(find.text("This event has no location"), findsOneWidget);
        await tester.tap(find.text("This event has no location"));
        await tester.pumpAndSettle();
        expect(find.text("Location:"), findsOneWidget);
        expect(find.text("This event has no location"), findsOneWidget);
      });
    });
  });
}
