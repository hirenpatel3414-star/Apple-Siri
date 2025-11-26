import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:voice_assistant/main.dart';

import 'widget_test.mocks.dart';

@GenerateMocks([stt.SpeechToText, FlutterTts])
void main() {
  testWidgets('Voice Assistant smoke test', (WidgetTester tester) async {
    final mockSpeechToText = MockSpeechToText();
    final mockFlutterTts = MockFlutterTts();

    when(mockSpeechToText.initialize(
      onStatus: anyNamed('onStatus'),
      onError: anyNamed('onError'),
    )).thenAnswer((_) async => true);

    when(mockSpeechToText.listen(
      onResult: anyNamed('onResult'),
    )).thenAnswer((_) async {});

    when(mockFlutterTts.speak(any)).thenAnswer((_) async => 1);

    await tester.pumpWidget(MyApp(
      speechToText: mockSpeechToText,
      flutterTts: mockFlutterTts,
    ));

    expect(find.text('Press the button and start speaking...'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.mic_none));
    await tester.pumpAndSettle();

    expect(find.text('Listening...'), findsOneWidget);
  });
}
