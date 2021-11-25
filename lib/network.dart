import 'package:http/http.dart' as http;
import 'package:html/parser.dart'; // Contains HTML parsers to generate a Document object
import 'package:html/dom.dart'; // Contains DOM related classes for extracting data from elements
import 'dart:convert';

class NetworkCalls {
  String url;

  NetworkCalls({required this.url});

  Future<Document> getResponseBody() async {
    // TODO: this needs error handling - try catch around the await ?
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var document = parse(response.body);
      return document;
    } else {
      // TODO: Error handling - throw an exception?
      print('Status code was: $response.statusCode');
      throw ('Is this how I throw an error??');
    }
  }

  Future<Map<String, dynamic>> getJsonResponseBody() async {
    // TODO: this needs error handling - try catch around the await ?
    // TODO: will defo need some auth and encryption
    // TODO: how do I change this when running server locally and then in PROD ??
    // TODO: add proper endpoint to api - dont be using root
    // String serverURL = 'https://10.0.2.2:5000/getItems?url=$url';
    String serverURL = 'https://baskit.dev/getItemDetails?url=$url';
    // String serverURL = 'http://10.0.2.2/getItemDetails?url=$url';

    // Basic auth
    // TODO: Put these in env variables...
    String username = 'appuser';
    String password = 'daehtihs';
    String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
    print(basicAuth);

    var response = await http.get(Uri.parse(serverURL), headers: <String, String>{
      'authorization': basicAuth
    }).timeout(const Duration(seconds: 120));

    // await http.get(Uri.parse(serverURL));
    if (response.statusCode == 200) {
      // TODO: is this the best way to serialize JSON ?
      Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      // TODO: Error handling - throw an exception?
      print('Status code was: ${response.statusCode}');
      print('Status code was: ${response.body}');
      throw ('Is this how I throw an error??');
    }
  }

  Future<Map<String, dynamic>> getJsonResponseBodySTUB() async {
    await Future.delayed(Duration(milliseconds: 8000), () {
      print('Waiting inside Future.delayed...');
    });

    Map<String, dynamic> data = {
      'title': 'balls',
      'imageURL':
          'https://backend.central.co.th/media/catalog/product/c/3/c3e3162405496e5b28386276fd487a6a3eb67726_mkp0616135dummy.jpg',
      'price': '£3.99'
    };

    return data;
  }
}
