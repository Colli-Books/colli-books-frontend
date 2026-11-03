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
│   ├── main.dart             # composição do app (serviços, controllers) e AuthGate
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