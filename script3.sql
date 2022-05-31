CREATE TABLE tb_teste_trigger(
    cod_teste_trigger SERIAL PRIMARY KEY,
    texto VARCHAR(200)
);

CREATE OR REPLACE FUNCTION fn_antes_de_um_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Estamos no trigger BEFORE';
    RAISE NOTICE 'OLD: %', OLD;
    RAISE NOTICE 'NEW: %', NEW;
    RAISE NOTICE 'OLD.texto: %', OLD.texto;
    RAISE NOTICE 'NEW.texto: %', NEW.texto;
    RAISE NOTICE 'TG_NAME: %', TG_NAME;
    RAISE NOTICE 'TG_LEVEL: %', TG_LEVEL;
    RAISE NOTICE 'TG_WHEN: %', TG_WHEN;
    --TG_NARGS TG_ARGV
    FOR i IN 0..TG_NARGS - 1 LOOP
        RAISE NOTICE 'TG_ARGV[%]: %', i, TG_ARGV[i];
    END LOOP;
    --mais sobre isso em breve
    RETURN NEW;
END;
$$

CREATE OR REPLACE TRIGGER tg_antes_do_insert
BEFORE INSERT OR UPDATE ON tb_teste_trigger
FOR EACH ROW
EXECUTE FUNCTION fn_antes_de_um_insert('Antes: V1', 'Antes: V2');

INSERT INTO tb_teste_trigger 
(texto)
VALUES
('testando trigger...');

CREATE OR REPLACE FUNCTION fn_depois_de_um_insert()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    RAISE NOTICE 'Estamos no trigger AFTER';
    RAISE NOTICE 'OLD: %', OLD;
    RAISE NOTICE 'NEW: %', NEW;
    RAISE NOTICE 'OLD.texto: %', OLD.texto;
    RAISE NOTICE 'NEW.texto: %', NEW.texto;
    RAISE NOTICE 'TG_NAME: %', TG_NAME;
    RAISE NOTICE 'TG_LEVEL: %', TG_LEVEL;
    RAISE NOTICE 'TG_WHEN: %', TG_WHEN;
    --TG_NARGS TG_ARGV
    FOR i IN 0..TG_NARGS - 1 LOOP
        RAISE NOTICE 'TG_ARGV[%]: %', i, TG_ARGV[i];
    END LOOP;
    --mais sobre isso em breve
    RETURN NEW;
    
END;
$$

CREATE OR REPLACE TRIGGER tg_depois_do_insert
AFTER INSERT OR UPDATE ON tb_teste_trigger
FOR ROW
EXECUTE PROCEDURE fn_depois_de_um_insert(
'Depois: V1', 'Depois: V2', 'Depois: V3'
);

INSERT INTO tb_teste_trigger
(texto)
VALUES
('Testando trigger mais uma vez');

CREATE OR REPLACE TRIGGER tg_antes_do_insert2
BEFORE INSERT ON tb_teste_trigger
FOR EACH STATEMENT
EXECUTE FUNCTION fn_antes_de_um_insert();

CREATE OR REPLACE TRIGGER tg_depois_do_insert2
AFTER INSERT ON tb_teste_trigger
FOR STATEMENT
EXECUTE PROCEDURE fn_depois_de_um_insert();

INSERT INTO tb_teste_trigger
(texto)
VALUES
('Testando mais uma vez');

DELETE FROM tb_teste_trigger;
SELECT * FROM tb_teste_trigger_cod_teste_trigger_seq;

ALTER SEQUENCE tb_teste_trigger_cod_teste_trigger_seq
RESTART WITH 1;

DROP TRIGGER IF EXISTS tg_antes_do_insert2 ON tb_teste_trigger;

DROP TRIGGER IF EXISTS tg_depois_do_insert2 ON
tb_teste_trigger;

INSERT INTO tb_teste_trigger
(texto)
VALUES
('Mais um texto');

SELECT * FROM tb_teste_trigger;

UPDATE tb_teste_trigger SET texto='atualizado';














