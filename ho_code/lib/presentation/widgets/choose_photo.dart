import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/presentation/utils/cache_images.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hang_out_app/presentation/utils/colors.dart';

class ChoosePhoto extends StatefulWidget {
  final Function choosePhotoCallback;
  final int borderRadius;
  final String oldPhoto;
  final ImagePicker? imagePicker;

  const ChoosePhoto(
      {Key? key,
      required this.choosePhotoCallback,
      required this.borderRadius,
      this.oldPhoto = "",
      this.imagePicker})
      : super(key: key);

  @override
  State<ChoosePhoto> createState() => _ChoosePhotoState();
}

class _ChoosePhotoState extends State<ChoosePhoto> {
  XFile? image;

  @override
  Widget build(BuildContext context) {
    ImagePicker imagePicker =
        widget.imagePicker != null ? widget.imagePicker! : ImagePicker();
    if (getSize(context) == ScreenSize.normal) {
      return _buildChoosePhoto(imagePicker, context);
    }
    return _buildTabletChoosePhoto(imagePicker, context);
  }

  Widget _buildChoosePhoto(ImagePicker imagePicker, BuildContext context) {
    return GestureDetector(
      child: image != null
          ? SizedBox(
              width: 60.r,
              height: 60.r,
              child: ClipRRect(
                // width: 60.w,
                // height: 60.h,
                borderRadius: BorderRadius.circular(widget.borderRadius.r),

                //     height: 60.h,
                child: Image.file(
                  File(image!.path),
                  fit: BoxFit.cover,
                ),
              ),
            )
          : Container(
              width: 60.r,
              height: 60.r,
              decoration: BoxDecoration(
                color: AppColors.grayColor,
                image: widget.oldPhoto != ""
                    ? DecorationImage(
                        image: ImageManager.getImageProvider(widget.oldPhoto),
                        fit: BoxFit.cover)
                    : null,
                borderRadius: BorderRadius.circular(widget.borderRadius.r),
              ),
              child: widget.oldPhoto != ""
                  ? null
                  : Icon(
                      AppIcons.cameraOutline,
                      color: AppColors.whiteColor,
                      size: Constants.iconDimension,
                    ),
            ),
      onTap: () async {
        await _pickImage(imagePicker);
      },
    );
  }

  Future<void> _pickImage(ImagePicker imagePicker) async {
    XFile? file = await imagePicker.pickImage(
      source: ImageSource.gallery,
      // maxHeight: 1800,
      // maxWidth: 1800,
    );
    if (file != null) {
      // MyEventsRepository testRepo =
      //     MyEventsRepository();
      // String? newURL =
      //     await testRepo.uploadImage(file);
      // imageDevicePath = file.path;
      setState(
        () {
          image = file;
          widget.choosePhotoCallback(image);
          // imageURL = newURL ?? "";
        },
      );
    }
  }

  Widget _buildTabletChoosePhoto(
      ImagePicker imagePicker, BuildContext context) {
    return GestureDetector(
      child: image != null
          ? SizedBox(
              width: TabletConstants.resizeR(200),
              height: TabletConstants.resizeR(200),
              child: ClipRRect(
                // width: 60.w,
                // height: 60.h,
                borderRadius: BorderRadius.circular(
                    TabletConstants.resizeR(widget.borderRadius.toDouble())),

                //     height: 60.h,
                child: Image.file(
                  File(image!.path),
                  fit: BoxFit.cover,
                ),
              ),
            )
          : Container(
              width: TabletConstants.resizeR(200),
              height: TabletConstants.resizeR(200),
              decoration: BoxDecoration(
                color: AppColors.grayColor,
                image: widget.oldPhoto != ""
                    ? DecorationImage(
                        image: ImageManager.getImageProvider(widget.oldPhoto),
                        fit: BoxFit.cover)
                    : null,
                borderRadius: BorderRadius.circular(
                    TabletConstants.resizeR(widget.borderRadius.toDouble())),
              ),
              child: widget.oldPhoto != ""
                  ? null
                  : Icon(
                      AppIcons.cameraOutline,
                      color: AppColors.whiteColor,
                      size: TabletConstants.iconDimension(),
                    ),
            ),
      onTap: () async {
        await _pickImage(imagePicker);
      },
    );
  }
}
