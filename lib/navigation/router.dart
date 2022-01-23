import 'package:baskit/item_screen.dart';
import 'package:baskit/models/app_state_manager.dart';
import 'package:baskit/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final goRouter = GoRouter(
  initialLocation: Routes.splash.path,
  refreshListenable: appStateManager,
  routes: [
    Routes.splash,
    Routes.item,
    Routes.parse,
  ],
  redirect: (state) {
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
      print('state.location: ${state.location}');
      print('state.subloc: ${state.subloc}');
      print('state.path: ${state.path}');
      if (state.subloc != Routes.item.path) {
        return Routes.item.path;
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
    return ItemScreen.page(key: state.pageKey);
  },
);
