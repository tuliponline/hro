import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Null>notifySend(String server,String token, String title,
    String body) async {
  print("notiserver = " + server);
  http.post(
    Uri.parse(server),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
        <String, String>{'token': token, 'title': title, 'body': body}),
  );
}