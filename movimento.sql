CREATE TABLE Produto
(
	ID_PRODUTO int primary key,
	DESCRICAO varchar(80),
	UN int,
	PRECO float
)

CREATE TABLE Venda
(
	ID_VENDA int primary key,
	DATA_VENDA datetime,
	ID_CLIENTE int,
	ID_PRODUTO int,
	QTD_Venda int,
	Valor_Total decimal(10,2),
	n_parcelas int,
	constraint FK_Venda_Produto
	foreign key (ID_PRODUTO)
	references Produto(ID_PRODUTO)
)

CREATE TABLE Compra
(
	ID_COMPRA int primary key,
	ID_PRODUTO int,
	DATA_COMPRA datetime,
	QTD_Compra int,
	Valor_Total decimal(10,2),
	constraint FK_Compra_Produto
	foreign key (ID_PRODUTO)
	references Produto(ID_PRODUTO)
)

CREATE TABLE Saldo
(
	ID_PRODUTO int primary key,
	QTD int,
	constraint FK_Saldo_Produto
	foreign key (ID_PRODUTO)
	references Produto(ID_PRODUTO)
)

CREATE TABLE Feriados_Fixos
(
	ID_Feriado_Fixo int primary key identity(1,1),
	Dia int,
	Mes int,
	Descricao varchar(50)
)

CREATE TABLE Feriados_Do_Ano
(
	ID_Feriado_Ano int primary key identity(1,1),
	Data_Feriado date,
	Descricao varchar(50)
)

CREATE TABLE Contas_A_Receber
(
	ID_Conta int primary key identity(1,1),
	ID_Venda int,
	Num_Parcela int,
	Data_Vencimento date,
	Valor_Parcela money,
	Data_Pagamento date,
	constraint FK_CAR_Venda
	foreign key (ID_Venda)
	references Venda(ID_VENDA)
)

-- Inserção de Produtos
INSERT INTO Produto (ID_PRODUTO, DESCRICAO, UN, PRECO)
VALUES
(01, 'Semente de Girassol', 101, 3.00),
(02, 'Semente de Margarida', 102, 3.00),
(03, 'Semente de Lavanda', 103, 3.00),
(04, 'Semente de Azaleia', 104, 3.00),
(05, 'Semente de Antúrio', 105, 3.59),
(06, 'Adubo Orgânico Concentrado', 201, 31.59),
(07, 'Adubo Enraizador Líquido', 202, 31.59),
(08, 'Fertilizante NPK 10-10-10', 203, 67.99),
(09, 'Fertilizante para Orquídeas', 204, 67.99),
(10, 'Substrato Premium para Suculentas', 205, 26.68),
(11, 'Substrato para Plantas Verdes', 206, 26.68),
(12, 'Vaso de Cerâmica Terracota G', 301, 59.76),
(13, 'Vaso Auto-irrigável Médio', 302, 70.00),
(14, 'Cachepô de Fibra Natural', 303, 69.90),
(15, 'Mini Vaso de Vidro Suspenso', 304, 19.90),
(16, 'Pá de Jardinagem em Aço Inox', 305, 25.00),
(17, 'Muda de Costela-de-Adão', 401, 83.61),
(18, 'Muda de Jiboia Pendente', 402, 145.00),
(19, 'Muda de Espada-de-São-Jorge', 403, 71.49),
(20, 'Muda de Lírio da Paz', 404, 58.90),
(21, 'Muda de Orquídea Phalaenopsis', 405, 78.90)

-- Inicialização do Saldo
INSERT INTO Saldo (ID_PRODUTO, QTD)
SELECT ID_PRODUTO, 100 FROM Produto

-- Inserção de Feriados Fixos
INSERT INTO Feriados_Fixos (Dia, Mes, Descricao)
VALUES
(1, 1, 'Confraternização Universal'),
(21, 4, 'Tiradentes'),
(1, 5, 'Dia do Trabalho'),
(12, 10, 'Nossa Senhora Aparecida'),
(2, 11, 'Finados'),
(15, 11, 'Proclamação da República'),
(25, 12, 'Natal')

-- Inserção de Feriados Móveis (Ano 2026)
INSERT INTO Feriados_Do_Ano (Data_Feriado, Descricao)
VALUES
('2026-02-17', 'Carnaval'),
('2026-04-03', 'Paixão de Cristo'),
('2026-09-07', 'Independência do Brasil')

GO

-- TRIGGER 1: Subtrair saldo após venda
CREATE TRIGGER TR_Venda_SubtraiSaldo
ON Venda
AFTER INSERT
AS
BEGIN
	UPDATE Saldo
	SET QTD = QTD - i.QTD_Venda
	FROM Saldo s
	INNER JOIN inserted i ON s.ID_PRODUTO = i.ID_PRODUTO
END
GO

-- TRIGGER 2: Somar saldo após compra
CREATE TRIGGER TR_Compra_SomaSaldo
ON Compra
AFTER INSERT
AS
BEGIN
	UPDATE Saldo
	SET QTD = QTD + i.QTD_Compra
	FROM Saldo s
	INNER JOIN inserted i ON s.ID_PRODUTO = i.ID_PRODUTO
END
GO

-- TRIGGER 3: Criar parcelas após venda
CREATE TRIGGER TR_Venda_CriaParcelas
ON Venda
AFTER INSERT
AS
BEGIN
	INSERT INTO Contas_A_Receber (ID_Venda, Num_Parcela, Data_Vencimento, Valor_Parcela, Data_Pagamento)
	SELECT
		i.ID_VENDA,
		NumParcela,
		dbo.fn_ProximoDiaUtil(DATEADD(MONTH, NumParcela - 1, i.DATA_VENDA)),
		i.Valor_Total / i.n_parcelas,
		NULL
	FROM inserted i
	CROSS JOIN (
		SELECT 1 as NumParcela UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL
		SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL
		SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
	) NumParcelas
	WHERE NumParcela <= i.n_parcelas
END
GO

-- Deleção da função caso exista
IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'fn_ProximoDiaUtil' AND type = 'FN')
    DROP FUNCTION dbo.fn_ProximoDiaUtil
GO

-- Criação da função de próximo dia útil
CREATE FUNCTION dbo.fn_ProximoDiaUtil(@Data DATETIME)
RETURNS DATETIME
AS
BEGIN
    DECLARE @Dia_Semana INT
    DECLARE @Data_Teste DATETIME
    
    SET @Data_Teste = @Data
    
    WHILE 1 = 1
    BEGIN
        SET @Dia_Semana = DATEPART(WEEKDAY, @Data_Teste)
        
        IF @Dia_Semana = 1 OR @Dia_Semana = 7
            SET @Data_Teste = DATEADD(DAY, 1, @Data_Teste)
        ELSE IF EXISTS (SELECT 1 FROM Feriados_Fixos 
                       WHERE DAY(@Data_Teste) = Dia AND MONTH(@Data_Teste) = Mes)
            SET @Data_Teste = DATEADD(DAY, 1, @Data_Teste)
        ELSE IF EXISTS (SELECT 1 FROM Feriados_Do_Ano 
                       WHERE CAST(Data_Feriado AS DATETIME) = CAST(@Data_Teste AS DATETIME))
            SET @Data_Teste = DATEADD(DAY, 1, @Data_Teste)
        ELSE
            BREAK
    END
    
    RETURN @Data_Teste
END
GO


-- p testar

-- 1. consultar o estado inicial das tabelas
-- SELECT * FROM Produto;
-- SELECT * FROM Saldo;
-- SELECT * FROM Feriados_Fixos;
-- SELECT * FROM Feriados_Do_Ano;

-- 2. simular a inserção de uma venda (Venda teste no feriado de 01/05/2026)
-- INSERT INTO Venda (ID_VENDA, DATA_VENDA, ID_CLIENTE, ID_PRODUTO, QTD_Venda, Valor_Total, n_parcelas)
-- VALUES (1, '2026-05-01', 99, 17, 5, 250.83, 3);

-- 3. verificar o impacto no saldo do produto vendido
-- SELECT * FROM Saldo WHERE ID_PRODUTO = 17;

-- 4. verificar o parcelamento gerado no Contas a Receber
-- SELECT * FROM Contas_A_Receber;