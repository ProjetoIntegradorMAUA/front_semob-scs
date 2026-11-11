import 'package:flutter/material.dart';

/// Guarda se o app está no tema claro ou escuro.
/// O main.dart escuta este serviço e troca o tema na hora.
/// (Fica só em memória: ao fechar o app volta para o claro.)
class TemaService extends ChangeNotifier {
  TemaService._();
  static final TemaService instance = TemaService._();

  ThemeMode _modo = ThemeMode.light;
  ThemeMode get modo => _modo;
  bool get escuro => _modo == ThemeMode.dark;

  void definirEscuro(bool escuro) {
    final novo = escuro ? ThemeMode.dark : ThemeMode.light;
    if (novo == _modo) return;
    _modo = novo;
    notifyListeners();
  }
}
