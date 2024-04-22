import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/choose_photo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';

class MockImagePicker extends Mock implements ImagePicker {}

void main() {
  late MockImagePicker mockImagePicker;

  setUp(() {
    mockImagePicker = MockImagePicker();
  });

  group('ChoosePhoto widget phone', () {
    testWidgets('should show default camera icon when no photo is selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 800),
          builder: (context, child) {
            return MaterialApp(
              home: Scaffold(
                body: ChoosePhoto(
                  choosePhotoCallback: (_) {},
                  borderRadius: 10,
                ),
              ),
            );
          },
        ),
      );

      expect(find.byIcon(AppIcons.cameraOutline), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('should show selected image when photo is selected',
        (WidgetTester tester) async {
      when(() => mockImagePicker.pickImage(
            source: ImageSource.gallery,
          )).thenAnswer((_) async => XFile('test_resources/example.jpg'));

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 800),
          builder: (context, child) {
            return MaterialApp(
              home: Scaffold(
                body: ChoosePhoto(
                  imagePicker: mockImagePicker,
                  choosePhotoCallback: (_) {},
                  borderRadius: 10,
                ),
              ),
            );
          },
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(AppIcons.cameraOutline), findsNothing);
    });

    testWidgets('should show old photo if present',
        (WidgetTester tester) async {
      when(() => mockImagePicker.pickImage(
            source: ImageSource.gallery,
          )).thenAnswer((_) async => XFile('test_resources/example.jpg'));
      await mockNetworkImagesFor(() async => await tester.pumpWidget(
            ScreenUtilInit(
              designSize: const Size(360, 800),
              builder: (context, child) {
                return MaterialApp(
                  home: Scaffold(
                    body: ChoosePhoto(
                      oldPhoto: 'https://example.com/some_image.jpg',
                      imagePicker: mockImagePicker,
                      choosePhotoCallback: (_) {},
                      borderRadius: 10,
                    ),
                  ),
                );
              },
            ),
          ));

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(AppIcons.cameraOutline), findsNothing);
    });

    // testWidgets('should call choosePhotoCallback with selected image',
    //     (WidgetTester tester) async {
    //   XFile selectedImage = XFile('test_resources/example.jpg');

    //   when(() => mockImagePicker.pickImage(
    //         source: ImageSource.gallery,
    //       )).thenAnswer((_) async => selectedImage);

    //   choosePhotoCallback(XFile? image) {}
    //   await tester.pumpWidget(
    //     ScreenUtilInit(
    //       designSize: const Size(360, 800),
    //       builder: (context, child) {
    //         return MaterialApp(
    //           home: Scaffold(
    //             body: ChoosePhoto(
    //               imagePicker: mockImagePicker,
    //               choosePhotoCallback: choosePhotoCallback,
    //               borderRadius: 10,
    //             ),
    //           ),
    //         );
    //       },
    //     ),
    //   );

    //   await tester.tap(find.byType(GestureDetector));
    //   await tester.pumpAndSettle();

    //   verify(() => choosePhotoCallback(selectedImage)).called(1);
    // });
  });
  group('ChoosePhoto widget tablet', () {
    const Size tabletLandscapeSize = Size(1374, 1024);
    // const Size tabletPortraitSize = Size(1024, 1374);
    testWidgets('should show default camera icon when no photo is selected',
        (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = tabletLandscapeSize;
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
              size: tabletLandscapeSize, devicePixelRatio: 1.0),
          child: ScreenUtilInit(
            designSize: tabletLandscapeSize,
            builder: (context, child) {
              TabletConstants.setDimensions(context);
              PopupTabletConstants.setSmallestDimension(context);
              return MaterialApp(
                home: Scaffold(
                  body: ChoosePhoto(
                    choosePhotoCallback: (_) {},
                    borderRadius: 10,
                  ),
                ),
              );
            },
          ),
        ),
      );

      expect(find.byIcon(AppIcons.cameraOutline), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testWidgets('should show selected image when photo is selected',
        (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = tabletLandscapeSize;
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      when(() => mockImagePicker.pickImage(
            source: ImageSource.gallery,
          )).thenAnswer((_) async => XFile('test_resources/example.jpg'));

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
              size: tabletLandscapeSize, devicePixelRatio: 1.0),
          child: ScreenUtilInit(
            designSize: tabletLandscapeSize,
            builder: (context, child) {
              TabletConstants.setDimensions(context);
              PopupTabletConstants.setSmallestDimension(context);
              return MaterialApp(
                home: Scaffold(
                  body: ChoosePhoto(
                    imagePicker: mockImagePicker,
                    choosePhotoCallback: (_) {},
                    borderRadius: 10,
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(AppIcons.cameraOutline), findsNothing);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testWidgets('should show old photo if present',
        (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = tabletLandscapeSize;
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      when(() => mockImagePicker.pickImage(
            source: ImageSource.gallery,
          )).thenAnswer((_) async => XFile('test_resources/example.jpg'));
      await mockNetworkImagesFor(() async => await tester.pumpWidget(
            MediaQuery(
              data: const MediaQueryData(
                  size: tabletLandscapeSize, devicePixelRatio: 1.0),
              child: ScreenUtilInit(
                designSize: tabletLandscapeSize,
                builder: (context, child) {
                  TabletConstants.setDimensions(context);
                  PopupTabletConstants.setSmallestDimension(context);
                  return MaterialApp(
                    home: Scaffold(
                      body: ChoosePhoto(
                        oldPhoto: 'https://example.com/some_image.jpg',
                        imagePicker: mockImagePicker,
                        choosePhotoCallback: (_) {},
                        borderRadius: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
          ));

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(AppIcons.cameraOutline), findsNothing);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
  });
}
