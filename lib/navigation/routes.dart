import 'package:baskit/error_screen.dart';
import 'package:baskit/parse_screen.dart';
import 'package:baskit/item_screen.dart';
import 'package:baskit/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Routes {
  static final item = GoRoute(
    path: '/',
    pageBuilder: (BuildContext context, GoRouterState state) =>
        ItemScreen.page(key: state.pageKey),
  );

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
}
