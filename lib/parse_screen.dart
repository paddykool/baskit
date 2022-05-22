import 'package:baskit/models/baskit_db_manager.dart';
import 'package:baskit/parse_document.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:convert';
import 'dart:io';
import 'boxes.dart';
import 'models/baskit.dart';
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
  InAppWebViewController? _controller;
  var loadingPercentage = 0;
  late String passedURL = "";
  var h1Position;
  dynamic allVisibleImg;
  String jsGetHTML = "document.documentElement.outerHTML";
  String jsGetiFrames =
      "document.documentElement.getElementsByTagName('iframe')";
  String jsFirstVisibleH1 = """
      var collectionOfH1s = document.documentElement.getElementsByTagName("h1")
      var htmlArray = Array.from(collectionOfH1s);
      var firstElementIndex = htmlArray.findIndex(isNotHidden) 
      firstElementIndex
      
      function isNotHidden(el) {
          return (el.offsetParent != null)
      }
  """;
  String jsAllVisibleImg = """
    function isInViewport(element) {
      var position = element.getBoundingClientRect()
    
      // checking whether fully visible
      return position.top > 0 && position.bottom <= window.innerHeight+250 && position.left >= 0 && position.right <= window.innerWidth
    }
  
    var collectionOfIMGs = document.documentElement.getElementsByTagName("img")
    var collectionOfVisibleImages = []
    var listOfVisibleImagesObj = {}
    var counter = 0
    for (let item of collectionOfIMGs){
      //if(isInViewport(item)){
      if(true){
        var clientRect = item.getBoundingClientRect()
        var imageObj = {
          src: item.src,
          alt: item.alt,
          x: clientRect.x,
          y: clientRect.y,
          width: clientRect.width,
          height: clientRect.height,
          top: clientRect.top,
          bottom: clientRect.bottom,
          right: clientRect.right,
          left: clientRect.left,
        }

        var imageName = "img" + counter
        listOfVisibleImagesObj[imageName] = imageObj
        counter++
      }
    }

    listOfVisibleImagesObj

  """;
  String jsAllVisibleImg2 = """
    function areaInViewPort(element) {
    var pos = element.getBoundingClientRect()
    var windowHeight = window.innerHeight
    var windowWidth = window.innerWidth
    var ActuaulElementWidth
    var ActuaulElementHeight
    
    // GET THE ACTUAL VISIBLE HEIGHT
    // Should try to use switch statement here
    if(pos.height == 0 || pos.left-pos.right == 0){
       console.debug('HEIGHT height or width is 0')
        ActuaulElementHeight = 0 
    } else if(pos.top + pos.height <= 0){
        console.debug('HEIGHT top+height is less than zero')
        ActuaulElementHeight = 0
    } else if(pos.top + pos.height < pos.height ){
        console.debug('HEIGHT Image is partically visible from top')
        ActuaulElementHeight = pos.bottom
    } else if(pos.top + pos.height < windowHeight){
        console.debug('HEIGHT Image is Fully visible')
        ActuaulElementHeight = pos.height
    } else if(pos.top < windowHeight){
        console.debug('HEIGHT Image is partically visible from the bottom')
        ActuaulElementHeight = (windowHeight - pos.top)
    } else if(pos.top > windowHeight){
        console.debug('HEIGHT top is greater than window height')
        ActuaulElementHeight = 0
    } else {
        console.debug('HEIGHT -  SOMETHING. SLIPPED THROUGH. THIS SHOULD NOT BE HERE.')
        ActuaulElementHeight = 0
    }

    // GET THE ACTUAL VISIBLE WIDTH
    // Should try to use switch statement here
    if(pos.width == 0 || pos.left-pos.right == 0){
       console.debug('WIDTH height or width is 0')
        ActuaulElementWidth = 0 
    } else if(pos.right <= 0){
        console.debug('WIDTH right is less than zero')
        ActuaulElementWidth = 0 
    } else if(pos.left + pos.width < pos.width ){
        console.debug('WIDTH Image is partically visible from left')
        ActuaulElementWidth = pos.right
    } else if(pos.left + pos.width < windowWidth){
        console.debug('WIDTH Image is Fully visible')
        ActuaulElementWidth = pos.width
    } else if(pos.left < windowWidth){
        console.debug('WIDTH Image is partically visible from the right')
        ActuaulElementWidth = (windowWidth - pos.left) 
    } else if(pos.left > windowWidth){
        console.debug('WIDTH left is greater than window width')
        ActuaulElementWidth = 0 
    } else {
        console.debug('WIDTH -  SOMETHING. SLIPPED THROUGH. THIS SHOULD NOT BE HERE.')
        ActuaulElementWidth = 0
    }
    return ActuaulElementHeight * ActuaulElementWidth
}

var collectionOfIMGs = document.documentElement.getElementsByTagName("img")
var listOfImagesObj = {}
var counter = 0
for (let item of collectionOfIMGs){
  var imageArea = areaInViewPort(item)
  var imageObj = {
    imageElementPosition: counter,
    datasrc: item["data-src"],
    currentSrc: item.currentSrc,
    src: item.src,
    alt: item.alt,
    area: imageArea,
  }
  
  var imageName = "img" + counter
  listOfImagesObj[imageName] = imageObj
  counter++
}

listOfImagesObj
  """;

  int loadStopCount = 0;
  incrementOnLoadStopCount() {
    loadStopCount++;
  }

  // use this to get the text for a new Baskit
  // TODO this can be removed since dialog haas own class now
  // I think....
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String passedURL =
        Provider.of<AppStateManager>(context, listen: false).sharedURL;
    print('passed URL received in parse screen.. $passedURL');

    // TODO - argos - iOd and Android - does it need an if ??
    // Remove any ';' characters... ARGOS MADE ME DO THIS
    passedURL = passedURL.replaceAll(";", "");

    // Make sure it's using https - was this for argos ?
    Uri parsedURL = Uri.parse(passedURL);
    if (parsedURL.scheme == 'http') {
      print('parsedURL before $parsedURL');
      parsedURL = parsedURL.replace(scheme: 'https');
      print('parsedURL after $parsedURL');
    }

    print('BUILD BUILD BUILD BUILD BUILD BUILD I\'m in the build method');

    return Scaffold(
      appBar: AppBar(
        title: Text('The Parse Screen'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go(Routes.home.path);
        },
        child: Center(
          child: Text('Home Page'),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // TODO - Maybe take this out as separate class
          // TODO - Actually just create a model for the parse screen state
          // and add the url and progress indicator. Then use provider and change notifier ?
          InAppWebView(
            initialUrlRequest: URLRequest(url: parsedURL),
            onWebViewCreated: (controller) {
              _controller = controller;
            },
            onLoadStart: (controller, url) {
              print('STARTING ONLOADSTART ---------- $url');
              setState(() {
                loadingPercentage = 0;
              });
            },
            onProgressChanged: (controllerr, progress) async {
              print('DEBUG DEBUG - Progress = $progress');
              Uri? daURL = await controllerr.getUrl();
              print(daURL);
              setState(() {
                loadingPercentage = progress;
              });
            },
            onLoadStop: (controller, url) async {
              // int? progressInsideLoadStop = await controller.getProgress();
              // print('STARTING onLoadStop() - $url');
              // print('PROGRESS INSIDE ONLOADSTOP: $progressInsideLoadStop');
              // if (progressInsideLoadStop != 100) {
              //   print('going to wait for 3 seconds');
              //   // wait 0.5 seconds
              //   await Future.delayed(Duration(milliseconds: 3000));
              //   print('Finished waiting to wait for 3 seconds');
              // }
              // print('PROGRESS INSIDE ONLOADSTOP: $progressInsideLoadStop');
              // setState(() {
              //   loadingPercentage = 100;
              //   incrementOnLoadStopCount();
              //   print('INSIDE SETSTATE onLoadStopCount: $loadStopCount');
              // });
              //
              // print('OUTSIDE SETSTATE onLoadStopCount: $loadStopCount');

              // If an iframe finishes loading it can trigger onLoadStop
              // even though the parent webpage is still not ready
              // so check that the progress is 100
              print('STARTING onLoadStop() - $url');
              int? progressInsideLoadStop = await controller.getProgress();
              if (progressInsideLoadStop == 100) {
                // Wrapping the whole thing in a try / catch as loads can go wrong
                try {
                  // get all the html
                  print('RUNNING RUNNING RUNNING RUNNING - jsGetHTML');
                  String doc =
                      await _controller!.evaluateJavascript(source: jsGetHTML);

                  // parse the html to get the dom
                  var dom = parse(doc);

                  // find out the number of h1's in the dom
                  var numOfH1s = dom.getElementsByTagName('h1').length;

                  // // if there are no h1's then abort and goto error screen
                  // if (numOfH1s == 0) {
                  //   print('no h1s brought back... aborting');
                  //   // TODO - This does not work.. prob something with the redirect...
                  //   context.go(Routes.error.path);
                  // }

                  // if there are multiple h1s the find first visible on
                  if (numOfH1s > 1) {
                    print(
                        'multiple h1\'s brought back.. finding first visible h1..');
                    print('RUNNING RUNNING RUNNING RUNNING - jsFirstVisibleH1');
                    h1Position = await _controller!
                        .evaluateJavascript(source: jsFirstVisibleH1);
                    // make sure it's an Int
                    h1Position = h1Position.toInt();
                  }

                  // Get a list of all fully visible <img>
                  print('RUNNING RUNNING RUNNING RUNNING - jsAllVisibleImg2');
                  print(DateTime.now());
                  allVisibleImg = await _controller!
                      .evaluateJavascript(source: jsAllVisibleImg2);
                  print(
                      'FINISHED FINISHED FINISHED FINISHED - jsAllVisibleImg2');
                  print(DateTime.now());
                  print('allVisibleImg: $allVisibleImg');

                  // get teh type
                  Type type = allVisibleImg.runtimeType;
                  print(type);

                  // TODO - this was added for iOS as js eval brought
                  // back map<Object?, Object>
                  // convert the list of visible images to a map
                  Map<String, dynamic> allVisibleImgMap =
                      allVisibleImg.cast<String, dynamic>();
                  print('allVisibleImgMap" $allVisibleImgMap');

                  // Get the domain name
                  String host = Uri.parse(passedURL).host;
                  print('host from URL: $host');

                  // Get all the item details
                  var jsonData = getItemDetails(
                      document: dom,
                      host: host,
                      numH1s: numOfH1s,
                      h1Position: h1Position,
                      allVisibleImages: allVisibleImgMap);

                  // TODO - Now... what to do...
                  // create the new Item
                  Item newItem = Item(
                    title: jsonData['title'],
                    imageURL: jsonData['imageURL'],
                    price: jsonData['price'],
                    host: host,
                    url: parsedURL.toString(),
                  );

                  // Store the new Item in the Data Manager until a baskit is selected
                  Provider.of<BaskitDBManager>(context, listen: false)
                      .storeItemToDataManager(newItem);

                  // GOTO a new select baskit page
                  context.go('/selectbaskit');
                } catch (e) {
                  print('DEBUG - this exception happened:');
                  print(e);
                  // Reset the shared launch properties in app state manager
                  Provider.of<AppStateManager>(context, listen: false)
                      .resetShareLaunchProperties();

                  // Go to the error screen
                  context.go(Routes.error.path);
                }
              } else {
                print(
                    'something shit happened that progress didn\'t get to 100');
              }
            },
          ),
          DetailsLoadingWidget(loadingPercent: loadingPercentage)
        ],
      ),
    );
  }

  // Future<String> baskitSelectDialog() async {
  //   await showDialog<String>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return SimpleDialog(
  //         title: Text('Select Baskit'),
  //         children: selectBaskitList(),
  //       );
  //     },
  //   );
  //
  //   return Future.delayed(Duration(milliseconds: 3000), () => 'Balls');
  // }
  //
  // List<Widget> selectBaskitList() {
  //   // Get all the current baskit titles:
  //   var box = Boxes.getBaskits();
  //   List listOfBaskitKeys = box.keys.toList();
  //
  //   List listOfBaskitNames =
  //       listOfBaskitKeys.map((key) => box.get(key)?.title).toList();
  //
  //   // Create a SimpleDialogOption for each baskit name
  //   List<Widget> listOfOptionWidgets = listOfBaskitNames
  //       .map(
  //         (baskitName) => SimpleDialogOption(
  //           child: Text(baskitName),
  //           // TODO - Return the baskit name
  //           // or create the actual item ???
  //           // Will this return the baskit name ???
  //           onPressed: () => Navigator.pop(context, baskitName),
  //         ),
  //       )
  //       .toList();
  //
  //   // Add Option to create a baskit
  //   listOfOptionWidgets.insert(
  //       0,
  //       SimpleDialogOption(
  //         child: Text("Create a new Baskit"),
  //         // Navigate to create new Baskit screen ?
  //         onPressed: () => createBaskitDialog(),
  //       ));
  //
  //   return listOfOptionWidgets;
  // }

  // Future<String> createBaskitDialog() async {
  //   await showDialog<String>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Enter New Baskit Name'),
  //         // Text field with a submit button
  //         content: TextField(
  //           autofocus: true,
  //           decoration: InputDecoration(hintText: 'Enter name of new Baskit'),
  //           controller: controller,
  //           // TODO - create a new baskit and return it's name
  //           // This is if the user hits return on the keyboard
  //           onSubmitted: (_) => null,
  //         ),
  //         actions: [
  //           TextButton(
  //             child: Text('Submit'),
  //             // TODO - create a new baskit and return it's name
  //             onPressed: () {
  //               // createNewBaskit(controller.text);
  //               // return controller.text;
  //             },
  //           )
  //         ],
  //       );
  //     },
  //   );
  //
  //   return Future.delayed(Duration(milliseconds: 3000), () => 'Balls');
  // }

  // void createNewBaskit(String newBaskitName) {
  //   // Create a new Baskit
  //   Baskit newBaskit = Baskit(title: newBaskitName);
  //
  //   // Create the new baskit in the Hive box
  //   var box = Boxes.getBaskits();
  //   box.add(newBaskit);
  //
  //   // Now... return the name of this new baskit....
  // }
}

class DetailsLoadingWidget extends StatelessWidget {
  var loadingPercent = 0;

  DetailsLoadingWidget({Key? key, required this.loadingPercent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1.0,
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
