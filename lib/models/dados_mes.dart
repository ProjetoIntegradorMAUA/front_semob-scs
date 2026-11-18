import 'faixa_fcv.dart';
import 'linha_resumo.dart';

/// Uma viagem com problema (não realizada, não iniciada ou não terminada).
class OcorrenciaViagem {
  final int dia;
  final String linha;
  final String sentido;
  final String horario; // "HH:MM" previsto
  const OcorrenciaViagem(this.dia, this.linha, this.sentido, this.horario);
}

/// Todos os números de um mês (ou quinzena) usados pelas telas.
/// Cada grupo de séries tem a sua própria lista de dias, porque os relatórios
/// de passageiros e de vendas nem sempre cobrem os mesmos dias da operação.
class DadosMes {
  final String id;
  final String rotulo; // "Agosto/2026"
  final String periodo; // "01 a 31/08"
  final String? nota; // aviso exibido na tela (ex.: dados parciais)
  final int mes;

  // Operação (frota)
  final List<int> diasOper;
  final List<int> viagensProg;
  final List<int> viagensReal;
  final double kmTotal;
  final List<LinhaResumo> linhas;
  final List<FaixaFcv> faixas;

  /// Viagens realizadas por hora de saída, de 4h até 3h (24 valores).
  final List<int> viagensPorHora;

  // Passageiros
  final List<int> diasPass;
  final List<int> catraca;
  final List<int> antecipados;
  final List<int> naoPagantes;

  // Financeiro
  final List<int> diasFin;
  final List<double> vendas;
  final List<double> utilizacao;

  // Ocorrências de viagem (com a linha em que aconteceram)
  final List<OcorrenciaViagem> naoRealizadas;
  final List<OcorrenciaViagem> naoTerminadas;
  final List<OcorrenciaViagem> naoIniciadas;

  const DadosMes({
    required this.id,
    required this.rotulo,
    required this.periodo,
    required this.nota,
    required this.mes,
    required this.diasOper,
    required this.viagensProg,
    required this.viagensReal,
    required this.kmTotal,
    required this.linhas,
    required this.faixas,
    required this.viagensPorHora,
    required this.diasPass,
    required this.catraca,
    required this.antecipados,
    required this.naoPagantes,
    required this.diasFin,
    required this.vendas,
    required this.utilizacao,
    required this.naoRealizadas,
    required this.naoTerminadas,
    required this.naoIniciadas,
  });

  static const horasLabels = [
    '4h', '5h', '6h', '7h', '8h', '9h', '10h', '11h', '12h', '13h', '14h', '15h',
    '16h', '17h', '18h', '19h', '20h', '21h', '22h', '23h', '0h', '1h', '2h', '3h',
  ];

  static int _somaInt(List<int> l) => l.fold<int>(0, (a, b) => a + b);
  static double _somaDouble(List<double> l) => l.fold<double>(0, (a, b) => a + b);

  // ---- operação
  int get viagensProgramadas => _somaInt(viagensProg);
  int get viagensRealizadas => _somaInt(viagensReal);
  int get viagensNaoRealizadas => viagensProgramadas - viagensRealizadas;
  double get fcv =>
      viagensProgramadas == 0 ? 0 : viagensRealizadas / viagensProgramadas * 100;
  List<int> get naoRealizadasPorDia => [
        for (var i = 0; i < viagensProg.length; i++) viagensProg[i] - viagensReal[i]
      ];

  /// Linhas ordenadas da que mais fez viagens para a que menos fez.
  List<LinhaResumo> get linhasOrdenadas {
    final l = List<LinhaResumo>.of(linhas);
    l.sort((a, b) => b.viagens.compareTo(a.viagens));
    return l;
  }

  // ---- passageiros
  int get passageirosCatraca => _somaInt(catraca);
  int get passageirosAntecipados => _somaInt(antecipados);
  int get passageirosPagantes => passageirosCatraca + passageirosAntecipados;
  int get passageirosNaoPagantes => _somaInt(naoPagantes);
  int get passageirosTotal => passageirosPagantes + passageirosNaoPagantes;
  List<int> get passageirosPorDia => [
        for (var i = 0; i < diasPass.length; i++)
          catraca[i] + antecipados[i] + naoPagantes[i]
      ];
  double get mediaDiariaPassageiros =>
      diasPass.isEmpty ? 0 : passageirosTotal / diasPass.length;

  // ---- financeiro
  double get totalVendas => _somaDouble(vendas);
  double get totalUtilizacao => _somaDouble(utilizacao);
  double get creditoCirculante => totalVendas - totalUtilizacao;
  double get pctUtilizacao => totalVendas == 0 ? 0 : totalUtilizacao / totalVendas * 100;
  List<double> get saldoPorDia => [
        for (var i = 0; i < diasFin.length; i++) vendas[i] - utilizacao[i]
      ];
  int get diasSaldoNegativo => saldoPorDia.where((s) => s < 0).length;
}
