enum Gravidade {
  critico('Crítico'),
  atencao('Atenção'),
  baixo('Baixo');

  final String rotulo;
  const Gravidade(this.rotulo);
}

enum StatusAlerta {
  aberto('Aberto'),
  emAnalise('Em análise'),
  resolvido('Resolvido');

  final String rotulo;
  const StatusAlerta(this.rotulo);
}

class Alerta {
  final String id;
  final DateTime data;
  final String linha;
  final String tipo;
  final String descricao;
  final Gravidade gravidade;
  final StatusAlerta status;

  const Alerta({
    required this.id,
    required this.data,
    required this.linha,
    required this.tipo,
    required this.descricao,
    required this.gravidade,
    required this.status,
  });
}
