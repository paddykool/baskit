import 'package:baskit/boxes.dart';
import 'package:baskit/models/app_state_manager.dart';
import 'package:baskit/parse_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'item_screen.dart';
import 'models/item.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'navigation/router.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ItemAdapter());
  await Hive.openBox<Item>('items');

  // initialise the shareURL properties
  appStateManager.initialiseShareLaunchProperties();

  runApp(Baskit());
}

class Baskit extends StatefulWidget {
  @override
  State<Baskit> createState() => _BaskitState();
}

class _BaskitState extends State<Baskit> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppStateManager>(
            lazy: false, create: (BuildContext context) => appStateManager),
        Provider<MyGoRouter>(
          lazy: false,
          create: (BuildContext createContext) => MyGoRouter(appStateManager),
        )
      ],
      child: Builder(
        builder: (BuildContext context) {
          final router =
              Provider.of<MyGoRouter>(context, listen: false).goRouter;
          return MaterialApp.router(
            title: 'Baskit',
            debugShowCheckedModeBanner: false,
            routerDelegate: router.routerDelegate,
            routeInformationParser: router.routeInformationParser,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    Hive.box('items').close();
    super.dispose();
  }
}
