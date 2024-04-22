import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hang_out_app/presentation/login/login_tablet_form.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/business_logic/cubits/login/login_cubit.dart';
import 'package:hang_out_app/data/repositories/authentication_repository.dart';

class LoginTabletPage extends StatelessWidget {
  const LoginTabletPage({super.key});

  static Page<void> page() =>
      const MaterialPage<void>(child: LoginTabletPage());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Theme.of(context).brightness == Brightness.light
                ? const AssetImage(TabletConstants.tabletBgLogin)
                : const AssetImage(TabletConstants.tabletDarkBgLogin),
            fit: BoxFit.cover,
            // opacity: 1,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Padding(
              padding: TabletConstants.pagePadding(),
              child: BlocProvider(
                create: (_) =>
                    LoginCubit(context.read<AuthenticationRepository>()),
                child: const LoginTabletForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
