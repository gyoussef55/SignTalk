import 'dart:convert';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'package:textsign/sign/text_to_sign_result.dart';

class SpeechToSignLanguage extends StatefulWidget {
  const SpeechToSignLanguage({super.key});
  @override
  State<SpeechToSignLanguage> createState() => _SpeechToSignLanguageState();
}

class _SpeechToSignLanguageState extends State<SpeechToSignLanguage> {
  stt.SpeechToText speech = stt.SpeechToText();
  bool isListening = false;
  String _text = 'Press the button and start speaking';

  Future<void> translateTextToSign() async {
    var request =
        http.MultipartRequest('POST', Uri.parse('http://127.0.0.1:5000/'));
    request.fields.addAll({'text': _text});
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
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    try {
      var hasSpeech = await speech.initialize();

      if (!mounted) return;

      setState(() {
        isListening = hasSpeech;
      });
    } catch (e) {
      setState(() {
        isListening = false;
      });
    }
  }

  void _startListening() async {
    await speech.listen(
      onResult: _onSpeechResult,
      localeId: "en_US",
    );
    setState(() {});
  }

  void _stopListening() async {
    await speech.stop();

    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _text = result.recognizedWords;
    });
    if (speech.isNotListening) {
      translateTextToSign();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech to Sign Language'),
        automaticallyImplyLeading: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: speech.isListening,
        glowColor: Theme.of(context).primaryColor,
        duration: const Duration(milliseconds: 2000),
        repeat: true,
        child: FloatingActionButton(
          onPressed: speech.isNotListening ? _startListening : _stopListening,
          child: Icon(speech.isNotListening ? Icons.mic : Icons.mic_off),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
          child: Text(
            _text,
            style: const TextStyle(fontSize: 32.0)
                .copyWith(color: Colors.black, fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }
}
