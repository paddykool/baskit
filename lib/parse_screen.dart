import 'package:baskit/parse_document.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'dart:io';
import 'boxes.dart';
import 'models/item.dart';
import 'package:provider/provider.dart';
import 'package:baskit/models/app_state_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:baskit/navigation/routes.dart';

class ParseScreen extends StatefulWidget {
  const ParseScreen({Key? key}) : super(key: key);

  static Page page({LocalKey? key}) => MaterialPage(
        key: key,
        child: ParseScreen(),
      );

  @override
  State<ParseScreen> createState() => _ParseScreenState();
}

class _ParseScreenState extends State<ParseScreen> {
  WebViewController? _controller;
  var loadingPercentage = 0;

  @override
  Widget build(BuildContext context) {
    String passedURL =
        Provider.of<AppStateManager>(context, listen: false).sharedURL;
    print('pasased URL recieved in parse screen.. ${passedURL}');

    return Scaffold(
      appBar: AppBar(
        title: Text('The Parse Screen'),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.go(Routes.item.path);
          },
          child: Text('Items List')),
      body: Stack(
        alignment: Alignment.center,
        children: [
          WebView(
            javascriptMode: JavascriptMode.unrestricted,
            initialUrl: passedURL,
            onWebViewCreated: (controller) {
              _controller = controller;
            },
            onPageStarted: (url) {
              setState(() {
                loadingPercentage = 0;
              });
            },
            onProgress: (progress) {
              print('DEBUG DEBUG - Progress = $progress');
              setState(() {
                loadingPercentage = progress;
              });
            },
            onPageFinished: (string) async {
              setState(() {
                loadingPercentage = 100;
              });

              // await Future.delayed(Duration(seconds: 5));
              String docuDecode;
              print('DEBUG 222 using the _controller here.... $_controller');
              String docu = await _controller!.runJavascriptReturningResult(
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
