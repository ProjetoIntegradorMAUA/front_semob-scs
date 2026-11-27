/// Salva um arquivo no computador do usuário.
///  - Web: o navegador baixa o arquivo (pasta Downloads).
///  - Desktop (Windows/macOS/Linux): grava na pasta Downloads.
/// Retorna o caminho salvo (desktop) ou null (web).
export 'salvar_arquivo_stub.dart'
    if (dart.library.js_interop) 'salvar_arquivo_web.dart'
    if (dart.library.io) 'salvar_arquivo_io.dart';
