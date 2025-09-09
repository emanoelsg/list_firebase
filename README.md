# 📋 Gerenciador de Atividades Diárias

> Aplicativo Flutter para gerenciamento de tarefas diárias, com autenticação de usuários, notificações personalizadas e integração com Firebase.

> Aplicativo de gerenciamento de tarefas com notificações e autenticação, desenvolvido em Flutter com integração Firebase.
[![codecov](https://codecov.io/gh/emanoelsg/list_firebase/graph/badge.svg?token=OH5YR7MGM0)](https://codecov.io/gh/emanoelsg/list_firebase)
---

## 🛠 Tecnologias Utilizadas

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat&logo=firebase&logoColor=white)
![GetX](https://img.shields.io/badge/GetX-FF5722?style=flat&logoColor=white)
![CI](https://img.shields.io/badge/CI-CD-blue)

- **Flutter & Dart** – Desenvolvimento multiplataforma com performance nativa.  
- **GetX** – Gerenciamento de estado reativo e navegação simplificada.  
- **Firebase Auth & Firestore** – Autenticação segura e banco de dados em tempo real.  
- **Notificações Locais** – Agendamento de lembretes e alertas para tarefas.  
- **Testes Unitários** – `flutter_test`, `mocktail` e `fake_firestore` para garantir confiabilidade.  

---

## ⚡ Funcionalidades Principais

- **Cadastro e Login de Usuário**  
  Autenticação via email e senha com Firebase Auth.  

- **CRUD de Tarefas**  
  Criar, atualizar, deletar e listar tarefas associadas a cada usuário.  

- **Lembretes e Notificações**  
  Configuração de alertas para tarefas com horário específico e repetição opcional.  

- **UI Reativa**  
  A interface atualiza automaticamente quando dados são alterados, usando GetX.

---

## 🧪 Cobertura de Testes

O projeto possui testes unitários completos, incluindo:

- **AuthController & AuthRepository**  
  - Cadastro, login e logout  
  - Tratamento de erros e exceções  

- **TaskController & TaskRepository**  
  - Operações de CRUD de tarefas  
  - Cancelamento e atualização de notificações  

- **TaskEntity**  
  - Métodos `toMap` e `fromMap`  
  - Suporte ao `copyWith`  

- **NotificationController**  
  - Verificação de agendamento e cancelamento de lembretes  

💡 Os testes garantem confiabilidade, facilitam manutenção e permitem evolução segura do app.

---

## 🚀 Estrutura do Projeto

- **data/** – Implementação dos repositórios e integração com Firebase.  
- **domain/** – Entidades e interfaces, abstraindo regras de negócio.  
- **presentation/** – Controllers, páginas e widgets (UI reativa via GetX).  
- **service/** – Serviços externos, como notificações e integração com APIs.  

---

## 🎯 Diferenciais do Projeto

- Arquitetura modular, limpa e escalável (**Clean Architecture**).  
- Código totalmente testável, com alta cobertura de testes unitários.  
- Integração real com Firebase e notificações locais.  
- Facilita futuras implementações e manutenção do código.  

---

## 📌 Em Desenvolvimento

- Implementação de **CI/CD** para builds automáticos e deploys.  
- Suporte a notificações recorrentes avançadas e integração com calendário.  
- Melhorias na experiência do usuário e interface.

---

## 📦 Como Rodar

```bash
# Clonar repositório
git clone <REPO_URL>

# Instalar dependências
flutter pub get

# Rodar aplicativo
flutter run

```
[📲 Baixar Lista de Tarefas v1.0](https://github.com/emanoelsg/list_firebase/releases/latest/download/app-release.apk)

