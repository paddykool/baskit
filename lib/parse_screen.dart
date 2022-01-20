import 'package:baskit/item_screen.dart';
import 'package:baskit/parse_document.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'dart:io';
import 'boxes.dart';
import 'models/item.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:baskit/models/app_state_manager.dart';
import 'package:go_router/go_router.dart';

class ParseScreen extends StatelessWidget {
  const ParseScreen({Key? key}) : super(key: key);

  static Page page({LocalKey? key}) => MaterialPage(
        key: key,
        child: ParseScreen(),
      );

  // @override
  // void initState() {
  // super.initState();
  //
  // // For sharing or opening urls/text coming from outside the app while the app is in the memory
  // _intentDataStreamSubscription =
  //     ReceiveSharingIntent.getTextStream().listen((String url) {
  //   // setOpenedBySharing(value: true);
  //   print('inside "ReceiveSharingIntent.getTextStream()"...');
  //   print(
  //       'Value passed in from getTextStream() was $url... Setting passedUrl variable');
  //   passedUrl = url;
  //   // getItemDetails(url);
  // }, onError: (err) {
  //   print("getLinkStream error: $err");
  // });

  // // For sharing or opening urls/text coming from outside the app while the app is closed
  // ReceiveSharingIntent.getInitialText().then((String? url) {
  //   print('inside "ReceiveSharingIntent.getInitialText()"...');
  //   if (url != null) {
  //     print(
  //         'Value passed in from getInitialText() was $url... Setting passedUrl variable');
  //     // setOpenedBySharing(value: true);
  //     passedUrl = url;
  //     // getItemDetails(url);
  //   } else {
  //     print('Value passed in from getInitialText() was null');
  //   }
  // });
  // }

  // @override
  // void dispose() {
  //   _intentDataStreamSubscription!.cancel();
  // }

  @override
  Widget build(BuildContext context) {
    late WebViewController _controller;
    String passedURL =
        Provider.of<AppStateManager>(context, listen: false).sharedURL;
    print('pasased URL recieved in parse screen.. ${passedURL}');

    return Scaffold(
      appBar: AppBar(
        title: Text('The Parse Screen'),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => ItemScreen()));
          },
          child: Text('Items List')),
      body: WebView(
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: passedURL,
        onWebViewCreated: (controller) {
          _controller = controller;
        },
        onPageFinished: (string) async {
          // await Future.delayed(Duration(seconds: 5));
          String docuDecode;
          String docu = await _controller.runJavascriptReturningResult(
              "document.documentElement.outerHTML");
          // For Safari - actual HTML comes backand not Json so encoding first...
          if (Platform.isIOS) {
            docuDecode = jsonDecode(jsonEncode(docu));
          } else {
            docuDecode = jsonDecode(docu);
          }

          print('Just decoded the Json ....');
          var dom = parse(docuDecode);
          var title = dom.getElementsByTagName('title')[0].innerHtml;
          print('Page title: $title');

          // // Call back to set the property to go back to item list
          // widget.setOpenedBySharingCallback(value: false);

          // Get the domain name
          String origin = Uri.parse(passedURL).origin;
          print('origin from URL: $origin');
          var jsonData = getItemDetails(document: dom, origin: origin);
          Item item = Item(
              title: jsonData['title'],
              imageURL: jsonData['imageURL'],
              price: jsonData['price']);

          final box = Boxes.getItems();
          box.add(item);

          // Reset the shared launch properties in app state manager
          Provider.of<AppStateManager>(context, listen: false)
              .resetShareLaunchProperties();

          // Navigate back to item screen
          // TODO change to go_router
          context.go('/');
          // Navigator.push(
          //     context, MaterialPageRoute(builder: (context) => ItemScreen()));
        },
      ),
    );
  }
}
