/// Uma tabela dentro do relatório. Cada célula é String, int ou double.
class SecaoRelatorio {
  final String titulo;
  final List<String> colunas;
  final List<List<Object>> linhas;

  /// Largura relativa de cada coluna no PDF (opcional).
  final List<double>? proporcoes;

  const SecaoRelatorio(this.titulo, this.colunas, this.linhas, {this.proporcoes});
}

/// Conteúdo completo de um relatório, antes de virar PDF, Excel ou CSV.
class ConteudoRelatorio {
  final String titulo;
  final String periodo;
  final String geradoEm;
  final List<String> notas;
  final List<SecaoRelatorio> secoes;

  const ConteudoRelatorio({
    required this.titulo,
    required this.periodo,
    required this.geradoEm,
    required this.notas,
    required this.secoes,
  });
}
