import '../models/dados_mes.dart';
import 'dados_meses.dart';

/// Ponto único de acesso aos dados. Hoje lê os dados gerados do ZIP;
/// quando houver API, é só trocar o miolo daqui.
class DadosService {
  static const List<DadosMes> meses = [
    DadosMeses.julho,
    DadosMeses.agosto,
    DadosMeses.setembro,
  ];

  static DadosMes get agosto => DadosMeses.agosto;

  static List<String> get rotulos => [for (final m in meses) m.rotulo];

  static DadosMes porRotulo(String rotulo) =>
      meses.firstWhere((m) => m.rotulo == rotulo, orElse: () => DadosMeses.agosto);

  /// "04" -> "Santa Paula" (vazio se não conhecer a linha).
  static String nomeLinha(String codigo) => DadosMeses.nomesLinhas[codigo] ?? '';
}
