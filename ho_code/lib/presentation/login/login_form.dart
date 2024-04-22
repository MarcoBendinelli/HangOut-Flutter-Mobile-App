import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:formz/formz.dart';
import 'package:hang_out_app/presentation/utils/colors.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/business_logic/cubits/login/login_cubit.dart';
import 'package:hang_out_app/presentation/sign_up/sign_up_page.dart';
import 'package:hang_out_app/presentation/widgets/our_circular_progress_indicator.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.status.isSubmissionFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Authentication Failure'),
              ),
            );
        }
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          child: Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                SizedBox(
                  height: 270.h,
                ),
                Image(
                  image: Theme.of(context).brightness == Brightness.light
                      ? const AssetImage("assets/logo_written.png")
                      : const AssetImage("assets/logo_written_white.png"),
                  width: 115.w,
                ),
                // CustomText(
                //   text: "HangOut",
                //   size: 24.r,
                //   fontWeight: Fonts.bold,
                //   fontFamily: "Inter",
                // ),
                SizedBox(height: 65.h),
                _EmailInput(),
                SizedBox(height: 15.h),
                _PasswordInput(),
                SizedBox(height: 15.h),
                _GoogleLoginButton(),
                SizedBox(height: 15.h),
                _TwitterLoginButton(),
                // SizedBox(
                //   height: 128.h,
                // ),
                SizedBox(
                  height: 78.h,
                ),
                _SignUpButton(),
                SizedBox(
                  height: 5.h,
                ),
                _LoginButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return SizedBox(
          height: Constants.formInputHeight,
          width: Constants.formInputWidth,
          child: TextField(
            key: const Key('loginForm_emailInput_textField'),
            onChanged: (email) =>
                context.read<LoginCubit>().emailChanged(email),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              suffix: CustomText(
                text: state.email.invalid ? 'invalid email' : "",
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
              hintText: 'E-mail',
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
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return SizedBox(
          height: Constants.formInputHeight,
          width: Constants.formInputWidth,
          child: TextField(
            key: const Key('loginForm_passwordInput_textField'),
            onChanged: (password) =>
                context.read<LoginCubit>().passwordChanged(password),
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
              // errorText: state.password.invalid ? 'invalid password' : null,
            ),
          ),
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status.isSubmissionInProgress
            ? const OurCircularProgressIndicator()
            : ElevatedButton(
                key: const Key('loginForm_continue_raisedButton'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.googleSignInColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Constants.borderRadius),
                  ),
                ),
                onPressed: state.status.isValidated
                    ? () => context.read<LoginCubit>().logInWithCredentials()
                    : null,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: CustomText(
                    text: 'login',
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

class _GoogleLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Constants.formInputWidth,
      height: Constants.formInputHeight,
      child: ElevatedButton.icon(
        key: const Key('loginForm_googleLogin_raisedButton'),
        label: CustomText(
          text: 'sign in with google',
          fontFamily: "Inter",
          fontWeight: Fonts.regular,
          size: 14.r,
          color: AppColors.whiteColor,
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Constants.borderRadius),
          ),
          backgroundColor: AppColors.googleSignInColor,
        ),
        icon: Icon(
          FontAwesomeIcons.google,
          color: AppColors.whiteColor,
          size: 20.r,
        ),
        onPressed: () => context.read<LoginCubit>().logInWithGoogle(),
      ),
    );
  }
}

class _TwitterLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Constants.formInputWidth,
      height: Constants.formInputHeight,
      child: ElevatedButton.icon(
        key: const Key('loginForm_twitterLogin_raisedButton'),
        label: CustomText(
          text: 'sign in with twitter',
          fontFamily: "Inter",
          fontWeight: Fonts.regular,
          size: 14.r,
          color: AppColors.whiteColor,
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Constants.borderRadius),
          ),
          backgroundColor: AppColors.twitterSignInColor,
        ),
        icon: Icon(
          FontAwesomeIcons.twitter,
          color: AppColors.whiteColor,
          size: 20.r,
        ),
        onPressed: () => context.read<LoginCubit>().logInWithTwitter(),
      ),
    );
  }
}

class _SignUpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key("loginForm_createAccount_flatButton"),
      child: CustomText(
        text: 'create an account',
        size: 12.r,
        fontWeight: Fonts.regular,
        fontFamily: "Inter",
      ),
      onTap: () => Navigator.of(context).push<void>(SignUpPage.route()),
    );
    // return TextButton(
    //   key: const Key('loginForm_createAccount_flatButton'),
    //   onPressed: () => Navigator.of(context).push<void>(SignUpPage.route()),
    //   child: CustomText(
    //     text: 'create an account',
    //     size: 12,
    //     fontWeight: Fonts.regular,
    //     fontFamily: "Inter",
    //   ),
    // );
  }
}
