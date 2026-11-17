import '../models/alerta.dart';
import '../models/dados_mes.dart';
import '../models/relatorio_conteudo.dart';
import 'alertas_service.dart';
import 'dados_service.dart';
import 'formatadores.dart';

/// Monta o CONTEÚDO de cada tipo de relatório a partir dos dados do mês.
class RelatorioService {
  static ConteudoRelatorio montar({
    required String tipo,
    required DadosMes dados,
    required String geradoEm,
  }) {
    final secoes = switch (tipo) {
      'Operação da Frota' => _operacao(dados),
      'Análise de Passageiros' => _passageiros(dados),
      'Indicadores Financeiros' => _financeiro(dados),
      'Alertas Operacionais' => _alertas(dados),
      _ => _consolidado(dados),
    };
    return ConteudoRelatorio(
      titulo: tipo,
      periodo: '${dados.rotulo} (${dados.periodo})',
      geradoEm: geradoEm,
      notas: [if (dados.nota != null) dados.nota!],
      secoes: secoes,
    );
  }

  static String _dm(int dia, int mes) => '${doisDigitos(dia)}/${doisDigitos(mes)}';

  static String _linhaTexto(String codigo) {
    final nome = DadosService.nomeLinha(codigo);
    if (codigo == AlertasService.todas) return 'Todas';
    return nome.isEmpty ? codigo : '$codigo - $nome';
  }

  static List<SecaoRelatorio> _consolidado(DadosMes d) => [
        SecaoRelatorio('Resumo do período', const ['Indicador', 'Valor'], [
          ['Total de passageiros', d.passageirosTotal],
          ['Passageiros pagantes', d.passageirosPagantes],
          ['Passageiros não pagantes', d.passageirosNaoPagantes],
          ['Média diária de passageiros', d.mediaDiariaPassageiros.round()],
          ['Viagens programadas', d.viagensProgramadas],
          ['Viagens realizadas', d.viagensRealizadas],
          ['Viagens não realizadas', d.viagensNaoRealizadas],
          ['Cumprimento de viagens (FCV)', fmtPct(d.fcv)],
          ['Quilometragem total (km)', d.kmTotal],
          ['Vendas (R\$)', d.totalVendas],
          ['Créditos utilizados (R\$)', d.totalUtilizacao],
          ['Crédito circulante (R\$)', d.creditoCirculante],
        ], proporcoes: const [3, 2]),
      ];

  static List<SecaoRelatorio> _operacao(DadosMes d) => [
        SecaoRelatorio('Resumo da operação', const ['Indicador', 'Valor'], [
          ['Viagens programadas', d.viagensProgramadas],
          ['Viagens realizadas', d.viagensRealizadas],
          ['Viagens não realizadas', d.viagensNaoRealizadas],
          ['Cumprimento de viagens (FCV)', fmtPct(d.fcv)],
          ['Quilometragem total (km)', d.kmTotal],
        ], proporcoes: const [3, 2]),
        SecaoRelatorio('Viagens por linha', const ['Linha', 'Viagens', 'Km'], [
          for (final l in d.linhasOrdenadas) [_linhaTexto(l.linha), l.viagens, l.km],
        ], proporcoes: const [4, 2, 2]),
        SecaoRelatorio(
            'Cumprimento por faixa horária',
            const ['Faixa', 'Programadas', 'Realizadas', 'Não realizadas', 'FCV'],
            [
              for (final f in d.faixas)
                [f.nome, f.programadas, f.realizadas, f.programadas - f.realizadas, fmtPct(f.fcv)],
            ]),
        SecaoRelatorio('Viagens por dia', const ['Data', 'Programadas', 'Realizadas', 'Não realizadas'], [
          for (var i = 0; i < d.diasOper.length; i++)
            [
              _dm(d.diasOper[i], d.mes),
              d.viagensProg[i],
              d.viagensReal[i],
              d.viagensProg[i] - d.viagensReal[i],
            ],
        ]),
      ];

  static List<SecaoRelatorio> _passageiros(DadosMes d) => [
        SecaoRelatorio('Resumo de passageiros', const ['Indicador', 'Valor'], [
          ['Total de passageiros', d.passageirosTotal],
          ['Catraca', d.passageirosCatraca],
          ['Antecipados', d.passageirosAntecipados],
          ['Pagantes (catraca + antecipados)', d.passageirosPagantes],
          ['Não pagantes', d.passageirosNaoPagantes],
          ['Média diária', d.mediaDiariaPassageiros.round()],
        ], proporcoes: const [3, 2]),
        SecaoRelatorio('Passageiros por dia', const ['Data', 'Catraca', 'Antecipados', 'Não pagantes', 'Total'], [
          for (var i = 0; i < d.diasPass.length; i++)
            [
              _dm(d.diasPass[i], d.mes),
              d.catraca[i],
              d.antecipados[i],
              d.naoPagantes[i],
              d.catraca[i] + d.antecipados[i] + d.naoPagantes[i],
            ],
        ]),
      ];

  static List<SecaoRelatorio> _financeiro(DadosMes d) => [
        SecaoRelatorio('Resumo financeiro', const ['Indicador', 'Valor'], [
          ['Total de vendas (R\$)', d.totalVendas],
          ['Créditos utilizados (R\$)', d.totalUtilizacao],
          ['Crédito circulante (R\$)', d.creditoCirculante],
          ['Utilização sobre as vendas', fmtPct(d.pctUtilizacao)],
        ], proporcoes: const [3, 2]),
        SecaoRelatorio('Vendas e utilização por dia', const ['Data', 'Vendas (R\$)', 'Utilização (R\$)', 'Saldo (R\$)'], [
          for (var i = 0; i < d.diasFin.length; i++)
            [
              _dm(d.diasFin[i], d.mes),
              d.vendas[i],
              d.utilizacao[i],
              d.vendas[i] - d.utilizacao[i],
            ],
        ]),
      ];

  static List<SecaoRelatorio> _alertas(DadosMes d) {
    final lista = AlertasService.listar().where((a) => a.data.month == d.mes).toList();
    int conta(Gravidade g) => lista.where((a) => a.gravidade == g).length;
    return [
      SecaoRelatorio('Resumo por gravidade', const ['Gravidade', 'Quantidade'], [
        for (final g in Gravidade.values) [g.rotulo, conta(g)],
        ['Total', lista.length],
      ], proporcoes: const [3, 2]),
      SecaoRelatorio(
          'Ocorrências',
          const ['Data', 'Linha', 'Tipo', 'Descrição', 'Gravidade', 'Status'],
          [
            for (final a in lista)
              [
                fmtDiaMes(a.data),
                _linhaTexto(a.linha),
                a.tipo,
                a.descricao,
                a.gravidade.rotulo,
                a.status.rotulo,
              ],
          ],
          proporcoes: const [1, 2.2, 2.2, 4, 1.4, 1.5]),
    ];
  }
}
