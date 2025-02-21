import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class ReadingDecimalScreen extends StatefulWidget {
  const ReadingDecimalScreen({super.key});

  @override
  _ReadingDecimalScreen createState() => _ReadingDecimalScreen();
}
class _ReadingDecimalScreen extends State<ReadingDecimalScreen> {
  final Map<String, String> originalTexts = {
    'h1':'To read decimals:',
    'h2':'1. Say the whole number first.\n'
  '2. Say “and.”\n'
  '3. Say each number after the decimal.\n'
  '4. Don’t forget to say the units of the last digit!',
    'h3':'Examples:',
    'h4':'number: 12.7,'
            'description: Twelve and seven tenths',
    'h5':'number: 38.29'
        'description: Thirty Eight and Twenty Nine Hundredths',
    'h6':'number: 453.01'
 'description: Four Hundred Fifty Three and One Hundredths',
    'NextPage': 'Next Page'
  };
  Map<String, String> translatedTexts = {};
  bool translated = false;
  Future<void> translateTexts() async {
    if (!translated) {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'texts': originalTexts.values.toList()}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          translatedTexts = {
            for (int i = 0; i < originalTexts.keys.length; i++)
              originalTexts.keys.elementAt(i): data['translations'][i]
          };
          translated = true;
        });
      } else {
        print('Failed to fetch translations: ${response.statusCode}');
      }
    } else {
      setState(() {
        translatedTexts.clear();
        translated = false; // Mark as untranslated
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
         title:  const Text('Reading Decimals'),
         backgroundColor: Colors.green,
         actions: [
            IconButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: const Icon(Icons.home),
          ),
           IconButton(
             icon: const Icon(Icons.translate),
             onPressed: translateTexts,
           ),
         ],
       ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
             Text(
               translated
                   ? translatedTexts['h1'] ?? originalTexts['h1']!
                   : originalTexts['h1']!,
               style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 10),
             Text(translated
                ? translatedTexts['h2'] ?? originalTexts['h2']!
                : originalTexts['h2']!,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 30),
             Text(
              translated
                  ? translatedTexts['h3'] ?? originalTexts['h3']!
                  : originalTexts['h3']!,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 20),
            ExampleItem(
              number: '12.7',
              description: 'Twelve and seven tenths',
            ),
            ExampleItem(
              number: '38.29',
              description: 'Thirty Eight and Twenty Nine Hundredths',
            ),
            ExampleItem(
              number: '453.01',
              description: 'Four Hundred Fifty Three and One Hundredths',
            ),
          ],
        ),
      ),
    );
  }
}
class ExampleItem extends StatelessWidget {
  final String number;
  final String description;

  ExampleItem({
    required this.number,
    required this.description,
    super.key,
  });

  final FlutterTts _flutterTts = FlutterTts();


  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  number,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Audio button
          IconButton(
            onPressed: () => _speak(description),
            icon: const Icon(Icons.volume_up),
            color: Colors.orange,
            iconSize: 32,
          ),
        ],
      ),
    );
  }
}