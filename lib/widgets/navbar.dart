import 'package:flutter/material.dart';
import '../services/api_config.dart';
import 'app_theme.dart';

class SideNavbar extends StatefulWidget {
  final ValueChanged<int>? onSelecionar; // avisa a tela qual página foi clicada
  final int indiceInicial;
  const SideNavbar({super.key, this.onSelecionar, this.indiceInicial = 0});

  @override
  State<SideNavbar> createState() => _SideNavbarState();
}

class _SideNavbarState extends State<SideNavbar> {
  late int _indiceAtivo = widget.indiceInicial;

  @override
  void didUpdateWidget(covariant SideNavbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.indiceInicial != widget.indiceInicial) {
      _indiceAtivo = widget.indiceInicial;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: double.infinity, // o container vai esticar e ocupar 100% da altura da tela
      decoration: const BoxDecoration( 
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF004B93),
            Color(0xFF002244),
          ],
        )
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [
                Icon(Icons.directions_bus, color: Colors.white, size: 28),
                SizedBox(width: 10),
                Text(
                  'SEMOB-SCS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]),
              const SizedBox(height: 6),
              const Padding(
                padding: EdgeInsets.only(left: 38),
                child: Text(
                  'Dashboard de Transporte',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              const SizedBox(height: 28),

              _paginas('Dashboard', Icons.dashboard_outlined, numeroDaPagina: 0),
              _paginas('Operação da Frota', Icons.alt_route, numeroDaPagina: 1),
              _paginas('Passageiros', Icons.groups_outlined, numeroDaPagina: 2),
              _paginas('Financeiro', Icons.account_balance_wallet_outlined,
                  numeroDaPagina: 3),
              _paginas('Alertas', Icons.notifications_none, numeroDaPagina: 4),
              _paginas('Relatórios', Icons.description_outlined, numeroDaPagina: 5),
              _paginas('Configurações', Icons.settings_outlined, numeroDaPagina: 6),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: Row(children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: ApiConfig.useMocks ? AppColors.orange : AppColors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ApiConfig.sourceLabel,
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paginas(String title, IconData icon, {required int numeroDaPagina}) {
    final ativo = _indiceAtivo == numeroDaPagina;

    return Semantics(
      selected: ativo,
      button: true,
      label: title,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: ativo ? const Color(0xFF0073D6) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: () {
            setState(() => _indiceAtivo = numeroDaPagina);
            widget.onSelecionar?.call(numeroDaPagina);
          },
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(children: [
              Icon(
                icon,
                size: 20,
                color: ativo ? Colors.white : Colors.white70,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: ativo ? Colors.white : Colors.white.withValues(alpha: 0.78),
                    fontSize: 14,
                    fontWeight: ativo ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
