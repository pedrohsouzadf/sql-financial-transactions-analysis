# Análise de Transações Financeiras com SQL

## 📌 Objetivo

Este projeto tem como objetivo analisar uma base de dados de transações financeiras para identificar padrões de comportamento dos clientes, concentração de movimentação financeira, picos de atividade ao longo do tempo e possíveis transações suspeitas utilizando SQL.

A análise foi realizada utilizando consultas analíticas com agregações, CTEs e window functions.

# 📊 Base de Dados

O dataset contém informações sobre:

- Clientes
- Cartões
- Transações financeiras

Principais tabelas utilizadas:

### transacoes
Contém o histórico das transações realizadas.

Campos relevantes:

- `id`
- `client_id`
- `card_id`
- `amount`
- `date`
- `merchant_state`
- `mcc`

### clientes
Informações demográficas dos clientes.

### cartoes
Informações sobre os cartões utilizados nas transações.

---

# 🛠 Tecnologias Utilizadas

- SQL
- SQLite
- DBeaver

Principais recursos SQL aplicados:

- `JOIN`
- `GROUP BY`
- `CTE`
- `Window Functions`
- `LAG`
- `CASE WHEN`
- Agregações (`SUM`, `AVG`, `COUNT`)
- Regras de negócio para detecção de anomalias

---

# 🔎 Perguntas de Negócio Respondidas

O projeto buscou responder às seguintes perguntas:

1. Qual o valor médio transacionado por cliente?
2. Quais clientes movimentam mais dinheiro?
3. Quais transações parecem suspeitas?
4. Em quais dias ou horários há pico de movimentação?
5. Quais clientes tiveram comportamento fora do padrão?
6. Existe concentração de movimentação em poucos clientes?
7. Qual tipo de transação é mais frequente?
8. Houve aumento repentino de movimentação em algum período?

---

# ⚠️ Detecção de Transações Suspeitas

Foi implementado um sistema simples de **score de risco** baseado em regras heurísticas:

| Regra | Pontuação |
|------|------|
Transação acima de 3x a média do cliente | +2 |
Estado diferente do padrão do cliente | +1 |
Horário incomum (00h–05h) | +1 |
Cartão presente na dark web | +2 |
Muitas transações em sequência | +1 |

Se o **score ≥ 3**, a transação é classificada como **suspeita**.

---

# 📈 Análises Realizadas

## Ticket médio por cliente
Identificação do valor médio das transações realizadas por cada cliente.

## Clientes com maior movimentação
Ranking de clientes com maior volume financeiro movimentado.

## Detecção de anomalias
Identificação de transações com comportamento fora do padrão histórico do cliente.

## Picos de movimentação
Análise temporal para identificar períodos com maior volume de transações.

## Concentração de movimentação
Verificação se poucos clientes concentram grande parte das transações.

## Categorias mais frequentes
Análise do campo **MCC (Merchant Category Code)** para identificar setores mais frequentes nas transações.

---

# 📊 Principais Insights

- Uma pequena parcela de clientes concentra grande parte da movimentação financeira.
- A maior parte das transações e do valor gasto ocorre em um conjunto limitado de categorias de estabelecimento (MCC).
- Alguns períodos apresentam aumentos abruptos de movimentação financeira.
- Foram identificadas transações significativamente acima do padrão médio de determinados clientes.

---
