import 'package:flutter/services.dart';

class IsbnInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    int cursorPosition = newValue.selection.end;
    int digitsBeforeCursor = 0;
    for (int i = 0; i < cursorPosition && i < text.length; i++) {
      if (RegExp(r'[0-9]').hasMatch(text[i])) {
        digitsBeforeCursor++;
      }
    }

    final digitsOnly = text.replaceAll(RegExp(r'\D'), '');
    final limited = digitsOnly.length > 13 ? digitsOnly.substring(0, 13) : digitsOnly;
    if (digitsBeforeCursor > limited.length) {
      digitsBeforeCursor = limited.length;
    }

    final buffer = StringBuffer();
    int newCursor = 0;
    int digitCount = 0;

    for (int i = 0; i < limited.length; i++) {
      if (i == 3 || i == 5 || i == 9 || i == 12) {
        buffer.write('-');
        if (digitCount < digitsBeforeCursor) {
          newCursor++;
        }
      }
      buffer.write(limited[i]);
      digitCount++;
      if (digitCount <= digitsBeforeCursor) {
        newCursor++;
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursor.clamp(0, formatted.length)),
    );
  }
}

class FormValidators {
  /// Retorna true se a URL for válida (ou vazia, caso seja opcional).
  static bool isValidUrl(String? url, {bool allowEmpty = true}) {
    if (url == null || url.trim().isEmpty) {
      return allowEmpty;
    }

    final trimmed = url.trim();

    // Deve começar com http:// ou https://
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      return false;
    }

    // Não deve conter espaços
    if (trimmed.contains(' ')) {
      return false;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null) {
      return false;
    }

    // Precisa de scheme http/https e host com ponto
    if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return false;
    }

    if (uri.host.isEmpty || !uri.host.contains('.')) {
      return false;
    }

    if (uri.host.startsWith('.') || uri.host.endsWith('.')) {
      return false;
    }

    return true;
  }

  /// Retorna mensagem de erro amigável ou null se a URL for válida
  static String? validateUrl(String? url, {bool required = false}) {
    if (url == null || url.trim().isEmpty) {
      if (required) return 'Este link é obrigatório';
      return null;
    }

    final trimmed = url.trim();
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      return 'O link deve começar com https:// ou http://';
    }

    if (trimmed.contains(' ')) {
      return 'O link não pode conter espaços';
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || uri.host.isEmpty || !uri.host.contains('.')) {
      return 'Formato de link inválido (ex: https://dominio.com/...)';
    }

    if (uri.host.startsWith('.') || uri.host.endsWith('.')) {
      return 'Domínio inválido';
    }

    return null;
  }

  /// Retorna true se o e-mail estiver em formato válido
  static bool isValidEmail(String? email) {
    if (email == null || email.trim().isEmpty) return false;
    final regex = RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');
    return regex.hasMatch(email.trim());
  }

  /// Retorna mensagem de erro amigável ou null se o e-mail for válido
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Por favor, informe seu e-mail.';
    }
    if (!isValidEmail(email)) {
      return 'Informe um e-mail válido (ex: usuario@escola.com.br).';
    }
    return null;
  }

  /// Valida senha conforme contrato de autenticação (mínimo 8 caracteres, letra e número)
  static bool isValidPassword(String? password) {
    if (password == null || password.length < 8) return false;
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasDigit = RegExp(r'[0-9]').hasMatch(password);
    return hasLetter && hasDigit;
  }

  /// Retorna mensagem descritiva de validação de senha
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Por favor, informe sua senha.';
    }
    if (password.length < 8) {
      return 'A senha deve conter no mínimo 8 caracteres.';
    }
    if (!RegExp(r'[a-zA-Z]').hasMatch(password) || !RegExp(r'[0-9]').hasMatch(password)) {
      return 'A senha deve conter pelo menos uma letra e um número.';
    }
    return null;
  }
}
