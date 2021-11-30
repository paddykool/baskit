import 'package:baskit/parse_document.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'dart:io';
import 'boxes.dart';
import 'models/item.dart';

class ParseScreen extends StatelessWidget {
  final String url;
  final Function setOpenedBySharingCallback;

  ParseScreen({required this.url, required this.setOpenedBySharingCallback});

  @override
  Widget build(BuildContext context) {
    late WebViewController _controller;

    return WebView(
      javascriptMode: JavascriptMode.unrestricted,
      initialUrl: url,
      onWebViewCreated: (controller) {
        _controller = controller;
      },
      onPageFinished: (string) async {
        String docuDecode;
        String docu =
            await _controller.runJavascriptReturningResult("document.documentElement.outerHTML");
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

        // Call back to set the property to go back to item list
        setOpenedBySharingCallback(value: false);

        var jsonData = getItemDetails(document: dom);
        Item item = Item(
            title: jsonData['title'], imageURL: jsonData['imageURL'], price: jsonData['price']);

        final box = Boxes.getItems();
        box.add(item);
      },
    );
  }
}
