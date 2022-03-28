import 'package:baskit/home_screen.dart';
import 'package:baskit/models/app_state_manager.dart';
import 'package:baskit/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final goRouter = GoRouter(
  initialLocation: Routes.splash.path,
  refreshListenable: appStateManager,
  routes: [
    Routes.splash,
    Routes.home,
    Routes.parse,
    Routes.error,
    Routes.selectbaskit,
  ],
  redirect: (state) {
    if (state.subloc == '/selectbaskit') {
      return null;
    }

    // opened by sharing logic
    if (appStateManager.openedBySharingURL) {
      print('state.location: ${state.location}');
      print('state.subloc: ${state.subloc}');
      print('state.path: ${state.path}');
      if (state.subloc != Routes.parse.path) {
        return Routes.parse.path;
      }
      return null;
    }

    if (state.subloc.contains('/baskit')) {
      return null;
    }

    // Show the splash screen for 4 seconds if opened normally
    if (!appStateManager.isInitialised) {
      print('state.location: ${state.location}');
      print('state.subloc: ${state.subloc}');
      print('state.path: ${state.path}');
      if (state.subloc != Routes.splash.path) {
        return Routes.splash.path;
      }
      return null;
    }

    if (appStateManager.isInitialised) {
      print('DEBUG - inside the appStateManager.isInitialise');
      print('state.location: ${state.location}');
      print('state.subloc: ${state.subloc}');
      print('state.path: ${state.path}');
      if (state.subloc == Routes.error.path) {
        print('Returning null as route is error path');
        return null;
      }

      // if (state.subloc.contains('/item/')) {
      //   return null;
      // }

      if (state.subloc != Routes.home.path) {
        return Routes.home.path;
      }
      return null;
    }

    return null;
  },
  errorPageBuilder: (BuildContext context, GoRouterState state) {
    // ignore: avoid_print
    print('Error state: ${state.error}');
    // Showing the splash page on an error is a poor practice - but we'll
    // leave what page to show here as an exercise for the reader.
    return HomeScreen.page(key: state.pageKey);
  },
);
