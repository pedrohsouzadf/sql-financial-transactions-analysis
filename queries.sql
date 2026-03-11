-- Qual o valor médio transacionado por cliente?
SELECT AVG(CAST(REPLACE(amount, '$', '') AS DECIMAL(10,2))) as media, t.client_id 
FROM transacoes t 
GROUP BY client_id 
ORDER BY media DESC
LIMIT 10


-- Quais clientes movimentam mais dinheiro?
SELECT SUM(CAST(REPLACE(amount,'$', '') AS DECIMAL(10,2))) as soma, t.client_id
FROM transacoes t 
GROUP BY client_id 
ORDER BY soma DESC;
LIMIT 10

-- Quais transações parecem suspeitas?
WITH base AS (
    SELECT 
        t.id,
        t.client_id,
        t.card_id,
        t.merchant_state,
        t.date,
        CAST(t.amount AS FLOAT) AS amount,
        c.card_on_dark_web,
        AVG (CAST(REPLACE(amount ,'$', '') AS FLOAT)) OVER (
            PARTITION BY t.client_id
        ) AS avg_client_amount,
        LAG(t.date) OVER (
            PARTITION BY t.client_id 
            ORDER BY t.date
        ) AS prev_transaction
    FROM transacoes t
    JOIN cartoes c 
        ON t.card_id = c.id
),

estado_padrao AS (
    SELECT
        client_id,
        merchant_state,
        COUNT(*) AS qtd,
        RANK() OVER (
            PARTITION BY client_id 
            ORDER BY COUNT(*) DESC
        ) AS rnk
    FROM transacoes
    GROUP BY client_id, merchant_state
),

estado_client AS (
    SELECT
        client_id,
        merchant_state
    FROM estado_padrao
    WHERE rnk = 1
),

regras AS (
    SELECT 
        b.*,
        
        CASE
            WHEN b.amount > b.avg_client_amount * 3 THEN 2
            ELSE 0
        END AS rule_amount,
        
        CASE
            WHEN b.merchant_state <> e.merchant_state THEN 1
            ELSE 0
        END AS rule_state,
        
        CASE
            WHEN CAST(strftime('%H', b.date) AS INTEGER) BETWEEN 0 AND 5 THEN 1
            ELSE 0
        END AS rule_hour,
        
        CASE
            WHEN b.card_on_dark_web = 'Yes' THEN 2
            ELSE 0
        END AS rule_darkweb,
        
        CASE
            WHEN b.prev_transaction IS NOT NULL
             AND julianday(b.date) - julianday(b.prev_transaction) < (1.0 / 24 / 60)
            THEN 1
            ELSE 0
        END AS rule_frequency
        
    FROM base b
    LEFT JOIN estado_client e
        ON b.client_id = e.client_id
)


SELECT 
    *,
    (rule_amount + rule_state + rule_hour + rule_darkweb + rule_frequency) AS fraud_score,
    
    CASE
        WHEN (rule_amount + rule_state + rule_hour + rule_darkweb + rule_frequency) >= 3
        THEN 'suspeita'
        ELSE 'normal'
    END AS status
    
FROM regras
ORDER BY status ASC;
)


-- Em quais dias ou horários há pico de movimentação?

WITH movimento_dia AS(
	SELECT 
		DATE(date) AS dia,
		COUNT (*) AS qtd_transacoes
	FROM transacoes
	GROUP BY DATE(date)
)

SELECT 
	dia,
	qtd_transacoes,
	AVG(qtd_transacoes) OVER () AS media,
	
	CASE
		WHEN qtd_transacoes > AVG(qtd_transacoes) OVER () 
		THEN 'pico'
		ELSE 'normal'
	END AS status
FROM movimento_dia
ORDER BY qtd_transacoes DESC;

-- Quais clientes tiveram comportamento fora do padrão?
WITH base AS(
	SELECT
		client_id,
		id AS transaction_id,
		CAST (amount AS FLOAT) AS amount,
		AVG (CAST(REPLACE(amount ,'$', '') AS FLOAT)) OVER (PARTITION BY client_id) AS avg_cliente
	FROM transacoes
)

SELECT
	client_id,
	transaction_id,
	amount,
	avg_cliente
FROM base
WHERE amount > avg_cliente * 3
ORDER BY amount DESC;


-- Existe concentração de movimentação em poucos clientes?

SELECT 
	client_id,
	SUM(CAST(REPLACE(amount ,'$', '') AS FLOAT)) as total_gasto
FROM transacoes t 
GROUP BY client_id 
ORDER BY total_gasto DESC;


-- Qual tipo de transação é mais frequente?

SELECT 
	mcc,
	COUNT (*) AS qtd_transacoes,
	SUM(CAST(REPLACE(amount ,'$', '') AS FLOAT)) as total_gasto
FROM transacoes t 
GROUP BY mcc
ORDER BY qtd_transacoes DESC;	

-- Houve aumento repentino de movimentação em algum período?

WITH movimento_dia AS (
    SELECT
        DATE(date) AS dia,
        SUM(CAST(REPLACE(amount ,'$', '') AS FLOAT)) AS total_movimentado
    FROM transacoes
    GROUP BY DATE(date)
)

SELECT
    dia,
    total_movimentado,
    LAG(total_movimentado) 
        OVER(ORDER BY dia) AS dia_anterior,

    total_movimentado -
    LAG(total_movimentado) 
        OVER(ORDER BY dia) AS diferenca

FROM movimento_dia
ORDER BY diferenca DESC;



