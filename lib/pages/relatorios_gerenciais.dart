import 'package:flutter/material.dart';
import '../models/relatorio.dart';
import '../services/formatadores.dart';
import '../services/mock_relatorios.dart';
import '../widgets/app_theme.dart';
import '../widgets/common.dart';

class RelatoriosGerenciaisPage extends StatefulWidget {
  const RelatoriosGerenciaisPage({super.key});

  @override
  State<RelatoriosGerenciaisPage> createState() => _RelatoriosGerenciaisPageState();
}

class _RelatoriosGerenciaisPageState extends State<RelatoriosGerenciaisPage> {
  String _tipo = MockRelatorios.tipos.first.nome;
  String _periodo = MockRelatorios.periodos[1];
  String _formato = MockRelatorios.formatos.first;
  late final List<Relatorio> _recentes = List.of(MockRelatorios.recentes);

  // SIMULAÇÃO: só adiciona na lista. A geração real do arquivo (PDF/Excel/CSV)
  // depende do back-end ou de um pacote de exportação.
  void _gerar() {
    setState(() {
      _recentes.insert(
        0,
        Relatorio(
          nome: _tipo,
          periodo: _periodo,
          geradoEm: fmtDataHora(DateTime.now()),
          formato: _formato,
          status: 'Concluído',
        ),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Relatório "$_tipo" ($_periodo, $_formato) adicionado aos recentes.')),
    );
  }

  Widget _dropdown(String label, String valor, List<String> itens, ValueChanged<String> aoMudar) {
    return DropdownButtonFormField<String>(
      key: ValueKey('$label-$valor'),
      initialValue: valor,
      isExpanded: true,
      decoration: InputDecoration(
          labelText: label, border: const OutlineInputBorder(), isDense: true),
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
      subtitle: 'Geração e acompanhamento de relatórios',
      children: [
        SplitRow(
          main: SectionCard(
            title: 'Criar novo relatório',
            child: Column(children: [
              _dropdown('Tipo de relatório', _tipo,
                  [for (final t in MockRelatorios.tipos) t.nome],
                  (v) => setState(() => _tipo = v)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _dropdown('Período', _periodo, MockRelatorios.periodos,
                        (v) => setState(() => _periodo = v))),
                const SizedBox(width: 12),
                Expanded(
                    child: _dropdown('Formato', _formato, MockRelatorios.formatos,
                        (v) => setState(() => _formato = v))),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                    onPressed: _gerar, child: const Text('Gerar relatório')),
              ),
            ]),
          ),
          side: SectionCard(
            title: 'Tipos disponíveis',
            child: Column(children: [
              for (final t in MockRelatorios.tipos)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: t.nome == _tipo
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: t.nome == _tipo ? AppColors.primary : AppColors.border),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() => _tipo = t.nome),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(t.nome,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(t.descricao,
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.muted)),
                        ]),
                      ),
                    ),
                  ),
                ),
            ]),
          ),
        ),
        SectionCard(
          title: 'Relatórios recentes',
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 36,
              columnSpacing: 28,
              columns: const [
                DataColumn(label: Text('Nome')),
                DataColumn(label: Text('Período')),
                DataColumn(label: Text('Gerado em')),
                DataColumn(label: Text('Formato')),
                DataColumn(label: Text('Status')),
              ],
              rows: [
                for (final r in _recentes)
                  DataRow(cells: [
                    DataCell(Text(r.nome)),
                    DataCell(Text(r.periodo)),
                    DataCell(Text(r.geradoEm)),
                    DataCell(Text(r.formato)),
                    DataCell(Text(r.status,
                        style: const TextStyle(
                            color: AppColors.green, fontWeight: FontWeight.w600))),
                  ]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
