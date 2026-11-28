import 'package:flutter/material.dart';
import '../models/relatorio.dart';
import '../services/arquivos/salvar_arquivo.dart';
import '../services/dados_service.dart';
import '../services/formatadores.dart';
import '../services/mock_relatorios.dart';
import '../services/relatorio_exportador.dart';
import '../services/relatorio_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/tabela.dart';

class RelatoriosGerenciaisPage extends StatefulWidget {
  const RelatoriosGerenciaisPage({super.key});

  @override
  State<RelatoriosGerenciaisPage> createState() => _RelatoriosGerenciaisPageState();
}

class _RelatoriosGerenciaisPageState extends State<RelatoriosGerenciaisPage> {
  String _tipo = MockRelatorios.tipos.first.nome;
  String _periodo = DadosService.agosto.rotulo;
  String _formato = MockRelatorios.formatos.first;
  bool _gerando = false;
  final List<Relatorio> _recentes = [];

  void _mensagem(String texto, {String? caminho}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 6),
      content: Text(texto),
      action: caminho == null
          ? null
          : SnackBarAction(label: 'Mostrar', onPressed: () => mostrarNaPasta(caminho)),
    ));
  }

  /// Gera o arquivo no formato escolhido, baixa e guarda na lista de recentes.
  Future<void> _gerar() async {
    if (_gerando) return;
    setState(() => _gerando = true);
    try {
      final agora = DateTime.now();
      final conteudo = RelatorioService.montar(
        tipo: _tipo,
        dados: DadosService.porRotulo(_periodo),
        geradoEm: fmtDataHora(agora),
      );
      final bytes = await RelatorioExportador.exportar(conteudo, _formato);
      final nomeArquivo =
          'relatorio_${slug(_tipo)}_${slug(_periodo)}_${fmtCarimbo(agora)}.${RelatorioExportador.extensao(_formato)}';
      final mime = RelatorioExportador.mime(_formato);

      final destino = await salvarArquivo(nome: nomeArquivo, bytes: bytes, mime: mime);
      if (!mounted) return;
      setState(() {
        _recentes.insert(
          0,
          Relatorio(
            nome: _tipo,
            periodo: _periodo,
            geradoEm: fmtDataHora(agora),
            formato: _formato,
            status: 'Concluído',
            bytes: bytes,
            nomeArquivo: nomeArquivo,
            mime: mime,
          ),
        );
      });
      _mensagem(destino == null ? 'Download iniciado: $nomeArquivo' : 'Salvo em: $destino',
          caminho: destino);
    } catch (e) {
      _mensagem('Não foi possível gerar o relatório: $e');
    } finally {
      if (mounted) setState(() => _gerando = false);
    }
  }

  Future<void> _baixarNovamente(Relatorio r) async {
    try {
      final destino = await salvarArquivo(nome: r.nomeArquivo, bytes: r.bytes, mime: r.mime);
      _mensagem(destino == null ? 'Download iniciado: ${r.nomeArquivo}' : 'Salvo em: $destino',
          caminho: destino);
    } catch (e) {
      _mensagem('Não foi possível baixar o arquivo: $e');
    }
  }

  Widget _dropdown(String rotulo, String valor, List<String> itens, ValueChanged<String> aoMudar) {
    return DropdownButtonFormField<String>(
      key: ValueKey('$rotulo-$valor'),
      initialValue: valor,
      isExpanded: true,
      decoration: InputDecoration(
          labelText: rotulo, border: const OutlineInputBorder(), isDense: true),
      items: [for (final i in itens) DropdownMenuItem(value: i, child: Text(i))],
      onChanged: (v) {
        if (v != null) aoMudar(v);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Relatórios Gerenciais',
      subtitle: 'Gere relatórios em PDF, Excel ou CSV e baixe na hora',
      children: [
        SplitRow(
          mainFlex: 1,
          sideFlex: 1,
          main: SectionCard(
            title: 'Criar novo relatório',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _dropdown('Tipo de relatório', _tipo, [for (final t in MockRelatorios.tipos) t.nome],
                  (v) => setState(() => _tipo = v)),
              const SizedBox(height: 14),
              _dropdown('Período', _periodo, MockRelatorios.periodos,
                  (v) => setState(() => _periodo = v)),
              const SizedBox(height: 14),
              Text('Formato do arquivo',
                  style: TextStyle(fontSize: 12, color: context.cores.muted)),
              const SizedBox(height: 6),
              SegmentedButton<String>(
                segments: [
                  for (final f in MockRelatorios.formatos)
                    ButtonSegment<String>(value: f, label: Text(f)),
                ],
                selected: {_formato},
                onSelectionChanged: (s) => setState(() => _formato = s.first),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton.icon(
                  key: const Key('botao-gerar-relatorio'),
                  onPressed: _gerando ? null : _gerar,
                  icon: _gerando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.download_outlined),
                  label: Text(_gerando ? 'Gerando...' : 'Gerar e baixar relatório'),
                ),
              ),
            ]),
          ),
          side: SectionCard(
            title: 'Tipos disponíveis',
            child: Column(children: [
              for (final t in MockRelatorios.tipos)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: t.nome == _tipo
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: t.nome == _tipo ? AppColors.primary : context.cores.border),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() => _tipo = t.nome),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(t.nome,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(t.descricao,
                            style: TextStyle(fontSize: 11, color: context.cores.muted)),
                      ]),
                    ),
                  ),
                ),
            ]),
          ),
        ),
        SectionCard(
          title: 'Relatórios recentes',
          child: TabelaCheia(
            vazio: 'Nenhum relatório gerado ainda. Gere o primeiro acima.',
            colunas: const [
              TabCol('Nome', flex: 4, largMin: 160),
              TabCol('Período', flex: 4, largMin: 170),
              TabCol('Gerado em', flex: 3, largMin: 130),
              TabCol('Formato', flex: 2, largMin: 80),
              TabCol('Status', flex: 2, largMin: 100),
              TabCol('', flex: 1, direita: true, largMin: 56),
            ],
            linhas: [
              for (final r in _recentes)
                [
                  Text(r.nome),
                  Text(r.periodo),
                  Text(r.geradoEm),
                  Text(r.formato),
                  Pilula(r.status, AppColors.green),
                  IconButton(
                    tooltip: 'Baixar novamente',
                    icon: const Icon(Icons.download_outlined, size: 20),
                    onPressed: () => _baixarNovamente(r),
                  ),
                ],
            ],
          ),
        ),
      ],
    );
  }
}
