import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ParseScreen extends StatelessWidget {
  final String url;
  final Function setStackIndexCallback;

  ParseScreen({required this.url, required this.setStackIndexCallback});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baskit - Webview'),
      ),
      body: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: "https://www.central.co.th/en/",
          onPageFinished: (string) {
            print("I'm inside the onPageFinished..... and parameter is $string");
            setStackIndexCallback();
          }),
      // TODO is the above '_' corect to use ?
      // TODO what is the deal with function types ???
    );
  }
}
