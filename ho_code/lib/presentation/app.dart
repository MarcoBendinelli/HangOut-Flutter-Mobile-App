import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/business_logic/blocs/theme/theme_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/business_logic/cubits/user/modify_user_cubit.dart';
import 'package:hang_out_app/data/repositories/chat_repository.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:hang_out_app/data/repositories/notifications_repository.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:hang_out_app/data/services/notification_service.dart';
import 'package:hang_out_app/business_logic/blocs/app/app_bloc.dart';
import 'package:hang_out_app/business_logic/routes/routes.dart';
import 'package:hang_out_app/data/repositories/authentication_repository.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/my_dark_theme.dart';
import 'package:hang_out_app/presentation/utils/my_theme.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';

class App extends StatelessWidget {
  const App(
      {super.key, required AuthenticationRepository authenticationRepository})
      : _authenticationRepository = authenticationRepository;

  final AuthenticationRepository _authenticationRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _authenticationRepository,
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<MyEventsRepository>(
              create: (context) => MyEventsRepository()),
          RepositoryProvider<MyGroupsRepository>(
              create: (context) => MyGroupsRepository()),
          RepositoryProvider<ChatRepository>(
              create: (context) => ChatRepository()),
          RepositoryProvider<NotificationsRepository>(
              create: (context) => NotificationsRepository()),
          RepositoryProvider<UserRepository>(
              create: (context) => UserRepository()),
        ],
        child: Builder(builder: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => AppBloc(
                  authenticationRepository: _authenticationRepository,
                ),
              ),
              BlocProvider(
                create: (_) => UserBloc(
                    userRepository: context.read<UserRepository>(),
                    notificationService: NotificationService()),
              ),
              BlocProvider<ModifyUserCubit>(
                  create: (context) => ModifyUserCubit(
                      userRepository: context.read<UserRepository>())),
              BlocProvider(
                create: (_) => ThemeBloc(
                    initialValue: SchedulerBinding
                            .instance.platformDispatcher.platformBrightness ==
                        Brightness.dark),
              ),
            ],
            child: const AppView(),
          );
        }),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    cacheBackgrounds(context);
    return BlocBuilder<ThemeBloc, bool>(builder: (context, state) {
      return MaterialApp(
          theme: state ? myDarkTheme : myTheme,
          title: 'HangOutApp',
          debugShowCheckedModeBanner: false,
          home: Builder(
            builder: (context) {
              PopupTabletConstants.setSmallestDimension(context);
              TabletConstants.setDimensions(context);
              ScreenUtil.init(
                context,
                designSize: getSize(context) == ScreenSize.normal
                    ? const Size(360, 800)
                    : tabletLandscapeSize,
              );
              return FlowBuilder<AppStatus>(
                state: context.select((AppBloc bloc) => bloc.state.status),
                onGeneratePages: getSize(context) == ScreenSize.normal
                    ? onGenerateAppViewPages
                    : onGenerateTabletAppViewPages,
              );
            },
          ));
    });
  }

  void cacheBackgrounds(BuildContext context) {
    precacheImage(const AssetImage("assets/logo_written.png"), context);
    precacheImage(const AssetImage("assets/logo_written_white.png"), context);
    precacheImage(const AssetImage(Constants.phoneBgChat), context);
    precacheImage(const AssetImage(Constants.iPhoneBgChat), context);
    precacheImage(const AssetImage(Constants.phoneBgSignUp), context);
    precacheImage(const AssetImage(Constants.phoneBgLogin), context);
    precacheImage(const AssetImage(Constants.phoneBgMain), context);
    precacheImage(const AssetImage(Constants.phoneDarkBgChat), context);
    precacheImage(const AssetImage(Constants.iPhoneDarkBgChat), context);
    precacheImage(const AssetImage(Constants.phoneDarkBgSignUp), context);
    precacheImage(const AssetImage(Constants.phoneDarkBgLogin), context);
    precacheImage(const AssetImage(Constants.phoneDarkBgMain), context);
    precacheImage(const AssetImage(TabletConstants.tabletBgChat), context);
    precacheImage(const AssetImage(TabletConstants.tabletBgSignup), context);
    precacheImage(const AssetImage(TabletConstants.tabletBgLogin), context);
    precacheImage(const AssetImage(TabletConstants.tabletBgMain), context);
    precacheImage(const AssetImage(TabletConstants.tabletDarkBgChat), context);
    precacheImage(
        const AssetImage(TabletConstants.tabletDarkBgSignup), context);
    precacheImage(const AssetImage(TabletConstants.tabletDarkBgLogin), context);
    precacheImage(const AssetImage(TabletConstants.tabletDarkBgMain), context);
  }
}
