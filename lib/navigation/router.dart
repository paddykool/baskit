import 'package:baskit/item_screen.dart';
import 'package:baskit/models/app_state_manager.dart';
import 'package:baskit/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyGoRouter {
  final AppStateManager appStateManager;
  MyGoRouter(this.appStateManager);

  late final goRouter = GoRouter(
    initialLocation: Routes.item.path,
    refreshListenable: appStateManager,
    routes: [
      Routes.item,
      Routes.parse,
    ],
    redirect: (state) {
      if (appStateManager.wasOpenedBySharingURL) {
        print('state.location: ${state.location}');
        print('state.subloc: ${state.subloc}');
        print('state.path: ${state.path}');
        if (state.subloc != Routes.parse.path) {
          return Routes.parse.path;
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
}
