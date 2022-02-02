import 'package:baskit/parse_document.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:convert';
import 'dart:io';
import 'boxes.dart';
import 'models/item.dart';
import 'package:provider/provider.dart';
import 'package:baskit/models/app_state_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:baskit/navigation/routes.dart';

class ParseScreen2 extends StatefulWidget {
  const ParseScreen2({Key? key}) : super(key: key);

  static Page page({LocalKey? key}) => MaterialPage(
        key: key,
        child: ParseScreen2(),
      );

  @override
  State<ParseScreen2> createState() => _ParseScreen2State();
}

class _ParseScreen2State extends State<ParseScreen2> {
  InAppWebViewController? _controller;
  var loadingPercentage = 0;
  String jsGetHTML = "document.documentElement.outerHTML";
  String jsFindH1 = """
      var collectionOfH1s = document.documentElement.getElementsByTagName("h1")
      var htmlArray = Array.from(collectionOfH1s);
      var firstElementIndex = htmlArray.findIndex(isNotHidden) 
      firstElementIndex
      
      function isNotHidden(el) {
          return (el.offsetParent != null)
      }
  """;

  @override
  Widget build(BuildContext context) {
    String passedURL =
        Provider.of<AppStateManager>(context, listen: false).sharedURL;
    print('pasased URL recieved in parse screen.. $passedURL');

    return Scaffold(
      appBar: AppBar(
        title: Text('The Parse Screen'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go(Routes.item.path);
        },
        child: Center(
          child: Text('Items List'),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: Uri.parse('$passedURL')),
            onWebViewCreated: (controller) {
              _controller = controller;
            },
            onLoadStart: (controller, url) {
              setState(() {
                loadingPercentage = 0;
              });
            },
            onProgressChanged: (_, progress) {
              print('DEBUG DEBUG - Progress = $progress');
              setState(() {
                loadingPercentage = progress;
              });
            },
            onLoadStop: (controller, url) async {
              setState(() {
                loadingPercentage = 100;
              });

              // Wrapping the whole thing in a try / catch as loads can go wrong
              try {
                // get all the html
                String doc =
                    await _controller!.evaluateJavascript(source: jsGetHTML);

                // Get the position of thee first visible h1
                // (if there are multiple h1's in the doc)
                int h1Position =
                    await _controller!.evaluateJavascript(source: jsFindH1);

                // parse the html to get the dom
                var dom = parse(doc);

                // Get the domain name
                String host = Uri.parse(passedURL).host;
                print('host from URL: $host');

                // Get all the item details
                var jsonData = getItemDetails(
                    document: dom, host: host, h1Position: h1Position);

                // Create the item
                Item item = Item(
                    title: jsonData['title'],
                    imageURL: jsonData['imageURL'],
                    price: jsonData['price']);

                // Add the item to the box
                final box = Boxes.getItems();
                box.add(item);

                // Reset the shared launch properties in app state manager
                Provider.of<AppStateManager>(context, listen: false)
                    .resetShareLaunchProperties();

                // Navigate back to item screen
                context.go('/');
              } catch (e) {
                print('DEBUG - this exception happened:');
                print(e);
                // Reset the shared launch properties in app state manager
                Provider.of<AppStateManager>(context, listen: false)
                    .resetShareLaunchProperties();

                // Go to the error screen
                context.go(Routes.error.path);
              }
            },
          ),
          DetailsLoadingWidget(loadingPercent: loadingPercentage)
        ],
      ),
    );
  }
}

class DetailsLoadingWidget extends StatelessWidget {
  var loadingPercent = 0;

  DetailsLoadingWidget({Key? key, required this.loadingPercent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.8,
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 6,
                child: Image(
                  height: 200.0,
                  image: AssetImage('assets/basket.png'),
                ),
              ),
              SizedBox(height: 50.0),
              Expanded(
                flex: 1,
                child: LinearProgressIndicator(
                  minHeight: 20.0,
                  value: loadingPercent / 100.0,
                  // value: 0.7,
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    'Getting item Details please wait...',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
