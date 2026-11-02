# front_semob-scs
Front-end Flutter do SEMOB-SCS (dashboards de transporte municipal).

## Como rodar

```bash
flutter pub get
flutter run -d chrome
```

Por padrão, a interface usa a base demonstrativa já extraída dos relatórios. Para preparar a execução integrada com o backend:

```bash
flutter run -d chrome \
  --dart-define=SEMOB_API_URL=http://localhost:8000/api/v1 \
  --dart-define=SEMOB_USE_MOCKS=false
```

A origem ativa aparece no menu e no topo do dashboard, evitando que dados simulados sejam confundidos com dados online. A configuração da URL já está centralizada em `lib/services/api_config.dart`; a troca efetiva dos services mock por chamadas HTTP é a próxima etapa de integração.

## Estrutura da lib

```
lib/
 ├─ main.dart                       app + troca de páginas pela navbar
 ├─ models/
 │   ├─ linha_resumo.dart           linha, km e viagens
 │   ├─ faixa_fcv.dart              faixa horária: programadas x realizadas
 │   ├─ alerta.dart                 ocorrência (gravidade e status)
 │   └─ relatorio.dart              relatório e tipos de relatório
 ├─ services/
 │   ├─ mock_data.dart              dados de exemplo (Dashboard e Frota)
 │   ├─ mock_alertas.dart           dados brutos dos alertas
 │   ├─ alertas_service.dart        regras que geram as ocorrências
 │   ├─ api_config.dart              URL da API e modo mock via dart-define
 │   ├─ mock_relatorios.dart        tipos e relatórios de exemplo
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
     ├─ indicadores_financeiros.dart
     ├─ alertas_operacionais.dart
     ├─ relatorios_gerenciais.dart
     └─ configuracoes.dart
```

Dependência dos gráficos: `fl_chart`.
