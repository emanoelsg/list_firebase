# 📋 Gerenciador de Atividades Diárias


![Coverage](https://codecov.io/gh/emanoelsg/list_firebase/graph/badge.svg?token=OH5YR7MGM0)
![Build](https://github.com/emanoelsg/list_firebase/workflows/Flutter%20CI/badge.svg)

> Sistema completo de gerenciamento de tarefas com autenticação Firebase e notificações locais.


## 🛠 Tecnologias Utilizadas

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat&logo=firebase&logoColor=white)
![GetX](https://img.shields.io/badge/GetX-FF5722?style=flat&logoColor=white)
![CI](https://img.shields.io/badge/CI-CD-blue)

- **Frontend:** Flutter 3.9.0, GetX, Material Design
- **Backend:** Firebase (Auth, Firestore, Storage)
- **Testes:** Mocktail, Flutter Test
- **CI/CD:** GitHub Actions, CodeCov
- **GetX**  Gerenciamento de estado reativo 
- **Notificações Locais** Agendamento de lembretes e alertas para tarefas.  
- **Testes Unitários** `flutter_test`, `mocktail` e `fake_firestore` para garantir confiabilidade.  

---

## 🚀 Recursos

- ✅ Autenticação segura com Firebase
- ✅ CRUD completo de tarefas
- ✅ Notificações locais agendadas
- ✅ UI responsiva e intuitiva
- ✅ +90% de cobertura de testes

## 🧪 Testes

```bash
flutter test --coverage
```

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

## 🔄 Roadmap

- [ ] Login com Google
- [ ] Tema escuro
- [ ] Sincronização offline
- [ ] Integração com calendário

```
[📲 Baixar Lista de Tarefas v1.0](https://github.com/emanoelsg/list_firebase/releases/latest/download/app-release.apk)

