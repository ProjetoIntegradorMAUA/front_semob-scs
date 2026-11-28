import 'dart:io';
import 'dart:typed_data';

/// Desktop: grava o arquivo na pasta Downloads do usuário.
Future<String?> salvarArquivo({
  required String nome,
  required Uint8List bytes,
  required String mime,
}) async {
  final casa = Platform.isWindows
      ? Platform.environment['USERPROFILE']
      : Platform.environment['HOME'];
  if (casa == null || casa.isEmpty) {
    throw UnsupportedError('Não foi possível achar a pasta Downloads.');
  }
  final pasta = Directory('$casa${Platform.pathSeparator}Downloads');
  await pasta.create(recursive: true);

  final destino = _caminhoLivre(pasta.path, nome);
  await File(destino).writeAsBytes(bytes, flush: true);
  return destino;
}

/// "relatorio.pdf" -> "relatorio (1).pdf" se já existir.
String _caminhoLivre(String pasta, String nome) {
  final sep = Platform.pathSeparator;
  final ponto = nome.lastIndexOf('.');
  final base = ponto > 0 ? nome.substring(0, ponto) : nome;
  final ext = ponto > 0 ? nome.substring(ponto) : '';
  var candidato = '$pasta$sep$nome';
  var i = 1;
  while (File(candidato).existsSync()) {
    candidato = '$pasta$sep$base ($i)$ext';
    i++;
  }
  return candidato;
}

/// Abre o explorador de arquivos já com o arquivo selecionado.
Future<void> mostrarNaPasta(String caminho) async {
  try {
    if (Platform.isWindows) {
      await Process.run('explorer.exe', ['/select,', caminho]);
    } else if (Platform.isMacOS) {
      await Process.run('open', ['-R', caminho]);
    } else if (Platform.isLinux) {
      final pasta = File(caminho).parent.path;
      await Process.run('xdg-open', [pasta]);
    }
  } catch (_) {
    // se não der para abrir a pasta, não é um erro grave
  }
}
