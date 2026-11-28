import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Web: cria um link temporário e "clica" nele para o navegador baixar.
Future<String?> salvarArquivo({
  required String nome,
  required Uint8List bytes,
  required String mime,
}) async {
  final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: mime));
  final url = web.URL.createObjectURL(blob);
  final link = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = nome;
  web.document.body?.append(link);
  link.click();
  link.remove();
  web.URL.revokeObjectURL(url);
  return null; // o navegador escolhe a pasta (normalmente Downloads)
}

Future<void> mostrarNaPasta(String caminho) async {}
