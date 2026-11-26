import '../models/alerta.dart';
import 'formatadores.dart';
import 'mock_alertas.dart';
import 'mock_dados_mes.dart';

class _Bruto {
  final DateTime data;
  final String linha;
  final String tipo;
  final String descricao;
  final Gravidade gravidade;
  const _Bruto(this.data, this.linha, this.tipo, this.descricao, this.gravidade);
}

/// Gera as ocorrências a partir dos dados de agosto/setembro.
///
/// REGRAS (simuladas — o ZIP não traz gravidade nem status):
///  - Viagens não realizadas no dia: >= 7 crítico, 3 a 6 atenção, 1 a 2 baixo.
///  - Saldo diário negativo (vendas - utilização): <= -7.500 crítico,
///    <= -3.000 atenção, demais baixo.
///  - Viagem não iniciada: atenção.
///  - Saldo negativo na 1ª quinzena de setembro: crítico.
///  - Status: crítico = aberto, atenção = em análise, baixo = resolvido.
class AlertasService {
  static List<Alerta> listar() {
    final brutos = <_Bruto>[];

    final nao = MockAlertas.naoRealizadasPorDia;
    for (var i = 0; i < nao.length; i++) {
      final n = nao[i];
      if (n == 0) continue;
      brutos.add(_Bruto(
        DateTime(2026, 8, i + 1),
        '—',
        'Viagens não realizadas',
        '$n viagem(ns) não realizada(s) no dia',
        n >= 7
            ? Gravidade.critico
            : n >= 3
                ? Gravidade.atencao
                : Gravidade.baixo,
      ));
    }

    final vendas = MockFinanceiro.vendasPorDia;
    final uso = MockFinanceiro.utilizacaoPorDia;
    for (var i = 0; i < vendas.length; i++) {
      final saldo = vendas[i] - uso[i];
      if (saldo >= 0) continue;
      brutos.add(_Bruto(
        DateTime(2026, 8, i + 1),
        '—',
        'Crédito circulante',
        'Saldo diário negativo (${fmtMoney(saldo)})',
        saldo <= -7500
            ? Gravidade.critico
            : saldo <= -3000
                ? Gravidade.atencao
                : Gravidade.baixo,
      ));
    }

    for (final v in MockAlertas.viagensNaoIniciadas) {
      brutos.add(_Bruto(
        DateTime(2026, 8, v.dia),
        v.linha,
        'Viagem não iniciada',
        '${v.descricao} · saída prevista ${v.horario}',
        Gravidade.atencao,
      ));
    }

    brutos.add(_Bruto(
      DateTime(2026, 9, 14),
      '—',
      'Crédito circulante',
      'Saldo negativo na 1ª quinzena de setembro (${fmtMoney(MockAlertas.saldoSetembroQuinzena)})',
      Gravidade.critico,
    ));

    brutos.sort((a, b) => a.data.compareTo(b.data));

    final lista = <Alerta>[];
    for (var i = 0; i < brutos.length; i++) {
      final b = brutos[i];
      lista.add(Alerta(
        id: 'ALR-${(i + 1).toString().padLeft(3, '0')}',
        data: b.data,
        linha: b.linha,
        tipo: b.tipo,
        descricao: b.descricao,
        gravidade: b.gravidade,
        status: switch (b.gravidade) {
          Gravidade.critico => StatusAlerta.aberto,
          Gravidade.atencao => StatusAlerta.emAnalise,
          Gravidade.baixo => StatusAlerta.resolvido,
        },
      ));
    }
    return lista.reversed.toList(); // mais recentes primeiro
  }
}
