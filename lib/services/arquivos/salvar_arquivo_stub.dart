import 'dart:typed_data';

Future<String?> salvarArquivo({
  required String nome,
  required Uint8List bytes,
  required String mime,
}) async {
  throw UnsupportedError('Download não disponível nesta plataforma.');
}

Future<void> mostrarNaPasta(String caminho) async {}
