import 'dart:async';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class AppStateManager extends ChangeNotifier {
  bool _isInitialised = false;
  bool _openedBySharingURL = false;
  bool _resumedBySharingURL = false;
  String _sharedURL = "";

  bool get isInitialised => _isInitialised;
  bool get openedBySharingURL => _openedBySharingURL;
  bool get resumedBySharingURL => _resumedBySharingURL;
  String get sharedURL => _sharedURL;

  StreamSubscription? _intentDataStreamSubscription;

  Future<void> initialiseWasOpenedByShareLaunch() async {
    // check if there is any initial text when app is opened
    // TODO maybe await this and assign to a string - make async - then check the string?
    String? url = await ReceiveSharingIntent.getInitialText();
    // ReceiveSharingIntent.getInitialText().then((String? url) {
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
  }

  // TODO just add this to above function and call once in main ?
  void initialiseResumedBySharingURL() {
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

  void initialiseApp() {
    Timer(
      const Duration(milliseconds: 3000),
      () {
        _isInitialised = true;
        notifyListeners();
      },
    );
  }

  void resetShareLaunchProperties() {
    _sharedURL = "";
    _openedBySharingURL = false;
    _resumedBySharingURL = false;
  }

  void closeShareURLStream() {
    _intentDataStreamSubscription!.cancel();
  }
}

final AppStateManager appStateManager = AppStateManager();
