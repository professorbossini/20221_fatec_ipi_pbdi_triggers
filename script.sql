DROP TABLE IF EXISTS tb_teste_trigger;
CREATE TABLE IF NOT EXISTS tb_teste_trigger(
    cod_teste_trigger SERIAL PRIMARY KEY,
    texto VARCHAR(200)
);

--esta função especifica o que o trigger vai fazer
--observe que a function é independente do momento em que o trigger vai disparar
--pode não ser uma boa ideia incluir essa informação (antes de um insert) em seu nome, portanto
CREATE OR REPLACE FUNCTION fn_antes_de_um_insert(texto VARCHAR(200)) RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    --aqui escrevemos o que o trigger deve fazer
    RAISE NOTICE '%', texto;
    --mais sobre isso adiante
    RETURN NULL;
END;
$$


--aqui associamos o trigger à tabela de interesse
CREATE OR REPLACE TRIGGER tg_antes_do_insert
-- antes de uma inserção acontecer na tabela tb_teste_trigger
BEFORE INSERT ON tb_teste_trigger
--executa apenas uma vez
FOR EACH STATEMENT
--aqui não faz diferença usar PROCEDURE OU FUNCTION
--mas não pode usar ROUTINE
EXECUTE PROCEDURE fn_antes_de_um_insert();

INSERT INTO tb_teste_trigger (texto) VALUES ('testando trigger..');

--primeiro a função
CREATE OR REPLACE FUNCTION fn_depois_de_um_insert()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    RAISE NOTICE 'Trigger foi chamado depois do INSERT!!';
    RETURN NULL;
END;
$$

--depois o vínculo da função à tabela
CREATE OR REPLACE TRIGGER tg_depois_do_insert
AFTER INSERT ON tb_teste_trigger
FOR STATEMENT
EXECUTE FUNCTION fn_depois_de_um_insert();

--inserindo
INSERT INTO tb_teste_trigger (texto) VALUES ('testando trigger..');



CREATE OR REPLACE TRIGGER tg_antes_do_insert2
BEFORE INSERT ON tb_teste_trigger
FOR EACH STATEMENT
EXECUTE PROCEDURE fn_antes_de_um_insert();


CREATE OR REPLACE TRIGGER tg_depois_do_insert2
AFTER INSERT ON tb_teste_trigger
FOR EACH STATEMENT
EXECUTE FUNCTION fn_depois_de_um_insert();

--inserindo
INSERT INTO tb_teste_trigger (texto) VALUES ('testando trigger..');

--removendo todos os dados
DELETE FROM tb_teste_trigger;
--visualizar detalhes do sequence usado na geração de valores para a tabela
SELECT * FROM tb_teste_trigger_cod_teste_trigger_seq;
--começa do 1 de novo. Use WITH n para começar de n
ALTER SEQUENCE tb_teste_trigger_cod_teste_trigger_seq RESTART WITH 1;
--removendo dois triggers
DROP TRIGGER IF EXISTS tg_antes_do_insert2 ON tb_teste_trigger;
DROP TRIGGER IF EXISTS tg_depois_do_insert2 ON tb_teste_trigger;








