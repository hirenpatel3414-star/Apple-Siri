import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart' as stt_result;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:voice_assistant/main.dart';

import 'widget_test.mocks.dart';

void main() {
  testWidgets('Voice Assistant response display bug', (WidgetTester tester) async {
    final mockSpeechToText = MockSpeechToText();
    final mockFlutterTts = MockFlutterTts();

    // Stub initialize to return true (available)
    when(mockSpeechToText.initialize(
      onStatus: anyNamed('onStatus'),
      onError: anyNamed('onError'),
    )).thenAnswer((_) async => true);

    // Capture the onResult callback
    late Function(stt_result.SpeechRecognitionResult) onResultCallback;
    when(mockSpeechToText.listen(
      onResult: anyNamed('onResult'),
    )).thenAnswer((invocation) async {
      onResultCallback = invocation.namedArguments[#onResult] as Function(stt_result.SpeechRecognitionResult);
    });

    when(mockFlutterTts.speak(any)).thenAnswer((_) async => 1);

    // Stub setStartHandler and setCompletionHandler to avoid errors,
    // but we won't manually trigger them to simulate immediate UI update requirement
    when(mockFlutterTts.setStartHandler(any)).thenReturn(null);
    when(mockFlutterTts.setCompletionHandler(any)).thenReturn(null);

    await tester.pumpWidget(MyApp(
      speechToText: mockSpeechToText,
      flutterTts: mockFlutterTts,
    ));

    // Tap to listen
    await tester.tap(find.byIcon(Icons.mic_none));
    await tester.pumpAndSettle();

    verify(mockSpeechToText.listen(onResult: anyNamed('onResult'))).called(1);

    // Simulate speech result "Hello"
    final result = stt_result.SpeechRecognitionResult(
      [stt_result.SpeechRecognitionWords('Hello', [], 1.0)],
      true, // finalResult
    );

    // Trigger the callback
    onResultCallback(result);

    // Pump to process the state change.
    // If _processCommand called setState, this pump should show the new text.
    await tester.pump();

    // Expect "You said: Hello"
    expect(find.text('Hello'), findsOneWidget);

    // Expect "Assistant says:" and "Hello there!"
    // This is expected to FAIL if the bug exists
    expect(find.text('Assistant says:'), findsOneWidget);
    expect(find.text('Hello there!'), findsOneWidget);
  });
}
