
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:textsign/sign/text_to_sign_result.dart';


class TextToSignLanguage extends StatefulWidget {
  const TextToSignLanguage({super.key});
  @override
  State<TextToSignLanguage> createState() => _TextToSignLanguageState();
}

class _TextToSignLanguageState extends State<TextToSignLanguage> {
  String url = '';
  String output = 'Initial Output';
  String input='';

  Future<void> translateTextToSign() async {
    var request =
        http.MultipartRequest('POST', Uri.parse('http://127.0.0.1:5000/'));
    request.fields.addAll({'text': input});
    var response = await request.send();

    if (response.statusCode == 200) {
      final data = jsonDecode(await response.stream.bytesToString());

      if (mounted) {
        final imagePaths = List<String>.from(data['image_paths']);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => TextToSignResult(imagePaths: imagePaths)));
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text to Sign Language'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              onChanged: (value) {
                input = value;
              },
              decoration: const InputDecoration(
                hintText: 'Enter text to translate',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                translateTextToSign();
              },
              child: const Text('Translate'),
            ),
            Text(output),
          ],
        ),
      ),
    );
  }
}
