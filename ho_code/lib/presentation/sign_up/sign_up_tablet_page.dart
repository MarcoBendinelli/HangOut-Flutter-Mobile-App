import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hang_out_app/business_logic/cubits/sign_up/sign_up_cubit.dart';
import 'package:hang_out_app/data/repositories/authentication_repository.dart';
import 'package:hang_out_app/presentation/sign_up/sign_up_tablet_form.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';

class SignUpTabletPage extends StatelessWidget {
  const SignUpTabletPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const SignUpTabletPage());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Theme.of(context).brightness == Brightness.light
                ? const AssetImage(TabletConstants.tabletBgSignup)
                : const AssetImage(TabletConstants.tabletDarkBgSignup),
            fit: BoxFit.cover,
            // opacity: 1,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Padding(
              padding: TabletConstants.pagePadding(),
              child: BlocProvider<SignUpCubit>(
                create: (_) =>
                    SignUpCubit(context.read<AuthenticationRepository>()),
                child: const SignUpTabletForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
