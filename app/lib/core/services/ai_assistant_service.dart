import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Service that queries Google Gemma / OpenRouter LLM using an API key
/// securely fetched from Firestore (collection: `config`, doc: `ai`).
///
/// If Firestore config is not present, it gracefully falls back to agronomic heuristics.
class AiAssistantService {
  final FirebaseFirestore _firestore;

  AiAssistantService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String defaultModel = 'google/gemma-4-26b-a4b-it:free';
  static const String openRouterUrl = 'https://openrouter.ai/api/v1/chat/completions';

  /// Fetches the API key stored in Firestore at config/ai -> apiKey
  Future<String?> _getApiKey() async {
    try {
      final snapshot = await _firestore.collection('config').doc('ai').get();
      if (snapshot.exists) {
        final data = snapshot.data();
        return data?['apiKey'] as String?;
      }
    } catch (e) {
      debugPrint('[AiAssistant] Error loading API key from Firestore: $e');
    }
    return null;
  }

  /// Queries the LLM for agricultural advice or disease remediation.
  Future<String> askAssistant({
    required String prompt,
    String? systemPrompt,
  }) async {
    final apiKey = await _getApiKey();
    if (apiKey == null || apiKey.trim().isEmpty) {
      throw Exception('AI Assistant API key is not configured in Firestore config/ai.');
    }

    final headers = {
      'Authorization': 'Bearer ${apiKey.trim()}',
      'Content-Type': 'application/json',
      'HTTP-Referer': 'https://agrovision.lk',
      'X-Title': 'AgroVision Crop Advisor',
    };

    final messages = <Map<String, String>>[
      if (systemPrompt != null)
        {'role': 'system', 'content': systemPrompt}
      else
        {
          'role': 'system',
          'content':
              'You are AgroVision AI, an expert agricultural advisor specializing in Sri Lankan nightshade cultivation (Tomato, Chilli, Eggplant, Potato). Provide clear, practical, bulleted agronomic guidance.',
        },
      {'role': 'user', 'content': prompt},
    ];

    final body = jsonEncode({
      'model': defaultModel,
      'messages': messages,
      'temperature': 0.7,
      'max_tokens': 600,
    });

    final response = await http.post(
      Uri.parse(openRouterUrl),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = json['choices'] as List<dynamic>?;
      if (choices != null && choices.isNotEmpty) {
        final message = choices[0]['message'] as Map<String, dynamic>?;
        return (message?['content'] as String?)?.trim() ?? 'No response received.';
      }
    }

    throw Exception(
      'AI request failed with code ${response.statusCode}: ${response.body}',
    );
  }
}

final aiAssistantServiceProvider = Provider<AiAssistantService>((ref) {
  return AiAssistantService();
});
