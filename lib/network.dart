import 'package:http/http.dart' as http;
import 'package:html/parser.dart'; // Contains HTML parsers to generate a Document object
import 'package:html/dom.dart'; // Contains DOM related classes for extracting data from elements

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
}
