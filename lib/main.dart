import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final stt.SpeechToText? speechToText;
  final FlutterTts? flutterTts;

  const MyApp({super.key, this.speechToText, this.flutterTts});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Assistant',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: VoiceAssistantPage(
        speechToText: speechToText,
        flutterTts: flutterTts,
      ),
    );
  }
}

class VoiceAssistantPage extends StatefulWidget {
  final stt.SpeechToText? speechToText;
  final FlutterTts? flutterTts;

  const VoiceAssistantPage({super.key, this.speechToText, this.flutterTts});

  @override
  State<VoiceAssistantPage> createState() => _VoiceAssistantPageState();
}

class _VoiceAssistantPageState extends State<VoiceAssistantPage> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _text = 'Press the button and start speaking...';
  String _response = '';

  @override
  void initState() {
    super.initState();
    _speech = widget.speechToText ?? stt.SpeechToText();
    _flutterTts = widget.flutterTts ?? FlutterTts();

    _flutterTts.setStartHandler(() {
      setState(() {
        _isSpeaking = true;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() {
          _isListening = true;
          _text = 'Listening...';
        });
        _speech.listen(
          onResult: (val) {
            setState(() {
              _text = val.recognizedWords;
            });
            if (val.finalResult) {
              _processCommand(_text);
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _processCommand(String command) {
    setState(() {
      if (command.toLowerCase().contains('hello')) {
        _response = 'Hello there!';
      } else if (command.toLowerCase().contains('goodbye')) {
        _response = 'Goodbye!';
      } else {
        _response = "I'm sorry, I don't understand that command.";
      }
    });
    _speak(_response);
  }

  void _speak(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Assistant'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'You said:',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    _text,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16.0),
                  if (_response.isNotEmpty)
                    Column(
                      children: [
                        Text(
                          'Assistant says:',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          _response,
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _listen,
        tooltip: 'Listen',
        child: Icon(_isListening
            ? Icons.mic
            : _isSpeaking
                ? Icons.volume_up
                : Icons.mic_none),
      ),
    );
  }
}
