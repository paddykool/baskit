import 'package:baskit/models/app_state_manager.dart';
import 'package:baskit/models/baskit.dart';
import 'package:flutter/material.dart';
import 'package:baskit/models/item.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'navigation/router.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(BaskitAdapter());
  Hive.registerAdapter(ItemAdapter());
  await Hive.openBox<Baskit>('baskits');

  // initialise the shareURL properties
  // TODO try async await here
  await appStateManager.initialiseWasOpenedByShareLaunch();

  // setup the stream to listen to onResume
  appStateManager.initialiseResumedBySharingURL();

  // wait 4 seconds before setting isInitialised to true
  appStateManager.initialiseApp();

  runApp(BaskitApp());
}

class BaskitApp extends StatefulWidget {
  @override
  State<BaskitApp> createState() => _BaskitAppState();
}

class _BaskitAppState extends State<BaskitApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppStateManager>(
      lazy: false,
      create: (BuildContext context) => appStateManager,
      child: MaterialApp.router(
        title: 'Baskit',
        debugShowCheckedModeBanner: false,
        routerDelegate: goRouter.routerDelegate,
        routeInformationParser: goRouter.routeInformationParser,
      ),
    );
  }

  @override
  void dispose() {
    Hive.box('baskits').close();
    appStateManager.closeShareURLStream();
    super.dispose();
  }
}
