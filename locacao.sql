-- limpa td
IF OBJECT_ID('Devolver_Filme', 'P') IS NOT NULL DROP PROCEDURE Devolver_Filme;
IF OBJECT_ID('Incluir_Locacao', 'P') IS NOT NULL DROP PROCEDURE Incluir_Locacao;
IF OBJECT_ID('Listar_Clientes_Cidade_Idade', 'P') IS NOT NULL DROP PROCEDURE Listar_Clientes_Cidade_Idade;
IF OBJECT_ID('Resumo_Aniversariantes', 'P') IS NOT NULL DROP PROCEDURE Resumo_Aniversariantes;
IF OBJECT_ID('proc_Aniversariantes_Mes', 'P') IS NOT NULL DROP PROCEDURE proc_Aniversariantes_Mes;
IF OBJECT_ID('Excluir_Cliente', 'P') IS NOT NULL DROP PROCEDURE Excluir_Cliente;
IF OBJECT_ID('Selecionar_Cliente', 'P') IS NOT NULL DROP PROCEDURE Selecionar_Cliente;
IF OBJECT_ID('Alterar_Cliente', 'P') IS NOT NULL DROP PROCEDURE Alterar_Cliente;
IF OBJECT_ID('Incluir_Cliente', 'P') IS NOT NULL DROP PROCEDURE Incluir_Cliente;

IF OBJECT_ID('LOCACOES', 'U') IS NOT NULL DROP TABLE LOCACOES;
IF OBJECT_ID('FILME', 'U') IS NOT NULL DROP TABLE FILME;
IF OBJECT_ID('CLIENTES', 'U') IS NOT NULL DROP TABLE CLIENTES;
IF OBJECT_ID('CATEGORIA', 'U') IS NOT NULL DROP TABLE CATEGORIA;

GO

-- criar as tabelas
CREATE TABLE CLIENTES (
    COD_CLIENTE NUMERIC(18,0) IDENTITY(1,1) PRIMARY KEY,
    RG VARCHAR(9) NOT NULL,
    NOME VARCHAR(50) NOT NULL,
    ENDERECO VARCHAR(50),
    BAIRRO VARCHAR(30),
    CIDADE VARCHAR(30),
    ESTADO CHAR(2) NOT NULL,
    TELEFONE VARCHAR(15),
    EMAIL VARCHAR(30),
    DATANASCIMENTO DATETIME,
    Sexo CHAR(1)
);

CREATE TABLE CATEGORIA (
    COD_CATEGORIA NUMERIC(10,0) IDENTITY(1,1) PRIMARY KEY,
    NOME_CATEGORIA VARCHAR(20) NOT NULL
);

CREATE TABLE FILME (
    COD_FILME NUMERIC(18,0) IDENTITY(1,1) PRIMARY KEY,
    FILME VARCHAR(30) NOT NULL,
    COD_CATEGORIA NUMERIC(10,0) NOT NULL,
    DIRETOR VARCHAR(50) NOT NULL,
    VALOR_LOCACAO FLOAT NOT NULL,
    RESERVADA CHAR(1) NOT NULL,
    Status VARCHAR(10) DEFAULT 'Disponível'
);

CREATE TABLE LOCACOES (
    COD_LOCACAO NUMERIC(18,0) IDENTITY(1,1) PRIMARY KEY,
    COD_CLIENTE NUMERIC(18,0) NOT NULL,
    COD_FILME NUMERIC(18,0) NOT NULL,
    DATA_LOCACAO DATETIME NOT NULL,
    DATA_EXPIRACAO DATETIME NULL,
    DATA_DEVOLUCAO DATETIME NULL
);

GO

-- dados inicais
INSERT INTO CATEGORIA VALUES ('Ação'), ('Romance'), ('Aventura'), ('Ficção'), ('Drama'), ('Terror'), ('Desenho'), ('Policial'), ('Comédia');

INSERT INTO CLIENTES VALUES ('321346530', 'Edson Martin Feitosa', 'Rua A', 'Jd. Vera Cruz', 'Sorocaba', 'SP', '32125809', 'edson@ig.com.br', '1985-04-01', 'M');
INSERT INTO CLIENTES VALUES ('421346111', 'Rafael Fernando Moraes', 'Rua B', 'Jd. Nova Esperança', 'São Roque', 'SP', '32274567', 'rafael@terra.com.br', '1985-04-01', 'M');
INSERT INTO CLIENTES VALUES ('324857670', 'João da Silva', 'Rua C', 'Av. Bartolomeu', 'Sorocaba', 'SP', '32134098', 'joao@uol.com.br', '1992-12-05', 'M');
INSERT INTO CLIENTES VALUES ('321349999', 'Renata Cristina', 'Rua E', 'Jd. Vera Cruz', 'Sorocaba', 'SP', '32125809', 'renata@gmail', '1970-09-01', 'F');

INSERT INTO FILME (FILME, COD_CATEGORIA, DIRETOR, VALOR_LOCACAO, RESERVADA) VALUES ('300', 1, 'Richard Donner', 3.5, 'n');
INSERT INTO FILME (FILME, COD_CATEGORIA, DIRETOR, VALOR_LOCACAO, RESERVADA) VALUES ('Máquina Mortífera', 1, 'Richard Donner', 3.6, 'n');
INSERT INTO FILME (FILME, COD_CATEGORIA, DIRETOR, VALOR_LOCACAO, RESERVADA) VALUES ('A Mexicana', 2, 'Burr Steers', 2, 's');

GO

-- 1 incluir cliente
CREATE PROCEDURE Incluir_Cliente 
    @RG VARCHAR(9),
    @NOME VARCHAR(50),
    @ENDERECO VARCHAR(50) = NULL,
    @BAIRRO VARCHAR(30) = NULL,
    @CIDADE VARCHAR(30) = NULL,
    @ESTADO CHAR(2),
    @TELEFONE VARCHAR(15) = NULL,
    @EMAIL VARCHAR(30) = NULL,
    @DATANASC DATETIME,
    @SEXO CHAR(1)
AS
BEGIN
    INSERT INTO CLIENTES (RG, NOME, ENDERECO, BAIRRO, CIDADE, ESTADO, TELEFONE, EMAIL, DATANASCIMENTO, Sexo)
    VALUES (@RG, @NOME, @ENDERECO, @BAIRRO, @CIDADE, @ESTADO, @TELEFONE, @EMAIL, @DATANASC, @SEXO)
    PRINT 'Cliente incluído com sucesso!'
END;
GO

-- 2 alterar cliente
CREATE PROCEDURE Alterar_Cliente
    @COD_CLIENTE NUMERIC(18,0),
    @NOME VARCHAR(50) = NULL,
    @ENDERECO VARCHAR(50) = NULL,
    @BAIRRO VARCHAR(30) = NULL,
    @CIDADE VARCHAR(30) = NULL,
    @ESTADO CHAR(2) = NULL,
    @TELEFONE VARCHAR(15) = NULL,
    @EMAIL VARCHAR(30) = NULL,
    @DATANASC DATETIME = NULL,
    @SEXO CHAR(1) = NULL
AS
BEGIN
    UPDATE CLIENTES SET
        NOME = ISNULL(@NOME, NOME),
        ENDERECO = ISNULL(@ENDERECO, ENDERECO),
        BAIRRO = ISNULL(@BAIRRO, BAIRRO),
        CIDADE = ISNULL(@CIDADE, CIDADE),
        ESTADO = ISNULL(@ESTADO, ESTADO),
        TELEFONE = ISNULL(@TELEFONE, TELEFONE),
        EMAIL = ISNULL(@EMAIL, EMAIL),
        DATANASCIMENTO = ISNULL(@DATANASC, DATANASCIMENTO),
        Sexo = ISNULL(@SEXO, Sexo)
    WHERE COD_CLIENTE = @COD_CLIENTE
    PRINT 'Cliente alterado com sucesso!'
END;
GO

-- selecionar cliente
CREATE PROCEDURE Selecionar_Cliente
    @COD_CLIENTE NUMERIC(18,0) = NULL
AS
BEGIN
    IF @COD_CLIENTE IS NULL
        SELECT * FROM CLIENTES
    ELSE
        SELECT * FROM CLIENTES WHERE COD_CLIENTE = @COD_CLIENTE
END;
GO

-- excluir cliente
CREATE PROCEDURE Excluir_Cliente
    @COD_CLIENTE NUMERIC(18,0)
AS
BEGIN
    DELETE FROM CLIENTES WHERE COD_CLIENTE = @COD_CLIENTE
    PRINT 'Cliente excluído com sucesso!'
END;
GO

-- aniversariantes por mes
CREATE PROCEDURE proc_Aniversariantes_Mes
    @MES INT
AS
BEGIN
    SELECT NOME, DAY(DATANASCIMENTO) AS DIA
    FROM CLIENTES
    WHERE MONTH(DATANASCIMENTO) = @MES
    ORDER BY DIA
END;
GO

-- resumo de aniversariantes
CREATE PROCEDURE Resumo_Aniversariantes
AS
BEGIN
    SELECT M.Mes, COUNT(C.COD_CLIENTE) AS Qtd
    FROM (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS M(Mes)
    LEFT JOIN CLIENTES C ON M.Mes = MONTH(C.DATANASCIMENTO)
    GROUP BY M.Mes
    ORDER BY M.Mes
END;
GO

--clientes por cidade e idade
CREATE PROCEDURE Listar_Clientes_Cidade_Idade
    @CIDADE VARCHAR(30),
    @IDADE_MAX INT
AS
BEGIN
    SELECT NOME AS [Nome do Cliente],
           DATANASCIMENTO AS [Data Nascimento],
           DATEDIFF(YEAR, DATANASCIMENTO, GETDATE()) AS [Idade]
    FROM CLIENTES
    WHERE CIDADE = @CIDADE AND DATEDIFF(YEAR, DATANASCIMENTO, GETDATE()) <= @IDADE_MAX
    ORDER BY NOME
END;
GO

-- incluir locação
CREATE PROCEDURE Incluir_Locacao
    @ID_CLIENTE INT,
    @ID_FILME INT
AS
BEGIN
    INSERT INTO LOCACOES (COD_CLIENTE, COD_FILME, DATA_LOCACAO)
    VALUES (@ID_CLIENTE, @ID_FILME, GETDATE());
    
    UPDATE FILME SET Status = 'Alugado' WHERE COD_FILME = @ID_FILME;
    
    PRINT 'Locação incluída com sucesso!'
END;
GO

--devolver filme
CREATE PROCEDURE Devolver_Filme
    @ID_LOCACAO INT
AS
BEGIN
    DECLARE @ID_FILME_VAR INT;
    
    SELECT @ID_FILME_VAR = COD_FILME FROM LOCACOES WHERE COD_LOCACAO = @ID_LOCACAO;
    
    UPDATE LOCACOES SET DATA_DEVOLUCAO = GETDATE() WHERE COD_LOCACAO = @ID_LOCACAO;
    
    UPDATE FILME SET Status = 'Disponível' WHERE COD_FILME = @ID_FILME_VAR;
    
    PRINT 'Filme devolvido com sucesso!'
END;
GO

--testes 

-- 1: Incluir Cliente
PRINT '========== TESTE 1: INCLUIR_CLIENTE =========='
EXEC Incluir_Cliente '999888777', 'Cliente Novo', 'Rua X', 'Bairro Y', 'Sorocaba', 'SP', '32125890', 'novo@email.com', '1995-10-10', 'F';
SELECT * FROM CLIENTES WHERE NOME = 'Cliente Novo';

-- 2: Selecionar Cliente
PRINT '========== TESTE 2: SELECIONAR_CLIENTE =========='
EXEC Selecionar_Cliente 1;

-- 3: Alterar Cliente
PRINT '========== TESTE 3: ALTERAR_CLIENTE =========='
EXEC Alterar_Cliente 5, @TELEFONE = '999999999';
EXEC Selecionar_Cliente 5;

--  4: Aniversariantes do Mês
PRINT '========== TESTE 4: PROC_ANIVERSARIANTES_MES =========='
EXEC proc_Aniversariantes_Mes 4;

-- 5: Resumo de Aniversariantes
PRINT '========== TESTE 5: RESUMO_ANIVERSARIANTES =========='
EXEC Resumo_Aniversariantes;

--  6: Clientes por Cidade e Idade
PRINT '========== TESTE 6: LISTAR_CLIENTES_CIDADE_IDADE =========='
EXEC Listar_Clientes_Cidade_Idade 'Sorocaba', 40;

-- 7: Incluir Locação
PRINT '========== TESTE 7: INCLUIR_LOCACAO =========='
EXEC Incluir_Locacao 1, 1;
SELECT * FROM LOCACOES;
SELECT COD_FILME, FILME, Status FROM FILME WHERE COD_FILME = 1;

--  8: Devolver Filme
PRINT '========== TESTE 8: DEVOLVER_FILME =========='
EXEC Devolver_Filme 1;
SELECT * FROM LOCACOES WHERE COD_LOCACAO = 1;
SELECT COD_FILME, FILME, Status FROM FILME WHERE COD_FILME = 1;

-- 9: Excluir Cliente
PRINT '========== TESTE 9: EXCLUIR_CLIENTE =========='
EXEC Excluir_Cliente 5;
SELECT COUNT(*) AS Total_Clientes FROM CLIENTES;