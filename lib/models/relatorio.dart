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
  const Relatorio({
    required this.nome,
    required this.periodo,
    required this.geradoEm,
    required this.formato,
    required this.status,
  });
}
