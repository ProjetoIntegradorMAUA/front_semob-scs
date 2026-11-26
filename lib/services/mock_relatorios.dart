import '../models/relatorio.dart';

/// Dados de exemplo da tela de relatórios (trocar pela API quando existir).
class MockRelatorios {
  static const tipos = <TipoRelatorio>[
    TipoRelatorio('Consolidado Mensal', 'Resumo geral de operação, passageiros e financeiro'),
    TipoRelatorio('Operação da Frota', 'Viagens programadas x realizadas, km e FCV por linha'),
    TipoRelatorio('Análise de Passageiros', 'Pagantes, não pagantes e evolução semanal'),
    TipoRelatorio('Indicadores Financeiros', 'Vendas, utilização e crédito circulante'),
    TipoRelatorio('Alertas Operacionais', 'Ocorrências por gravidade e status'),
  ];

  static const periodos = ['Julho/2026', 'Agosto/2026', 'Setembro/2026 (1–14)'];
  static const formatos = ['PDF', 'Excel', 'CSV'];

  static const recentes = <Relatorio>[
    Relatorio(
        nome: 'Consolidado Mensal',
        periodo: 'Agosto/2026',
        geradoEm: '01/09/2026 08:30',
        formato: 'PDF',
        status: 'Concluído'),
    Relatorio(
        nome: 'Indicadores Financeiros',
        periodo: 'Agosto/2026',
        geradoEm: '01/09/2026 08:45',
        formato: 'Excel',
        status: 'Concluído'),
    Relatorio(
        nome: 'Análise de Passageiros',
        periodo: 'Julho/2026',
        geradoEm: '03/08/2026 10:05',
        formato: 'CSV',
        status: 'Concluído'),
    Relatorio(
        nome: 'Operação da Frota',
        periodo: 'Julho/2026',
        geradoEm: '03/08/2026 09:40',
        formato: 'PDF',
        status: 'Concluído'),
  ];
}
