import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:formz/formz.dart';
import 'package:hang_out_app/presentation/sign_up/sign_up_tablet_page.dart';
import 'package:hang_out_app/presentation/utils/colors.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/business_logic/cubits/login/login_cubit.dart';
import 'package:hang_out_app/presentation/widgets/our_circular_progress_indicator.dart';

class LoginTabletForm extends StatelessWidget {
  const LoginTabletForm({super.key});

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
      child: OrientationBuilder(builder: (context, orientation) {
        TabletConstants.setOrientation(MediaQuery.of(context).orientation);
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SingleChildScrollView(
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: TabletConstants.resizeH(315),
                  ),
                  Image(
                    image: Theme.of(context).brightness == Brightness.light
                        ? const AssetImage("assets/logo_written.png")
                        : const AssetImage("assets/logo_written_white.png"),
                    width: TabletConstants.resizeW(115),
                  ),
                  // CustomText(
                  //   text: "HangOut",
                  //   size: TabletConstants.hangOutTextDimension(),
                  //   fontWeight: Fonts.bold,
                  //   fontFamily: "Inter",
                  // ),
                  SizedBox(
                    height: TabletConstants.resizeH(50),
                  ),
                  _EmailInput(),
                  SizedBox(
                    height: TabletConstants.heightBetweenInputForm(),
                  ),
                  _PasswordInput(),
                  SizedBox(
                    height: TabletConstants.heightBetweenInputForm(),
                  ),
                  _GoogleLoginButton(),
                  SizedBox(
                    height: TabletConstants.heightBetweenInputForm(),
                  ),
                  _TwitterLoginButton(),
                  SizedBox(
                    height: TabletConstants.resizeH(70),
                  ),
                  _SignUpButton(),
                  SizedBox(
                    height: TabletConstants.heightBetweenInputForm(),
                  ),
                  _LoginButton(),
                ],
              ),
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
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return SizedBox(
          height: TabletConstants.formInputHeight(),
          width: TabletConstants.formInputWidth(),
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
          height: TabletConstants.formInputHeight(),
          width: TabletConstants.formInputWidth(),
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
            : SizedBox(
                height: TabletConstants.resizeH(60),
                width: TabletConstants.resizeW(170),
                child: ElevatedButton(
                  key: const Key('loginForm_continue_raisedButton'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.googleSignInColor,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(TabletConstants.borderRadius()),
                    ),
                  ),
                  onPressed: state.status.isValidated
                      ? () => context.read<LoginCubit>().logInWithCredentials()
                      : null,
                  child: CustomText(
                    text: 'login',
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

class _GoogleLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: TabletConstants.formInputWidth(),
      height: TabletConstants.formInputHeight(),
      child: ElevatedButton.icon(
        key: const Key('loginForm_googleLogin_raisedButton'),
        label: CustomText(
          text: 'sign in with google',
          fontFamily: "Inter",
          fontWeight: Fonts.regular,
          size: TabletConstants.resizeR(20),
          color: AppColors.whiteColor,
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TabletConstants.borderRadius()),
          ),
          backgroundColor: AppColors.googleSignInColor,
        ),
        icon: const Icon(FontAwesomeIcons.google, color: AppColors.whiteColor),
        onPressed: () => context.read<LoginCubit>().logInWithGoogle(),
      ),
    );
  }
}

class _TwitterLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: TabletConstants.formInputWidth(),
      height: TabletConstants.formInputHeight(),
      child: ElevatedButton.icon(
        key: const Key('loginForm_twitterLogin_raisedButton'),
        label: CustomText(
          text: 'sign in with twitter',
          fontFamily: "Inter",
          fontWeight: Fonts.regular,
          size: TabletConstants.resizeR(20),
          color: AppColors.whiteColor,
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TabletConstants.borderRadius()),
          ),
          backgroundColor: AppColors.twitterSignInColor,
        ),
        icon: const Icon(FontAwesomeIcons.twitter, color: AppColors.whiteColor),
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
        size: TabletConstants.resizeR(20),
        fontWeight: Fonts.regular,
        fontFamily: "Inter",
      ),
      onTap: () => Navigator.of(context).push<void>(SignUpTabletPage.route()),
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
