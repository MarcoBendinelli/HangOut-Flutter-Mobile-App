import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:hang_out_app/presentation/utils/colors.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hang_out_app/business_logic/cubits/sign_up/sign_up_cubit.dart';
import 'package:hang_out_app/presentation/widgets/our_circular_progress_indicator.dart';

class SignUpTabletForm extends StatelessWidget {
  const SignUpTabletForm({super.key});

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
      child: OrientationBuilder(builder: (context, orientation) {
        TabletConstants.setOrientation(MediaQuery.of(context).orientation);
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  children: [
                    GestureDetector(
                      child: Row(
                        children: [
                          Icon(
                            AppIcons.arrowIosBackOutline,
                            size: TabletConstants.iconDimension(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: TabletConstants.resizeH(8)),
                            child: Image(
                              image: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? const AssetImage("assets/logo_written.png")
                                  : const AssetImage(
                                      "assets/logo_written_white.png"),
                              width: TabletConstants.resizeW(115),
                            ),
                          ),
                          // CustomText(
                          //   text: "HangOut",
                          //   size: TabletConstants.hangOutTextDimension(),
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
                      height: TabletConstants.resizeH(110),
                    ),
                    const PhotoInput(),
                    SizedBox(
                      height: TabletConstants.resizeH(20),
                    ),
                    _NameInput(),
                  ],
                ),
                SizedBox(
                  height: TabletConstants.resizeH(25),
                ),
                _EmailInput(),
                SizedBox(
                  height: TabletConstants.heightBetweenInputForm(),
                ),
                _PasswordInput(),
                SizedBox(
                  height: TabletConstants.heightBetweenInputForm(),
                ),
                _ConfirmPasswordInput(),
                SizedBox(
                  height: TabletConstants.resizeH(184),
                ),
                _SignUpButton()
              ],
            ),
          ),
        );
      }),
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
          width: TabletConstants.formInputWidth(),
          height: TabletConstants.formInputHeight(),
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
                size: TabletConstants.resizeR(12),
                color: Theme.of(context).colorScheme.error,
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: TabletConstants.resizeW(30)),
              border: InputBorder.none,
              // Removes the border
              focusedBorder: TabletConstants.formBorder(),
              enabledBorder: TabletConstants.formBorder(),
              errorBorder: TabletConstants.formBorder(),
              focusedErrorBorder: TabletConstants.formBorder(),
              disabledBorder: TabletConstants.formBorder(),
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
          width: TabletConstants.formInputWidth(),
          height: TabletConstants.formInputHeight(),
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
                size: TabletConstants.resizeR(12),
                color: Theme.of(context).colorScheme.error,
              ),
              fillColor: Theme.of(context).cardColor,
              filled: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: TabletConstants.resizeW(30)),
              border: InputBorder.none,
              // Removes the border
              focusedBorder: TabletConstants.formBorder(),
              enabledBorder: TabletConstants.formBorder(),
              errorBorder: TabletConstants.formBorder(),
              focusedErrorBorder: TabletConstants.formBorder(),
              disabledBorder: TabletConstants.formBorder(),
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
          width: TabletConstants.formInputWidth(),
          height: TabletConstants.formInputHeight(),
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
                size: TabletConstants.resizeR(12),
                color: Theme.of(context).colorScheme.error,
              ),
              fillColor: Theme.of(context).cardColor,
              filled: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: TabletConstants.resizeW(30)),
              border: InputBorder.none,
              // Removes the border
              focusedBorder: TabletConstants.formBorder(),
              enabledBorder: TabletConstants.formBorder(),
              errorBorder: TabletConstants.formBorder(),
              focusedErrorBorder: TabletConstants.formBorder(),
              disabledBorder: TabletConstants.formBorder(),
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
                  fontFamily: "Inter",
                  fontSize: TabletConstants.resizeH(24),
                  fontWeight: Fonts.bold),
              decoration: InputDecoration(
                // fillColor: AppColors.whiteColor,
                // filled: true,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: TabletConstants.resizeW(10)),
                hintStyle: TextStyle(
                    // color: AppColors.blackColor,
                    fontFamily: "Inter",
                    fontSize: TabletConstants.resizeR(24),
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
            )
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
                  radius: TabletConstants.resizeR(76),
                  backgroundImage: FileImage(
                    File(state.photo!.path),
                    // fit: BoxFit.cover,
                  ),
                )
              : CircleAvatar(
                  backgroundColor: AppColors.transparentLogin,
                  radius: TabletConstants.resizeR(76),
                  child: Icon(
                    AppIcons.cameraOutline,
                    size: TabletConstants.iconDimension(),
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
            : SizedBox(
                height: TabletConstants.resizeH(60),
                width: TabletConstants.resizeW(170),
                child: ElevatedButton(
                  key: const Key('signUpForm_continue_raisedButton'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.googleSignInColor,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(TabletConstants.borderRadius()),
                    ),
                  ),
                  onPressed: state.status.isValidated
                      ? () => context.read<SignUpCubit>().signUpFormSubmitted()
                      : null,
                  child: CustomText(
                    text: 'create',
                    size: TabletConstants.resizeR(24),
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
