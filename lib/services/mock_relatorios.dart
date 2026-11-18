import '../models/relatorio.dart';
import 'dados_service.dart';

/// Opções da tela de relatórios.
class MockRelatorios {
  static const tipos = <TipoRelatorio>[
    TipoRelatorio('Consolidado Mensal', 'Resumo geral de operação, passageiros e financeiro'),
    TipoRelatorio('Operação da Frota', 'Viagens programadas x realizadas, km e FCV por linha'),
    TipoRelatorio('Análise de Passageiros', 'Pagantes, não pagantes e passageiros por dia'),
    TipoRelatorio('Indicadores Financeiros', 'Vendas, utilização e crédito circulante por dia'),
    TipoRelatorio('Alertas Operacionais', 'Ocorrências por gravidade, linha e status'),
  ];

  static List<String> get periodos => DadosService.rotulos;
  static const formatos = ['PDF', 'Excel', 'CSV'];
}
