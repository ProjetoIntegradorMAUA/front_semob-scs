import '../models/alerta.dart';
import '../models/dados_mes.dart';
import 'dados_service.dart';
import 'formatadores.dart';

class _Bruto {
  final DateTime data;
  final String linha;
  final String tipo;
  final String descricao;
  final Gravidade gravidade;
  const _Bruto(this.data, this.linha, this.tipo, this.descricao, this.gravidade);
}

/// Gera as ocorrências a partir dos dados dos meses.
///
/// REGRAS (simuladas — os relatórios não trazem gravidade nem status):
///  - Viagens não realizadas (por dia e linha): 3 ou mais = crítico,
///    2 = atenção, 1 = baixo.
///  - Viagens não iniciadas / não terminadas (por dia e linha): 3 ou mais =
///    crítico, senão atenção.
///  - Saldo diário negativo (vendas - utilização, vale para todas as linhas):
///    <= -7.500 crítico, <= -3.000 atenção, demais baixo.
///  - Status: crítico = aberto, atenção = em análise, baixo = resolvido.
class AlertasService {
  static const todas = 'Todas';

  static List<Alerta> listar() {
    final brutos = <_Bruto>[];
    for (final m in DadosService.meses) {
      _viagens(m, m.naoRealizadas, 'Viagens não realizadas', brutos, naoRealizada: true);
      _viagens(m, m.naoTerminadas, 'Viagem não terminada', brutos);
      _viagens(m, m.naoIniciadas, 'Viagem não iniciada', brutos);
      _saldos(m, brutos);
    }

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

  static void _viagens(
    DadosMes m,
    List<OcorrenciaViagem> ocorrencias,
    String tipo,
    List<_Bruto> saida, {
    bool naoRealizada = false,
  }) {
    // agrupa por dia + linha
    final grupos = <String, List<OcorrenciaViagem>>{};
    for (final o in ocorrencias) {
      grupos.putIfAbsent('${o.dia}|${o.linha}', () => []).add(o);
    }
    for (final g in grupos.values) {
      final n = g.length;
      final horarios = (g.map((o) => o.horario).toList()..sort()).join(', ');
      final Gravidade grav;
      if (n >= 3) {
        grav = Gravidade.critico;
      } else if (naoRealizada && n == 1) {
        grav = Gravidade.baixo;
      } else {
        grav = Gravidade.atencao;
      }
      saida.add(_Bruto(
        DateTime(2026, m.mes, g.first.dia),
        g.first.linha,
        tipo,
        '$n ${n == 1 ? 'viagem' : 'viagens'} - saída prevista: $horarios',
        grav,
      ));
    }
  }

  static void _saldos(DadosMes m, List<_Bruto> saida) {
    final saldos = m.saldoPorDia;
    for (var i = 0; i < saldos.length; i++) {
      final s = saldos[i];
      if (s >= 0) continue;
      saida.add(_Bruto(
        DateTime(2026, m.mes, m.diasFin[i]),
        todas,
        'Crédito circulante',
        'Saldo diário negativo (${fmtMoney(s)})',
        s <= -7500
            ? Gravidade.critico
            : s <= -3000
                ? Gravidade.atencao
                : Gravidade.baixo,
      ));
    }
  }
}
