import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hang_out_app/presentation/sign_up/sign_up_form.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/business_logic/cubits/sign_up/sign_up_cubit.dart';
import 'package:hang_out_app/data/repositories/authentication_repository.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const SignUpPage());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Theme.of(context).brightness == Brightness.light
                ? const AssetImage(Constants.phoneBgSignUp)
                : const AssetImage(Constants.phoneDarkBgSignUp),
            fit: BoxFit.cover,
            // opacity: 1,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Padding(
              padding: Constants.pagePadding,
              child: BlocProvider<SignUpCubit>(
                create: (_) =>
                    SignUpCubit(context.read<AuthenticationRepository>()),
                child: const SignUpForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
