import 'dart:convert';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/relatorio_conteudo.dart';
import 'formatadores.dart';

/// Transforma um [ConteudoRelatorio] em arquivo: PDF, Excel (.xlsx) ou CSV.
class RelatorioExportador {
  static const formatos = {
    'PDF': ('pdf', 'application/pdf'),
    'Excel': ('xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
    'CSV': ('csv', 'text/csv;charset=utf-8'),
  };

  static String extensao(String formato) => formatos[formato]!.$1;
  static String mime(String formato) => formatos[formato]!.$2;

  static Future<Uint8List> exportar(ConteudoRelatorio c, String formato) async {
    switch (formato) {
      case 'PDF':
        return _pdf(c);
      case 'Excel':
        return _xlsx(c);
      default:
        return _csv(c);
    }
  }

  // ------------------------------------------------------------------ CSV
  // Separador ";" e BOM UTF-8: o Excel em português abre com acentos certos.
  static Uint8List _csv(ConteudoRelatorio c) {
    final b = StringBuffer();
    void linha(String t) => b.write('$t\r\n');

    linha(_csvTexto('SEMOB-SCS - ${c.titulo}'));
    linha('Período;${_csvTexto(c.periodo)}');
    linha('Gerado em;${_csvTexto(c.geradoEm)}');
    for (final n in c.notas) {
      linha(_csvTexto(n));
    }
    for (final s in c.secoes) {
      linha('');
      linha(_csvTexto(s.titulo));
      linha(s.colunas.map(_csvTexto).join(';'));
      for (final l in s.linhas) {
        linha(l.map(_csvValor).join(';'));
      }
    }
    return Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(b.toString())]);
  }

  static String _csvTexto(String t) {
    if (t.contains(';') || t.contains('"') || t.contains('\n')) {
      return '"${t.replaceAll('"', '""')}"';
    }
    return t;
  }

  static String _csvValor(Object v) {
    if (v is int) return '$v';
    if (v is double) return v.toStringAsFixed(2).replaceAll('.', ',');
    return _csvTexto(v.toString());
  }

  // ---------------------------------------------------------------- Excel
  static Uint8List _xlsx(ConteudoRelatorio c) {
    final excel = Excel.createExcel();
    final padrao = excel.getDefaultSheet();

    void escreve(Sheet aba, int col, int lin, Object v, {bool negrito = false}) {
      final cel = aba.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: lin));
      cel.value = v is int
          ? IntCellValue(v)
          : v is double
              ? DoubleCellValue(v)
              : TextCellValue(v.toString());
      if (negrito) cel.cellStyle = CellStyle(bold: true);
    }

    // Aba 1: informações gerais
    const abaInfo = 'Informacoes';
    if (padrao != null) excel.rename(padrao, abaInfo);
    final info = excel[abaInfo];
    escreve(info, 0, 0, 'SEMOB-SCS - ${c.titulo}', negrito: true);
    escreve(info, 0, 1, 'Período');
    escreve(info, 1, 1, c.periodo);
    escreve(info, 0, 2, 'Gerado em');
    escreve(info, 1, 2, c.geradoEm);
    for (var i = 0; i < c.notas.length; i++) {
      escreve(info, 0, 3 + i, c.notas[i]);
    }
    info.setColumnWidth(0, 28);
    info.setColumnWidth(1, 40);

    // Uma aba por seção
    final usados = <String>{abaInfo};
    for (final s in c.secoes) {
      var nome = _nomeAba(s.titulo);
      var n = 2;
      while (usados.contains(nome)) {
        nome = '${_nomeAba(s.titulo, max: 28)} $n';
        n++;
      }
      usados.add(nome);
      final aba = excel[nome];
      escreve(aba, 0, 0, s.titulo, negrito: true);
      for (var j = 0; j < s.colunas.length; j++) {
        escreve(aba, j, 2, s.colunas[j], negrito: true);
        aba.setColumnWidth(j, j == 0 ? 30 : 22);
      }
      for (var i = 0; i < s.linhas.length; i++) {
        for (var j = 0; j < s.linhas[i].length; j++) {
          escreve(aba, j, 3 + i, s.linhas[i][j]);
        }
      }
    }

    final bytes = excel.encode();
    if (bytes == null) throw StateError('Não foi possível montar o Excel.');
    return Uint8List.fromList(bytes);
  }

  static String _nomeAba(String t, {int max = 31}) {
    final limpo = t.replaceAll(RegExp(r'[\[\]:*?/\\]'), ' ').trim();
    return limpo.length > max ? limpo.substring(0, max) : limpo;
  }

  // ------------------------------------------------------------------ PDF
  // A fonte padrão do PDF só tem caracteres Latin-1: troca símbolos fora dele.
  static String _limpar(String t) => t
      .replaceAll('·', '-')
      .replaceAll('–', '-')
      .replaceAll('—', '-')
      .replaceAll('−', '-');

  static String _pdfValor(Object v) {
    if (v is int) return fmtInt(v);
    if (v is double) return fmtDec(v);
    return _limpar(v.toString());
  }

  static Future<Uint8List> _pdf(ConteudoRelatorio c) async {
    final doc = pw.Document(title: 'SEMOB-SCS - ${_limpar(c.titulo)}', author: 'SEMOB-SCS');
    final azul = PdfColor.fromInt(0xFF0A3D91);

    pw.Widget celula(String texto, {bool cabecalho = false, bool direita = false}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        child: pw.Align(
          alignment: direita ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
          child: pw.Text(
            texto,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: cabecalho ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: cabecalho ? PdfColors.white : PdfColors.black,
            ),
          ),
        ),
      );
    }

    pw.Widget tabela(SecaoRelatorio s) {
      // colunas numéricas (pela 1ª linha) ficam alinhadas à direita
      final numericas = [
        for (var j = 0; j < s.colunas.length; j++)
          s.linhas.isNotEmpty && j < s.linhas.first.length && s.linhas.first[j] is! String
      ];
      return pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
        columnWidths: s.proporcoes == null
            ? null
            : {
                for (var j = 0; j < s.proporcoes!.length; j++)
                  j: pw.FlexColumnWidth(s.proporcoes![j]),
              },
        children: [
          pw.TableRow(
            repeat: true,
            decoration: pw.BoxDecoration(color: azul),
            children: [
              for (var j = 0; j < s.colunas.length; j++)
                celula(_limpar(s.colunas[j]), cabecalho: true, direita: numericas[j]),
            ],
          ),
          for (final l in s.linhas)
            pw.TableRow(children: [
              for (var j = 0; j < l.length; j++)
                celula(_pdfValor(l[j]), direita: numericas[j]),
            ]),
        ],
      );
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        footer: (ctx) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('Pagina ${ctx.pageNumber} de ${ctx.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
        ),
        build: (ctx) => [
          pw.Text('SEMOB-SCS',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: azul)),
          pw.SizedBox(height: 2),
          pw.Text(_limpar(c.titulo),
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text('Periodo: ${_limpar(c.periodo)}', style: const pw.TextStyle(fontSize: 10)),
          pw.Text('Gerado em: ${_limpar(c.geradoEm)}', style: const pw.TextStyle(fontSize: 10)),
          for (final n in c.notas)
            pw.Text(_limpar(n),
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          for (final s in c.secoes) ...[
            pw.SizedBox(height: 16),
            pw.Text(_limpar(s.titulo),
                style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: azul)),
            pw.SizedBox(height: 6),
            tabela(s),
          ],
        ],
      ),
    );

    return doc.save();
  }
}
