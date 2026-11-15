import 'package:flutter/foundation.dart';

/// Perfil do usuário (SIMULADO, em memória).
/// Quando houver login/back-end, troque o miolo dos métodos por chamadas à API.
class PerfilService extends ChangeNotifier {
  PerfilService._();
  static final PerfilService instance = PerfilService._();

  static const _nomeInicial = 'Administrador SEMOB';
  static const senhaInicial = 'semob123'; // só para o protótipo

  String _nome = _nomeInicial;
  String _senha = senhaInicial;

  String get nome => _nome;

  /// Retorna `null` se deu certo, ou a mensagem de erro.
  String? alterarNome(String novoNome) {
    final n = novoNome.trim();
    if (n.isEmpty) return 'Informe um nome.';
    if (n.length < 3) return 'O nome deve ter ao menos 3 caracteres.';
    _nome = n;
    notifyListeners();
    return null;
  }

  /// Retorna `null` se deu certo, ou a mensagem de erro.
  String? alterarSenha({
    required String atual,
    required String nova,
    required String confirmacao,
  }) {
    if (atual != _senha) return 'A senha atual está incorreta.';
    if (nova.length < 6) return 'A nova senha deve ter ao menos 6 caracteres.';
    if (nova == atual) return 'A nova senha deve ser diferente da atual.';
    if (nova != confirmacao) return 'A confirmação não confere com a nova senha.';
    _senha = nova;
    notifyListeners();
    return null;
  }

  /// Volta ao estado inicial (usado nos testes).
  @visibleForTesting
  void resetar() {
    _nome = _nomeInicial;
    _senha = senhaInicial;
    notifyListeners();
  }
}
