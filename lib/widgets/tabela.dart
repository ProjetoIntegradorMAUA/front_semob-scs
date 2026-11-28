import 'package:flutter/material.dart';
import '../services/dados_service.dart';
import 'app_theme.dart';

/// Coluna de [TabelaCheia]. [flex] = proporção da largura.
class TabCol {
  final String titulo;
  final int flex;
  final bool direita; // números ficam alinhados à direita
  final double largMin; // usado só para rolar na horizontal em telas estreitas
  const TabCol(this.titulo, {this.flex = 1, this.direita = false, this.largMin = 90});
}

/// Tabela que ocupa TODA a largura do card (as colunas se distribuem).
/// Em telas estreitas (celular) ela rola na horizontal.
class TabelaCheia extends StatelessWidget {
  final List<TabCol> colunas;
  final List<List<Widget>> linhas;
  final String vazio;
  const TabelaCheia({
    super.key,
    required this.colunas,
    required this.linhas,
    this.vazio = 'Nenhum registro.',
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;

    if (linhas.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(vazio, style: TextStyle(color: cores.muted)),
      );
    }

    Widget celula(Widget filho, TabCol col) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Align(
            alignment: col.direita ? Alignment.centerRight : Alignment.centerLeft,
            child: filho,
          ),
        );

    final tabela = Table(
      columnWidths: {
        for (var i = 0; i < colunas.length; i++)
          i: FlexColumnWidth(colunas[i].flex.toDouble()),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder(horizontalInside: BorderSide(color: cores.border)),
      children: [
        TableRow(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: cores.border, width: 1.5)),
          ),
          children: [
            for (final c in colunas)
              celula(
                Text(c.titulo,
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700, color: cores.muted)),
                c,
              ),
          ],
        ),
        for (final linha in linhas)
          TableRow(children: [
            for (var i = 0; i < colunas.length; i++) celula(linha[i], colunas[i]),
          ]),
      ],
    );

    final conteudo = DefaultTextStyle.merge(
      style: TextStyle(fontSize: 13, color: cores.text),
      child: tabela,
    );

    final minLarg = colunas.fold<double>(0, (a, c) => a + c.largMin);
    final estreito = MediaQuery.sizeOf(context).width < 720;
    if (!estreito) return conteudo;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(width: minLarg, child: conteudo),
    );
  }
}

/// Célula "Linha": número em destaque e nome da linha embaixo.
/// Para ocorrências que valem para o sistema todo, mostra "Todas".
Widget celulaLinha(BuildContext context, String codigo) {
  final nome = DadosService.nomeLinha(codigo);
  if (nome.isEmpty) {
    return Text(codigo == 'Todas' ? 'Todas as linhas' : codigo,
        style: TextStyle(color: context.cores.muted));
  }
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Linha $codigo', style: const TextStyle(fontWeight: FontWeight.w600)),
      Text(nome, style: TextStyle(fontSize: 11, color: context.cores.muted)),
    ],
  );
}
