DROP TABLE IF EXISTS tb_pessoa;
CREATE TABLE IF NOT EXISTS tb_pessoa(
    cod_pessoa SERIAL PRIMARY KEY,
    nome VARCHAR(200) NOT NULL,
    idade INT NOT NULL,
    saldo NUMERIC(10, 2) NOT NULL
);

DROP TABLE IF EXISTS tb_auditoria;
CREATE TABLE IF NOT EXISTS tb_auditoria(
    cod_auditoria SERIAL PRIMARY KEY,
    cod_pessoa INT NOT NULL,
    nome VARCHAR(200),
    idade INT,
    saldo_antigo NUMERIC (10, 2),
    saldo_atual NUMERIC(10, 2),
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

SELECT * FROM tb_pessoa_cod_pessoa_seq;

CREATE OR REPLACE FUNCTION fn_validador_de_saldo()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.saldo >= 0 THEN
        RETURN NEW;
    ELSE
        RAISE NOTICE 'Valor de saldor R$% inválido', NEW.saldo;
        RETURN NULL;
    END IF;
END;
$$

CREATE OR REPLACE TRIGGER tg_validador_de_saldo
BEFORE INSERT OR UPDATE ON tb_pessoa
FOR EACH ROW
EXECUTE PROCEDURE fn_validador_de_saldo()









--inserts
INSERT INTO tb_pessoa 
(nome, idade, saldo)
VALUES
('João', 20, 100),
('Pedro', 22, 100),
('Maria', 22, 400);
UPDATE tb_pessoa SET saldo = -100 WHERE cod_pessoa = 1;


SELECT * FROM tb_pessoa;
DELETE FROM tb_pessoa;
ALTER SEQUENCE tb_pessoa_cod_pessoa_seq RESTART WITH 1;
DELETE FROM tb_pessoa WHERE cod_pessoa > 3;











--select
SELECT * FROM tb_auditoria;
DELETE FROM tb_auditoria;


CREATE OR REPLACE FUNCTION fn_log_pessoa_insert()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO tb_auditoria 
    (cod_pessoa, nome, idade, saldo_antigo, saldo_atual)
    --lembre-se que é uma função para log de INSERT
    --OLD aqui é NULL
    VALUES (NEW.cod_pessoa, NEW.nome, NEW.idade, NULL, NEW.saldo);
    --vai ser ignorado, mas precisa ter
    RETURN NULL;
END;
$$

CREATE OR REPLACE TRIGGER tg_log_pessoa_insert
AFTER INSERT ON tb_pessoa
FOR EACH ROW
    EXECUTE PROCEDURE fn_log_pessoa_insert()
    
    

--função que faz log de operações update na tabela pessoa
CREATE OR REPLACE FUNCTION fn_log_pessoa_update()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN

    INSERT INTO tb_auditoria
    (cod_pessoa, nome, idade, saldo_antigo, saldo_atual)
    VALUES
    (NEW.cod_pessoa, NEW.nome, NEW.idade, OLD.saldo, NEW.saldo);
    RETURN NEW;

END;
$$

--trigger vincular a função à tabela
CREATE OR REPLACE TRIGGER tg_log_pessoa_update
AFTER UPDATE ON tb_pessoa
FOR EACH ROW
EXECUTE PROCEDURE fn_log_pessoa_update()


--testes
--todo mundo tem saldo 100
UPDATE tb_pessoa SET saldo = 100;

--saldo negativo com UPDATE
UPDATE tb_pessoa SET saldo = -100 WHERE cod_pessoa = 1;

--teste (deve ter uma entrada para cada pessoa atualizada)
SELECT * FROM tb_auditoria;

