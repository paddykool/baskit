import 'package:baskit/models/app_state_manager.dart';
import 'package:flutter/material.dart';
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
  // TODO try async await here
  await appStateManager.initialiseWasOpenedByShareLaunch();

  // setup the stream to listen to onResume
  appStateManager.initialiseResumedBySharingURL();

  // wait 4 seconds before setting isinitialised to true
  appStateManager.initialiseApp();

  runApp(Baskit());
}

class Baskit extends StatefulWidget {
  @override
  State<Baskit> createState() => _BaskitState();
}

class _BaskitState extends State<Baskit> {
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
    Hive.box('items').close();
    appStateManager.closeShareURLStream();
    super.dispose();
  }
}
