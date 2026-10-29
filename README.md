# front_semob-scs
Front-end Flutter do SEMOB-SCS (dashboards de transporte municipal).

## Como rodar

```bash
flutter pub get
flutter run -d chrome
```

## Estrutura da lib

```
lib/
 ├─ main.dart                       app + troca de páginas pela navbar
 ├─ models/
 │   ├─ linha_resumo.dart           linha, km e viagens
 │   └─ faixa_fcv.dart              faixa horária: programadas x realizadas
 ├─ services/
 │   ├─ mock_data.dart              dados de exemplo (Dashboard e Frota)
 │   ├─ mock_dados_mes.dart         dados de agosto/2026 (Passageiros e Financeiro)
 │   └─ formatadores.dart           formatação pt-BR e somas por semana
 ├─ widgets/
 │   ├─ navbar.dart                 menu lateral (SideNavbar)
 │   ├─ app_theme.dart              cores e tema
 │   ├─ common.dart                 cards, KPIs e grades responsivas
 │   └─ charts.dart                 gráficos (linha, barras, rosca)
 └─ pages/
     ├─ dashboard_geral.dart
     ├─ operacao_frota.dart
     ├─ analise_passageiros.dart
     └─ indicadores_financeiros.dart
```

Dependência dos gráficos: `fl_chart`.
