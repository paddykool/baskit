import 'package:baskit/boxes.dart';
import 'package:baskit/error_screen.dart';
import 'package:baskit/models/baskit.dart';
import 'package:baskit/parse_screen.dart';
import 'package:baskit/baskit_screen.dart';
import 'package:baskit/select_baskit.dart';
import 'package:baskit/splash_screen.dart';
import 'package:baskit/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Routes {
  static final home = GoRoute(
    name: 'home',
    path: '/',
    pageBuilder: (BuildContext context, GoRouterState state) =>
        HomeScreen.page(key: state.pageKey),
    routes: [
      GoRoute(
          name: 'baskit',
          path: 'baskit/:baskitKey',
          pageBuilder: (BuildContext context, GoRouterState state) {
            var baskitKeyPassedInState = state.params['baskitKey'];
            print(
                'this is the baskit key in the state: $baskitKeyPassedInState');
            return BaskitScreen.page(baskitKey: baskitKeyPassedInState!);
          })
    ],
  );

  // static final baskit = GoRoute(
  //   name: 'baskit',
  //   path: 'baskit/:baskitKey',
  //   pageBuilder: (BuildContext context, GoRouterState state) {
  //     final baskitKey = state.params['baskitKey']!;
  //     return BaskitScreen.page(key: state.pageKey, baskitKey: baskitKey);
  //   },
  // );

  static final parse = GoRoute(
    path: '/parse',
    pageBuilder: (BuildContext context, GoRouterState state) =>
        ParseScreen.page(key: state.pageKey),
  );

  static final splash = GoRoute(
    path: '/splash',
    pageBuilder: (BuildContext context, GoRouterState state) =>
        SplashScreen.page(key: state.pageKey),
  );

  static final error = GoRoute(
    path: '/error',
    pageBuilder: (BuildContext context, GoRouterState state) =>
        ErrorScreen.page(key: state.pageKey),
  );

  static final selectbaskit = GoRoute(
    path: '/selectbaskit',
    pageBuilder: (BuildContext context, GoRouterState state) {
      final title = state.queryParams['title'] ?? "???";
      final imageURL = state.queryParams['imageURL'] ?? "???";
      final price = state.queryParams['price'] ?? "???";
      return SelectBaskit.page(
        key: state.pageKey,
        title: title,
        imageURL: imageURL,
        price: price,
      );
    },
  );
}
