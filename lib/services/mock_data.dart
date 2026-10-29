import '../models/faixa_fcv.dart';
import '../models/linha_resumo.dart';

/// Dados de AGOSTO/2026, extraídos dos relatórios do ZIP
/// (Passageiros_Mensal, Mensal_202608, Mensal_FCV_202608, Mensal_Linhas_202608).
/// Troque por chamadas à API quando o back-end estiver pronto.
class MockData {
  static const passCatraca = 228430;
  static const passAntecipados = 59948;
  static const passNaoPagantes = 761870;
  static const passTotal = 1050248;

  static const diasLabels = ['01', '02', '03', '04', '05', '06', '07'];
  static const passPorDia = <double>[16544, 8098, 38807, 40059, 40808, 41562, 38721];

  static const viagensProgramadas = 35050;
  static const viagensRealizadas = 34994;
  static const viagensNaoRealizadas = 56;
  static const kmTotal = 275694.5;

  static const viagensProgPorDia = <double>[924, 710, 1280, 1280, 1280, 1280, 1280];
  static const viagensRealPorDia = <double>[924, 703, 1271, 1273, 1280, 1275, 1276];

  static double get fcv => viagensRealizadas / viagensProgramadas * 100;

  static const topLinhas = <LinhaResumo>[
    LinhaResumo('03', 45189.3, 5848),
    LinhaResumo('02', 47042.5, 5841),
    LinhaResumo('06', 30754.0, 4496),
    LinhaResumo('07', 24864.6, 3556),
    LinhaResumo('01', 22753.9, 3427),
    LinhaResumo('10', 21304.3, 3419),
  ];

  // ATENÇÃO: confirme com o time o nome real de cada faixa horária.
  static const faixas = <FaixaFcv>[
    FaixaFcv('Faixa 1', 13604, 13580),
    FaixaFcv('Faixa 2', 11933, 11906),
    FaixaFcv('Faixa 3', 9513, 9508),
  ];

  static const meses = ['Julho/2026', 'Agosto/2026', 'Setembro/2026'];
}
