import 'dart:typed_data';

/// Tipo de relatório que pode ser gerado.
class TipoRelatorio {
  final String nome;
  final String descricao;
  const TipoRelatorio(this.nome, this.descricao);
}

/// Relatório já gerado (lista "Relatórios recentes").
class Relatorio {
  final String nome;
  final String periodo;
  final String geradoEm;
  final String formato;
  final String status;

  /// Arquivo gerado (fica em memória) para baixar de novo pela lista.
  final Uint8List bytes;
  final String nomeArquivo;
  final String mime;

  const Relatorio({
    required this.nome,
    required this.periodo,
    required this.geradoEm,
    required this.formato,
    required this.status,
    required this.bytes,
    required this.nomeArquivo,
    required this.mime,
  });
}
