# Colli Books Frontend

App **Flutter** da plataforma Colli Books, que consome a API do backend
(`colli-books-backend`, FastAPI + PostgreSQL). Cobre autenticação e primeiro
acesso por convite, o catálogo de obras com busca e filtros, o detalhe da obra,
Minha Seleção e os dados do professor, além do painel da editora
(administrador): visão geral, convite e acompanhamento de professores,
cadastro e edição de obras, temas e escolaridades.

## Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.27 ou superior (Dart 3)
- Android Studio (Android) e/ou Xcode (iOS)
- Backend do projeto em execução, que exige [Docker](https://docs.docker.com/get-docker/) 24+
  e Docker Compose v2 (veja o README do `colli-books-backend`)

Verifique com:

```bash
flutter --version
flutter doctor
docker --version
docker compose version
```

## Estrutura

```
colli-books-frontend/
├── lib/
│   ├── main.dart             # ColliBooksRoot (composição: serviços, controllers) e AuthGate
│   ├── core/                 # infraestrutura compartilhada
│   │   ├── config/           # endereço da API e timeouts (app_config.dart)
│   │   ├── network/          # ApiClient, ApiException, json_helpers, media_url
│   │   ├── session/          # refresh token (armazenamento seguro) e renovação da sessão
│   │   ├── utils/            # validadores, tipo de imagem pelos bytes, links externos
│   │   ├── theme/            # cores e tamanhos
│   │   └── widgets/          # widgets reutilizáveis
│   └── features/             # uma pasta por funcionalidade
│       ├── auth/             # login, recuperação e redefinição de senha, estado da sessão
│       ├── invites/          # primeiro acesso por convite (código ou link collibooks://convite)
│       ├── catalogo/         # obras, temas, escolaridades e Minha Seleção (admin e professor)
│       ├── admin/            # área da editora
│       ├── professor/        # área do professor
│       └── institucional/    # Sobre Nós, Termos de Uso, Política de Privacidade, Fale Conosco
├── patrol_test/              # testes E2E (Patrol), contra o backend real
├── android/
├── ios/
└── pubspec.yaml              # dependências
```

Cada feature segue a mesma divisão interna:

```
features/<nome>/
├── data/
│   ├── models/               # dados imutáveis, com fromJson
│   └── services/             # um método por endpoint da API
└── presentation/
    ├── controllers/          # estado das telas (ChangeNotifier)
    ├── screens/              # telas
    └── widgets/              # widgets da feature
```

### Arquitetura

O app é organizado **por funcionalidade** (feature-first). O que é usado por mais
de uma feature fica em `core/`; o que é comum a admin e professor (obras, temas,
escolaridades, Minha Seleção) fica na feature `catalogo/`.

| Camada | Pasta | Responsabilidade |
| --- | --- | --- |
| **Tela** | `presentation/screens` + `widgets` | Interface, validação de formulários e mensagens de erro |
| **Controller** | `presentation/controllers` | Estado de uma tela ou do app (listas, filtros, sessão), com `provider` + `ChangeNotifier` |
| **Service** | `data/services` | Um método por endpoint; monta a requisição e converte o JSON em models |
| **Model** | `data/models` | Dados imutáveis com `fromJson` |
| **Core** | `core/` | `ApiClient`, sessão, utilitários e widgets compartilhados |

A interface nunca chama a API diretamente:

```
Tela ──▶ Controller ──▶ Service ──▶ ApiClient ──HTTP──▶ Backend (FastAPI)
     ◀── notifyListeners ──┘                  ◀──JSON──┘
```

Telas de formulário simples (login, convite, temas) chamam o service direto, sem controller.

## Como executar

1. Suba o backend e prepare o banco (no repositório `colli-books-backend`):

```bash
cd ../colli-books-backend
cp .env.example .env
docker compose up --build -d
docker compose exec backend alembic upgrade head
docker compose exec backend python -m app.cli seed-admin --email admin@colli.com --name "Editora Colli"
docker compose exec backend python -m app.cli seed-demo
```

O `seed-admin` cria o administrador (a senha é pedida no terminal) e o
`seed-demo` popula o acervo de demonstração: temas, escolaridades e obras.

2. Volte para o frontend e instale as dependências:

```bash
cd ../colli-books-frontend
flutter pub get
```

3. Rode o app apontando para o backend:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

## Serviços utilizados

| Serviço | URL | Observação |
|---|---|---|
| Backend (API) | http://localhost:8000 | `GET /health` responde `{"status":"ok","database":"connected"}` |
| Swagger UI | http://localhost:8000/docs | Referência de todos os endpoints |

### Endereço da API

O endereço é definido na execução, por `--dart-define`. Use a URL **sem** o
prefixo `/api/v1` (o app o adiciona).

| Onde o app roda | `API_BASE_URL` |
|---|---|
| Emulador Android | `http://10.0.2.2:8000` |
| Simulador iOS | `http://localhost:8000` |
| Celular físico (mesma rede Wi-Fi) | `http://<IP-DA-SUA-MAQUINA>:8000` |
| Celular Android por USB | `adb reverse tcp:8000 tcp:8000` e `http://localhost:8000` |

No celular físico, o backend precisa estar acessível na rede (porta 8000 liberada
no firewall). Para não repetir o parâmetro, use um arquivo por ambiente:

```json
// env/dev.json
{ "API_BASE_URL": "http://192.168.0.10:8000" }
```

```bash
flutter run --dart-define-from-file=env/dev.json
```

Coloque `env/` no `.gitignore`: o IP muda de máquina para máquina.

## Acesso ao app

Não há cadastro público: toda conta nasce na editora.

| Perfil | Como entra | Áreas |
|---|---|---|
| **Administrador** | E-mail e senha definidos no `seed-admin` | Início, Professores, Catálogo, Perfil |
| **Professor** | Convite da editora → completa o cadastro → login | ColliBooks (catálogo), Seleção, Perfil |


## Configuração de plataforma

### HTTP em desenvolvimento

O backend local responde em HTTP; o Android e o iOS bloqueiam esse tráfego por padrão.

**Android** — `android/app/src/debug/AndroidManifest.xml` (só no debug):

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <application android:usesCleartextTraffic="true"/>
</manifest>
```

**iOS** — `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict><key>NSAllowsLocalNetworking</key><true/></dict>
```

> Em produção, use **HTTPS** e confirme que `android/app/src/main/AndroidManifest.xml`
> declara a permissão `INTERNET`.

### Deep link de convite

Para o link `collibooks://convite?token=...` abrir o app:

**Android** — dentro do `<activity>` principal, em `AndroidManifest.xml`:

```xml
<meta-data android:name="flutter_deeplinking_enabled" android:value="false" />
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="collibooks" android:host="convite" />
</intent-filter>
```

**iOS** — em `Info.plist`:

```xml
<key>FlutterDeepLinkingEnabled</key>
<false/>
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array><string>collibooks</string></array>
  </dict>
</array>
```

Para testar:

```bash
# Android
adb shell am start -a android.intent.action.VIEW -d "collibooks://convite?token=SEU_TOKEN" <applicationId>
# iOS (simulador)
xcrun simctl openurl booted "collibooks://convite?token=SEU_TOKEN"
```

## Autenticação e sessão

- O **access token** (JWT curto) fica só em memória; o **refresh token** fica no
  armazenamento seguro do sistema (Keychain no iOS, Keystore no Android).
- Quando o access token expira, o app o renova sozinho (`POST /auth/refresh`) e
  repete a requisição, sem o usuário perceber. Várias requisições simultâneas
  compartilham uma única renovação.
- Ao abrir o app, a sessão salva é restaurada sem pedir login de novo.
- **Sair** revoga o refresh token no servidor e limpa a sessão do aparelho.
- O papel do usuário (`admin` ou `teacher`) define a tela inicial.

## Endpoints consumidos

| Método | Rota | Uso no app |
|--------|------|------------|
| `POST` | `/api/v1/auth/login` | Login com e-mail e senha |
| `POST` | `/api/v1/auth/refresh` | Renovação automática da sessão |
| `POST` | `/api/v1/auth/logout` | Sair |
| `GET`  | `/api/v1/auth/me` | Restaurar a sessão ao abrir o app |
| `POST` | `/api/v1/auth/forgot-password` | "Esqueci minha senha" |
| `POST` | `/api/v1/auth/reset-password` | Redefinir a senha com o código recebido |
| `POST` | `/api/v1/invites/verify` | Conferir o convite e obter o e-mail |
| `POST` | `/api/v1/invites/accept` | Completar o cadastro e entrar |
| `POST` | `/api/v1/invites/resend` | Pedir novo convite quando o anterior expirou |
| `GET`  | `/api/v1/admin/overview` | Contadores do painel do administrador |
| `GET`  | `/api/v1/admin/teachers` | Gestão de professores (busca por nome ou e-mail) |
| `POST` | `/api/v1/admin/teachers` | Convidar professor |
| `POST` | `/api/v1/admin/teachers/{id}/invite` | Gerar novo convite para um professor |
| `GET`  | `/api/v1/books` | Catálogo com busca e filtros |
| `GET`  | `/api/v1/books/{id}` | Detalhe da obra e edição |
| `POST` | `/api/v1/books` | Cadastrar obra (multipart) |
| `PATCH` | `/api/v1/books/{id}` | Editar obra (multipart) |
| `GET`  | `/api/v1/themes` | Temas (filtros e formulário de obra) |
| `POST` | `/api/v1/themes` | Cadastrar tema |
| `PATCH` | `/api/v1/themes/{id}` | Renomear tema |
| `GET`  | `/api/v1/education-levels` | Escolaridades (filtros e formulário de obra) |
| `POST` | `/api/v1/education-levels` | Cadastrar escolaridade |
| `PATCH` | `/api/v1/education-levels/{id}` | Renomear escolaridade |
| `PATCH` | `/api/v1/me` | Editar nome e escola do professor |
| `GET`  | `/api/v1/me/saved-books` | Minha Seleção |
| `PUT`  | `/api/v1/me/saved-books/{book_id}` | Salvar obra na seleção |
| `DELETE` | `/api/v1/me/saved-books/{book_id}` | Remover obra da seleção |
| `GET`  | `/media/covers/{arquivo}` | Capas das obras |

### Upload de capas

O formulário de obra envia a capa no campo `cover` do `multipart/form-data`
(PNG ou JPEG, até 5 MB). O app confere o tipo pelos bytes do arquivo e o tamanho
antes de enviar. A obra guarda o caminho relativo em `cover_url`, e o app o
resolve contra a URL base da API.

## Build

```bash
# Android
flutter build apk --dart-define=API_BASE_URL=https://api.seudominio.com
flutter build appbundle --dart-define=API_BASE_URL=https://api.seudominio.com

# iOS
flutter build ios --dart-define=API_BASE_URL=https://api.seudominio.com
```

## Testes E2E (Patrol)

Testes de ponta a ponta com o [Patrol](https://patrol.leancode.co): o app roda de
verdade em um emulador, simulador ou aparelho, conversa com o **backend real** e o
teste usa a interface como um usuário (digita, toca e confere o que aparece). O Patrol
estende o `integration_test` do Flutter e também controla o sistema operacional, por
exemplo para abrir o link de convite `collibooks://convite`.

A estratégia é **preparar o estado pela API e testar só a interface**: o teste cria
professores, obras e temas direto na API (`E2eApi`) e só então abre o app. Isso deixa
cada teste curto e independente dos outros.

### Preparação

1. Instale o Patrol CLI e confira o ambiente:

```bash
dart pub global activate patrol_cli
patrol doctor
```

2. Declare o Patrol no `pubspec.yaml`:

```yaml
dev_dependencies:
  patrol: ^4.3.0        # confira a versão atual e o Flutter mínimo no pub.dev
  flutter_test:
    sdk: flutter

patrol:
  app_name: Colli Books
  android:
    package_name: <applicationId>
  ios:
    bundle_id: <bundle id>
```

3. Faça a configuração nativa (Android e iOS) conforme a documentação da versão do
   Patrol instalada. O `patrol doctor` indica o que ainda falta. Os testes ficam em
   `patrol_test/` (versões 3.x do Patrol usam `integration_test/`).

4. Tenha um emulador, simulador ou aparelho conectado (`flutter devices`).

### Backend de teste

Os testes criam dados (professores, obras, temas, escolaridades) com nomes únicos por
execução, e a API não tem exclusão. Por isso, use um **banco de teste recriado a cada
execução**, com o administrador do seed:

```bash
cd ../colli-books-backend
docker compose down -v            # apaga o banco
docker compose up --build -d
docker compose exec backend alembic upgrade head
docker compose exec backend python -m app.cli seed-admin --email admin@colli.com --name "Editora Colli"
```

O `seed-demo` não é necessário: os testes preparam os próprios dados.

### Variáveis

Passadas com `--dart-define`:

| Variável | Obrigatória | Descrição |
|---|---|---|
| `API_BASE_URL` | sim | Endereço da API (mesma tabela da seção "Endereço da API") |
| `E2E_ADMIN_EMAIL` | sim | E-mail do administrador criado pelo `seed-admin` |
| `E2E_ADMIN_PASSWORD` | sim | Senha do administrador |
| `E2E_EXPIRED_INVITE_TOKEN` | não | Token de um convite expirado; habilita o teste de convite expirado |
| `E2E_ACCESS_TTL_SECONDS` | não | Validade (em segundos) do access token configurada no backend de teste; habilita o teste de renovação de sessão |

Nunca grave a senha no repositório: leia-a de uma variável de ambiente do shell ou dos
*secrets* do CI.

### Como rodar

```bash
export E2E_ADMIN_PASSWORD='...'

# todos os testes (emulador Android)
patrol test \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000 \
  --dart-define=E2E_ADMIN_EMAIL=admin@colli.com \
  --dart-define=E2E_ADMIN_PASSWORD="$E2E_ADMIN_PASSWORD"

# um arquivo
patrol test --target patrol_test/auth_test.dart \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000 \
  --dart-define=E2E_ADMIN_EMAIL=admin@colli.com \
  --dart-define=E2E_ADMIN_PASSWORD="$E2E_ADMIN_PASSWORD"

# um dispositivo específico
patrol test -d <id-do-dispositivo> --dart-define=...
```

No simulador iOS, use `API_BASE_URL=http://localhost:8000`.

O teste de renovação de sessão exige o backend de teste com a validade do access token
curta (por exemplo, 10 segundos). Rode-o **sozinho**, porque o preparo de dados dos
outros testes também expiraria no meio:

```bash
patrol test --target patrol_test/sessao_test.dart \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000 \
  --dart-define=E2E_ADMIN_EMAIL=admin@colli.com \
  --dart-define=E2E_ADMIN_PASSWORD="$E2E_ADMIN_PASSWORD" \
  --dart-define=E2E_ACCESS_TTL_SECONDS=10
```

### Organização dos testes

```
patrol_test/
├── auth_test.dart          # login, sessão, recuperação e redefinição de senha
├── convites_test.dart      # convite de professor e primeiro acesso (inclui deep link)
├── busca_test.dart         # busca, filtros, detalhe da obra, perfil do professor e Minha Seleção
├── gestao_test.dart        # painel do admin: contadores, obras, temas, escolaridades e vínculos
├── navegacao_test.dart     # menu lateral e Fale Conosco
├── sessao_test.dart        # isolamento entre contas e renovação da sessão
└── support/
    ├── e2e_env.dart        # variáveis --dart-define dos testes
    ├── e2e_api.dart        # prepara dados direto na API (admin, professores, obras, temas)
    └── e2e_driver.dart     # ações e esperas de interface (única camada que usa o Patrol)
```

### Como os testes encontram os elementos

Por chaves (`ValueKey('nome_em_snake_case')`) nos widgets, ou pelo texto exibido.
Elementos de listas levam o id na chave (`book_save_12`, `theme_edit_7`). Ao criar um widget que um teste precise
tocar ou preencher, dê uma chave a ele.

### Escrevendo um teste novo

```dart
patrolTest('professor salva uma obra', ($) async {
  final api = await E2eApi.asAdmin();
  final book = await api.book();                      // dados preparados pela API
  final teacher = await api.createActiveTeacher();

  await $.launchApp();                                // app do zero, sem sessão
  await $.loginAsTeacher(teacher.email, teacher.password);

  await $.typeKey('catalog_search', book.title);
  await $.tapKey('book_save_${book.id}', scroll: true);
  await $.seeText('"${book.title}" adicionado à sua Seleção!');
});
```

Regras da suíte:

- **Prepare o estado pela API** (`E2eApi`), não pela interface.
- **Use valores únicos** (`uniq('Tema')`, `uniqEmail('prof')`, `uniqIsbn()`): o banco é compartilhado entre os testes.
- **Espere pelo resultado** (`seeText`, `seeKey`, `waitFor`): o backend é real e nada é instantâneo.
- **Todo acesso ao Patrol fica em `support/e2e_driver.dart`.** Se uma versão do Patrol mudar um nome, o ajuste é feito só nesse arquivo.

A suíte confere o fluxo pela interface. O envio da capa (seletor de arquivos do sistema)
e o toque em links externos (que abrem o navegador) são conferidos manualmente.

### Solução de problemas dos testes

| Sintoma | O que verificar |
|---|---|
| `Defina --dart-define=E2E_ADMIN_EMAIL=...` | As variáveis obrigatórias não foram passadas |
| Falha de login no preparo de dados | Credenciais do `seed-admin`, `API_BASE_URL` e backend no ar |
| "Tempo esgotado esperando elemento com chave ..." | A chave não existe na tela ou a tela não chegou a carregar |
| Execução lenta ou listas de filtro muito longas | Banco acumulado de execuções anteriores; recrie com `docker compose down -v` |
| O deep link não abre a tela de cadastro | Configuração do deep link nos arquivos nativos; no iOS o sistema pode pedir confirmação antes de abrir o app |
| Testes aparecem como pulados | Testes opcionais sem a variável de ambiente, ou marcados como pulados no código (o motivo aparece no nome) |
| `patrol doctor` aponta erros | Configuração nativa do Patrol; siga a documentação da versão instalada |

## Comandos úteis

```bash
# instalar dependências
flutter pub get

# analisar o código
flutter analyze

# formatar o código
dart format lib

# listar dispositivos e emuladores
flutter devices

# rodar em um dispositivo específico
flutter run -d <id-do-dispositivo> --dart-define-from-file=env/dev.json

# limpar o build e reinstalar as dependências
flutter clean && flutter pub get

# diagnóstico do ambiente
flutter doctor -v

# diagnóstico do Patrol (testes E2E)
patrol doctor

# rodar os testes E2E (veja a seção "Testes E2E")
patrol test --dart-define=API_BASE_URL=http://10.0.2.2:8000 \
  --dart-define=E2E_ADMIN_EMAIL=admin@colli.com \
  --dart-define=E2E_ADMIN_PASSWORD="$E2E_ADMIN_PASSWORD"

# recriar o banco do backend de teste (apaga os dados)
(cd ../colli-books-backend && docker compose down -v)

# expor a porta do backend a um celular Android ligado por USB
adb reverse tcp:8000 tcp:8000
```

## Solução de problemas

| Sintoma | O que verificar |
|---|---|
| "Não foi possível conectar ao servidor" | `API_BASE_URL` correto para onde o app roda (tabela acima); `GET /health` respondendo no navegador do próprio aparelho; liberação de HTTP em desenvolvimento (seção de plataforma) |
| Funciona no emulador, mas não no celular | `10.0.2.2` só vale no emulador Android; no celular use o IP da máquina ou o `adb reverse` |
| Abre sempre na tela de login | A sessão expirou ou foi encerrada; entre de novo |
| O link de convite abre o app, mas não o cadastro | Configuração do deep link nos arquivos nativos; o link é ignorado se já houver uma conta conectada no app |
| Build de release sem acesso à rede (Android) | Permissão `INTERNET` ausente em `android/app/src/main/AndroidManifest.xml` |