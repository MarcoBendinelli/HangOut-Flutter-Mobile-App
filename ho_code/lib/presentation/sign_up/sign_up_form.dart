import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:formz/formz.dart';
import 'package:hang_out_app/presentation/utils/colors.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hang_out_app/business_logic/cubits/sign_up/sign_up_cubit.dart';
import 'package:hang_out_app/presentation/widgets/our_circular_progress_indicator.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpCubit, SignUpState>(
      listener: (context, state) {
        if (state.status.isSubmissionSuccess) {
          Navigator.of(context).pop();
        } else if (state.status.isSubmissionFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Sign Up Failure')),
            );
        }
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 360.h,
                child: Column(
                  children: [
                    SizedBox(
                      height: 10.h,
                    ),
                    GestureDetector(
                      child: Row(
                        children: [
                          Icon(
                            AppIcons.arrowIosBackOutline,
                            size: Constants.iconDimension,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Image(
                              image: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? const AssetImage("assets/logo_written.png")
                                  : const AssetImage(
                                      "assets/logo_written_white.png"),
                              width: 75.w,
                            ),
                          ),
                          // CustomText(
                          //   text: "Hangout",
                          //   size: 20.r,
                          //   fontWeight: Fonts.bold,
                          //   fontFamily: "Inter",
                          // ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(
                      height: 96.h,
                    ),
                    const PhotoInput(),
                    SizedBox(
                      height: 20.h,
                    ),
                    _NameInput(),
                  ],
                ),
              ),
              _EmailInput(),
              SizedBox(height: 15.h),
              _PasswordInput(),
              SizedBox(height: 15.h),
              _ConfirmPasswordInput(),
              SizedBox(
                height: 146.h,
              ),
              _SignUpButton()
            ],
          ),
        ),
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return SizedBox(
          height: Constants.formInputHeight,
          width: Constants.formInputWidth,
          child: TextField(
            key: const Key('signUpForm_emailInput_textField'),
            onChanged: (email) =>
                context.read<SignUpCubit>().emailChanged(email),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              fillColor: Theme.of(context).cardColor,
              filled: true,
              suffix: CustomText(
                text: state.email.invalid ? 'invalid email' : "",
                fontFamily: "Raleway",
                fontWeight: Fonts.bold,
                size: 10.r,
                color: Theme.of(context).colorScheme.error,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
              border: InputBorder.none,
              // Removes the border
              focusedBorder: Constants.formBorder,
              enabledBorder: Constants.formBorder,
              errorBorder: Constants.formBorder,
              focusedErrorBorder: Constants.formBorder,
              disabledBorder: Constants.formBorder,
              hintText: 'E-mail',
              // helperText: '',
              // errorText: state.email.invalid ? 'invalid email' : null,
            ),
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return SizedBox(
          height: Constants.formInputHeight,
          width: Constants.formInputWidth,
          child: TextField(
            key: const Key('signUpForm_passwordInput_textField'),
            onChanged: (password) =>
                context.read<SignUpCubit>().passwordChanged(password),
            obscureText: true,
            decoration: InputDecoration(
              suffix: CustomText(
                text: state.password.invalid ? 'invalid password' : "",
                fontFamily: "Raleway",
                fontWeight: Fonts.bold,
                size: 10.r,
                color: Theme.of(context).colorScheme.error,
              ),
              fillColor: Theme.of(context).cardColor,
              filled: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
              border: InputBorder.none,
              // Removes the border
              focusedBorder: Constants.formBorder,
              enabledBorder: Constants.formBorder,
              errorBorder: Constants.formBorder,
              focusedErrorBorder: Constants.formBorder,
              disabledBorder: Constants.formBorder,
              hintText: 'Password',
              // helperText: '',
              // errorText: state.password.invalid ? 'invalid password' : null,
            ),
          ),
        );
      },
    );
  }
}

class _ConfirmPasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) =>
          previous.password != current.password ||
          previous.confirmedPassword != current.confirmedPassword,
      builder: (context, state) {
        return SizedBox(
          height: Constants.formInputHeight,
          width: Constants.formInputWidth,
          child: TextField(
            key: const Key('signUpForm_confirmedPasswordInput_textField'),
            onChanged: (confirmPassword) => context
                .read<SignUpCubit>()
                .confirmedPasswordChanged(confirmPassword),
            obscureText: true,
            decoration: InputDecoration(
              suffix: CustomText(
                text: state.confirmedPassword.invalid ? 'no match' : "",
                fontFamily: "Raleway",
                fontWeight: Fonts.bold,
                size: 10.r,
                color: Theme.of(context).colorScheme.error,
              ),
              fillColor: Theme.of(context).cardColor,
              filled: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
              border: InputBorder.none,
              // Removes the border
              focusedBorder: Constants.formBorder,
              enabledBorder: Constants.formBorder,
              errorBorder: Constants.formBorder,
              focusedErrorBorder: Constants.formBorder,
              disabledBorder: Constants.formBorder,
              hintText: 'Confirm password',
              // helperText: '',
              // errorText: state.confirmedPassword.invalid
              //     ? 'passwords do not match'
              //     : null,
            ),
          ),
        );
      },
    );
  }
}

class _NameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) => previous.name != current.name,
      builder: (context, state) {
        return Column(
          children: [
            TextField(
              key: const Key('signUpForm_nameInput_textField'),
              onChanged: (name) =>
                  context.read<SignUpCubit>().nameChanged(name),
              keyboardType: TextInputType.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: "Inter", fontSize: 20.r, fontWeight: Fonts.bold),
              decoration: InputDecoration(
                // fillColor: AppColors.whiteColor,
                // filled: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
                hintStyle: TextStyle(
                    // color: AppColors.blackColor,
                    fontFamily: "Inter",
                    fontSize: 20.r,
                    fontWeight: Fonts.bold),
                hintText: 'Nickname',

                // helperText: '',
                border: InputBorder.none,
                // Removes the gray line under the text
                // errorText: state.name.invalid
                //     ? 'invalid name (must start with capital letter)'
                //     : null,
              ),
            ),
            CustomText(
              text: state.name.invalid
                  ? 'invalid name (must start with capital letter)'
                  : "",
              color: Theme.of(context).colorScheme.error,
            ),
          ],
        );
      },
    );
  }
}

class PhotoInput extends StatelessWidget {
  final ImagePicker? imagePicker;
  const PhotoInput({super.key, this.imagePicker});
  @override
  Widget build(BuildContext context) {
    ImagePicker imagePicker = this.imagePicker ?? ImagePicker();
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) => previous.photo != current.photo,
      builder: (context, state) {
        return GestureDetector(
          key: const Key('signUpForm_photoInput_button'),
          child: state.photo != null
              ? CircleAvatar(
                  radius: 59.r,
                  backgroundImage: FileImage(
                    File(state.photo!.path),
                    // fit: BoxFit.cover,
                  ),
                )
              : CircleAvatar(
                  backgroundColor: AppColors.transparentLogin,
                  radius: 59.r,
                  child: Icon(
                    AppIcons.cameraOutline,
                    size: Constants.iconDimension,
                    color: AppColors.whiteColor,
                  ),
                ),
          onTap: () async {
            XFile? file = await imagePicker.pickImage(
              source: ImageSource.gallery,
              // maxHeight: 1800,
              // maxWidth: 1800,
            );
            if (file != null && context.mounted) {
              context.read<SignUpCubit>().photoChanged(file);
            }
          },
        );
      },
    );

    // CircleAvatar(
    //   backgroundImage: const AssetImage("assets/images/example.png"),
    //   radius: 55.r,
    // );
  }
}

class _SignUpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status.isSubmissionInProgress
            ? const OurCircularProgressIndicator()
            : ElevatedButton(
                key: const Key('signUpForm_continue_raisedButton'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.googleSignInColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Constants.borderRadius),
                  ),
                ),
                onPressed: state.status.isValidated
                    ? () => context.read<SignUpCubit>().signUpFormSubmitted()
                    : null,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: CustomText(
                    text: 'create',
                    size: 20.r,
                    fontWeight: Fonts.medium,
                    fontFamily: "Inter",
                    color: AppColors.whiteColor,
                  ),
                ),
              );
      },
    );
  }
}
