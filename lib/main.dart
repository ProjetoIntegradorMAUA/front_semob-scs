import 'package:flutter/material.dart';
import 'pages/alertas_operacionais.dart';
import 'pages/analise_passageiros.dart';
import 'pages/configuracoes.dart';
import 'pages/dashboard_geral.dart';
import 'pages/indicadores_financeiros.dart';
import 'pages/operacao_frota.dart';
import 'pages/relatorios_gerenciais.dart';
import 'widgets/app_theme.dart';
import 'widgets/navbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SEMOB-SCS',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const HomeShell(),
    );
  }
}

/// Junta a SideNavbar com a página escolhida.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _pagina = 0;

  // Índices iguais aos do navbar.dart
  Widget _conteudo() {
    switch (_pagina) {
      case 0:
        return const DashboardGeralPage();
      case 1:
        return const OperacaoFrotaPage();
      case 2:
        return const AnalisePassageirosPage();
      case 3:
        return const IndicadoresFinanceirosPage();
      case 4:
        return const AlertasOperacionaisPage();
      case 5:
        return const RelatoriosGerenciaisPage();
      case 6:
        return const ConfiguracoesPage();
      default:
        return const DashboardGeralPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;

    if (desktop) {
      return Scaffold(
        body: Row(
          children: [
            SideNavbar(
              indiceInicial: _pagina,
              onSelecionar: (i) => setState(() => _pagina = i),
            ),
            Expanded(child: _conteudo()),
          ],
        ),
      );
    }

    // Mobile: navbar vira menu lateral (hambúrguer)
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF004B93),
        foregroundColor: Colors.white,
        title: const Text('SEMOB-SCS'),
      ),
      drawer: Drawer(
        child: SideNavbar(
          indiceInicial: _pagina,
          onSelecionar: (i) {
            Navigator.pop(context);
            setState(() => _pagina = i);
          },
        ),
      ),
      body: _conteudo(),
    );
  }
}
