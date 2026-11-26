/// Dados brutos para os alertas (AGOSTO/2026 e 1ª quinzena de SETEMBRO/2026).
/// Fontes: Mensal_202608.html (viagens não realizadas por dia),
/// Mensal_Viag_Ninic_202608.html (viagens não iniciadas) e
/// Saldos_Quinzenal.html de Setembro (crédito circulante).
/// As regras de gravidade ficam em alertas_service.dart.
class NaoIniciada {
  final int dia;
  final String linha;
  final String descricao;
  final String horario;
  const NaoIniciada(this.dia, this.linha, this.descricao, this.horario);
}

class MockAlertas {
  /// Viagens não realizadas em cada dia de agosto (índice 0 = dia 01).
  static const naoRealizadasPorDia = <int>[0, 7, 9, 7, 0, 5, 4, 2, 0, 0, 3, 0, 0, 2, 0, 0, 2, 2, 1, 1, 1, 0, 0, 1, 2, 0, 0, 1, 4, 2, 0];

  static const viagensNaoIniciadas = <NaoIniciada>[
    NaoIniciada(2, '10', 'Oswaldo Cruz Sentido Estação', '14:35'),
    NaoIniciada(2, '10', 'Oswaldo Cruz Sentido Estação', '15:25'),
    NaoIniciada(2, '10', 'Oswaldo Cruz Sentido Estação', '16:15'),
    NaoIniciada(4, '04', 'B. Santa Paula Sentido Bairro', '05:40'),
    NaoIniciada(7, '02', 'Circular Gerty Sentido Ida', '12:20'),
    NaoIniciada(7, '07', 'B. Boa Vista Sentido Estacao', '12:15'),
  ];

  /// Crédito circulante (vendas - utilização) da 1ª quinzena de setembro.
  static const saldoSetembroQuinzena = -73046.66;
}
