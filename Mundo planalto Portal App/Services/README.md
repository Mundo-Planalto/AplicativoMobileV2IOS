# API Services - Mundo Planalto Portal App

## Base URL
```
Definida em API_BASE_URL nos xcconfigs (Development/Production) e lida por ApiConfig
```

## Authentication
Todos os endpoints (exceto autenticação) requerem token Bearer no header:
```
Authorization: Bearer {token}
```

---

## 📋 Lista de Serviços Implementados

### 1. **AuthService** - Autenticação
**Arquivo:** `AuthService.swift`

#### Endpoints:
- `POST /login` - Login de usuário
- `POST /primeiro_acesso` - Primeiro acesso/cadastro
- `POST /logout` - Logout

#### Métodos:
```swift
func login(cpf: String, password: String) async throws -> LoginResponse
func primeiroAcesso(cpf: String, password: String, confirmPassword: String) async throws -> RegisterResponse
func logout() async throws -> LogoutResponse
```

---

### 2. **DashboardService** - Dashboard
**Arquivo:** `DashboardService.swift`

#### Endpoints:
- `GET /dashboard` - Dados completos do dashboard
- `GET /dashboard/financial-overview` - Visão financeira
- `GET /dashboard/notices` - Avisos/notícias recentes

#### Métodos:
```swift
func getDashboardData() async throws -> DashboardResponse
func getFinancialOverview() async throws -> FinancialOverview
func getRecentNotices() async throws -> [Notice]
```

---

### 3. **EmpreendimentosService** - Empreendimentos
**Arquivo:** `EmpreendimentosService.swift`

#### Endpoints:
- `GET /empreendimentos` - Lista de empreendimentos
- `GET /empreendimentos/{id}` - Detalhes de empreendimento

#### Métodos:
```swift
func getEmpreendimentos() async throws -> EmpreendimentosResponse
func getEmpreendimentoDetail(id: String) async throws -> EmpreendimentoDetailResponse
```

---

### 4. **ProfileService** - Perfil do Usuário
**Arquivo:** `ProfileService.swift`

#### Endpoints:
- `GET /profile` - Dados do perfil
- `PUT /profile` - Atualizar perfil
- `POST /profile/change-password` - Alterar senha

#### Métodos:
```swift
func getProfile() async throws -> ProfileResponse
func updateProfile(updates: UpdateProfileRequest) async throws -> UpdateProfileResponse
func changePassword(currentPassword: String, newPassword: String, confirmPassword: String) async throws -> UpdateProfileResponse
```

---

### 5. **ExtratoService** - Extrato Financeiro
**Arquivo:** `ExtratoService.swift`

#### Endpoints:
- `GET /extrato` - Lista de transações
- `POST /extrato/pdf` - Gerar PDF do extrato
- `GET /informe_rendimentos/{year}` - Informe de rendimentos

#### Métodos:
```swift
func getExtrato(page: Int, limit: Int, startDate: String?, endDate: String?) async throws -> ExtratoResponse
func generateExtratoPDF(startDate: String?, endDate: String?) async throws -> PDFExtratoResponse
func getInformeRendimentos(year: String) async throws -> PDFExtratoResponse
```

---

### 6. **NewsService** - Notícias e Avisos
**Arquivo:** `NewsService.swift`

#### Endpoints:
- `GET /news` - Lista de notícias
- `GET /news/{id}` - Detalhes da notícia
- `POST /news/{id}/read` - Marcar como lida
- `GET /news/categories` - Categorias disponíveis

#### Métodos:
```swift
func getNews(page: Int, limit: Int, category: String?, featured: Bool?) async throws -> NewsResponse
func getNewsDetail(id: String) async throws -> NewsDetailResponse
func markAsRead(id: String) async throws -> MarkAsReadResponse
func getCategories() async throws -> [String]
```

---

### 7. **AIService** - Inteligência Artificial / Chat
**Arquivo:** `AIService.swift`

#### Endpoints:
- `POST /ai/chat` - Enviar mensagem
- `GET /ai/chat/history` - Histórico do chat
- `DELETE /ai/chat/clear` - Limpar histórico
- `GET /ai/capabilities` - Capacidades da IA
- `GET /ai/suggestions` - Sugestões rápidas

#### Métodos:
```swift
func sendMessage(message: String, context: String?) async throws -> ChatResponse
func getChatHistory(limit: Int, offset: Int) async throws -> ChatHistoryResponse
func clearChatHistory() async throws -> ChatResponse
func getCapabilities() async throws -> AICapabilitiesResponse
func getQuickSuggestions() async throws -> [String]
```

---


## 🔄 Tratamento de Erros

Todos os serviços usam enums de erro padronizados:

- `AuthError`, `DashboardError`, `EmpreendimentosError`, etc.
- Tipos de erro comuns:
  - `.invalidCredentials` - Token inválido/expirado (401)
  - `.networkError` - Problemas de conectividade
  - `.invalidResponse` - Resposta inesperada da API

---

## 📊 Modelos de Dados

### Principais structs implementadas:
- `LoginRequest/Response`
- `RegisterRequest/Response`
- `DashboardResponse`, `FinancialOverview`
- `Venture`, `EmpreendimentoDetail`
- `UserProfile`, `UpdateProfileRequest`
- `ExtratoItem`, `TransactionType`
- `NewsItem`, `NewsResponse`
- `ChatMessage`, `MessageRole`
- `PDFDocument`, `PDFListResponse`

---

## 🔐 Gerenciamento de Tokens

O `PreferencesManager` gerencia automaticamente:
- Salvamento de tokens após login
- Inclusão de tokens em headers de requisição
- Validação de sessão
- Limpeza de dados no logout

---

## 🚀 Próximos Passos

1. **Integração nos ViewModels**: Atualizar os ViewModels para usar os novos serviços
2. **Tratamento de Erros**: Implementar tratamento de erros nas views
3. **Cache**: Implementar cache local para dados frequentes
4. **Retry Logic**: Implementar lógica de retry para falhas de rede
5. **Loading States**: Melhorar estados de loading durante requisições

---

## 📝 Notas de Implementação

- Todos os serviços seguem o padrão Singleton
- URLs são construídas dinamicamente a partir da base URL
- Autenticação Bearer é incluída automaticamente quando token existe
- Tratamento assíncrono com async/await
- JSON encoding/decoding automático
- Tratamento padronizado de códigos HTTP (200, 401, 404, etc.)