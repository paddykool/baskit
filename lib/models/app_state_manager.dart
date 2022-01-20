import 'dart:async';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class AppStateManager extends ChangeNotifier {
  bool _openedBySharingURL = false;
  bool get wasOpenedBySharingURL => _openedBySharingURL;

  String _sharedURL = "";
  String get sharedURL => _sharedURL;

  StreamSubscription? _intentDataStreamSubscription;

  void initialiseShareLaunchProperties() {
    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String? url) {
      print('inside "ReceiveSharingIntent.getInitialText()"...');
      if (url != null) {
        print(
            'Value passed in from getInitialText() was $url... Setting passedUrl variable');
        _sharedURL = url;
        _openedBySharingURL = true;
        notifyListeners();
      } else {
        print('Value passed in from getInitialText() was null');
      }
    });

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String url) {
      print('inside "ReceiveSharingIntent.getTextStream()"...');
      print(
          'Value passed in from getTextStream() was $url... Setting passedUrl variable');
      _sharedURL = url;
      _openedBySharingURL = true;
      notifyListeners();
    }, onError: (err) {
      print("getLinkStream error: $err");
    });
  }

  void resetShareLaunchProperties() {
    _sharedURL = "";
    _openedBySharingURL = false;
  }

  void closeShareURLStream() {
    _intentDataStreamSubscription!.cancel();
  }
}

final AppStateManager appStateManager = AppStateManager();
