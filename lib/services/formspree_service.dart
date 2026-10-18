import 'dart:convert';
import 'package:http/http.dart' as http;

class FormspreeService {
  // ID do formulário Formspree padrão do Movi
  static const String defaultFormId = 'xeaedeeo';

  /// Envia dados para o Formspree via requisição HTTP POST
  Future<bool> sendForm({
    required String name,
    required String email,
    required String subject,
    required String message,
    String? customFormId,
  }) async {
    final formId = (customFormId != null && customFormId.trim().isNotEmpty)
        ? customFormId.trim()
        : defaultFormId;

    final url = Uri.parse('https://formspree.io/f/$formId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          '_subject': 'Movi App: $subject',
          'subject': subject,
          'message': message,
          'submitted_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        throw Exception('Erro Formspree (Código HTTP: ${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }
}
