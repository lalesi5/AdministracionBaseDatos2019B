/*==============================================================*/
/*				ESCUELA POLITECNICA NACIONAL					*/
/*				ADMINISTRACION DE BASE DE DATOS					*/
/*						ALEX CARRERA							*/
/*					SERGIO VILLACRÉS							*/
/*			Creacion de la Base de Datos BDD_BOOKSTORE			*/
/*==============================================================*/

USE master
GO

CREATE DATABASE BDD_BOOKSTORE
ON PRIMARY
(NAME='PRIMARY_DAT',
 FILENAME=
 'E:\FileGroupsSQL\PRIMARY_DAT.mdf',
 SIZE=10MB,
 MAXSIZE=65MB,
 FILEGROWTH=1MB),
FILEGROUP BDD_BOOKSTORE_CATALOGO
 (NAME='BDD_BOOKSTORE_CATALOGO',
 FILENAME=
 'E:\FileGroupsSQL\BDD_BOOKSTORE_CATALOGO.ndf',
 SIZE=10MB,
 MAXSIZE=65MB,
 FILEGROWTH=1MB),
FILEGROUP BDD_BOOKSTORE_VENTAS
 ( NAME = 'BDD_BOOKSTORE_DATOS_1',
 FILENAME =
 'E:\FileGroupsSQL\BDD_BOOKSTORE_DAT_1.ndf',
 SIZE = 5MB,
 MAXSIZE=50MB,
 FILEGROWTH=1MB),
 ( NAME = 'BDD_BOOKSTORE_DATOS_2',
 FILENAME =
 'E:\FileGroupsSQL\BDD_BOOKSTORE_DAT_2.ndf',
 SIZE = 5MB,
 MAXSIZE=50MB,
 FILEGROWTH=1MB)
LOG ON
 ( NAME='BDD_BOOKSTORE_LOG_1',
 FILENAME =
 'E:\FileGroupsSQL\BDD_BOOKSTORE_LOG_1.ldf',
 SIZE=5MB,
 MAXSIZE=35MB,
 FILEGROWTH=1MB),
 ( NAME='BDD_BOOKSTORE_LOG_2',
 FILENAME =
 'E:\FileGroupsSQL\BDD_BOOKSTORE_LOG_2.ldf',
 SIZE=5MB,
 MAXSIZE=35MB, 
 FILEGROWTH=1MB);
GO


/*==============================================================*/
/*							SCHEMA								*/
/*==============================================================*/


CREATE SCHEMA catalogo AUTHORIZATION DBO
GO
CREATE SCHEMA ventas AUTHORIZATION DBO
GO


/*==============================================================*/
/*						Table: AUTOR							*/
/*==============================================================*/


create table catalogo.AUTOR (
 AUTOR_ID int NOT NULL IDENTITY(1,1),
 AUTOR_NOMBRE varchar(100) null,
 --constraint PK_AUTOR primary key nonclustered (CEDULA)
)
ON BDD_BOOKSTORE_CATALOGO;
GO


/*==============================================================*/
/*						Table: CLIENTE							*/
/*==============================================================*/


create table catalogo.CLIENTE (
 CLIENTE_CEDULA varchar(15) not null,
 CLIENTE_NOMBRE varchar(100) null,
 -- constraint PK_CLIENTE primary key nonclustered (CLIENTE_CEDULA)
)
ON BDD_BOOKSTORE_CATALOGO;
GO


/*==============================================================*/
/*					Table: DETALLE_VENTA						*/
/*==============================================================*/


create table ventas.DETALLE_VENTA (
 DETALLE_VENTA_ID int not null IDENTITY(1,1),
 VENTA_ID int null,
 EDICION_NUMERO int null,
 CANTIDAD int null,
 PRECIO_UNITARIO money null,
-- constraint PK_DETALLE_VENTA primary key nonclustered (DETALLE_VENTA_ID)
)
ON BDD_BOOKSTORE_VENTAS;
go


/*==============================================================*/
/*						Table: EDICION							*/
/*==============================================================*/


create table catalogo.EDICION (
 EDICION_NUMERO int not null IDENTITY(1,1),
 ISBN int null,
 ANIO int null,
 NUMERO_COPIAS int null,
 PRECIO money null,
-- constraint PK_EDICION primary key nonclustered (EDICION_NUMERO,ISBN)
)
ON BDD_BOOKSTORE_CATALOGO;
go


/*==============================================================*/
/*						Table: LIBRO							*/
/*==============================================================*/


create table catalogo.LIBRO (
 ISBN int not null,
 TITULO varchar(100) null,
 IDIOMA varchar(20) null,
-- constraint PK_LIBRO primary key nonclustered (ISBN)
)
ON BDD_BOOKSTORE_CATALOGO;
go


/*==============================================================*/
/*						Table: LIBRO_AUTOR						*/
/*==============================================================*/


create table catalogo.LIBRO_AUTOR (
 AUTOR_ID varchar(15) not null,
 ISBN int not null,
 -- constraint PK_LIBRO_AUTOR primary key nonclustered (AUTOR_ID, ISBN)
)
ON BDD_BOOKSTORE_CATALOGO;
go


/*==============================================================*/
/*						Table: VENTA							*/
/*==============================================================*/


create table ventas.VENTA (
 VENTA_ID int not null IDENTITY(1,1),
 CLIENTE_CEDULA varchar(15) null,
 VENTA_FECHA datetime null,
 -- constraint PK_VENTA primary key nonclustered (VENTA_ID)
)
ON BDD_BOOKSTORE_VENTAS;
go


/*==============================================================*/
/*					Table: INFO_LIBROS							*/
/*==============================================================*/


create table catalogo.INFO_LIBROS (
 ISBN int not null,
 TITULO varchar(100) null,
 IDIOMA varchar(20) null,
 EDICION_NUMERO int not null,
 ANIO int null,
 NUMERO_COPIAS int null,
 PRECIO money null,
 AUTOR_ID varchar(15) not null,
 AUTOR_NOMBRE varchar(100) null
)
ON BDD_BOOKSTORE_CATALOGO;
GO


/*==============================================================*/
/*				TRIGER CATALOGO.INFO_LIBROS_IU					*/
/*==============================================================*/


CREATE TRIGGER catalogo.INFO_LIBROS_IU
ON catalogo.INFO_LIBROS
AFTER INSERT,UPDATE
AS
BEGIN
 IF (SELECT TOP(1) 1 FROM catalogo.LIBRO,catalogo.EDICION,catalogo.LIBRO_AUTOR
WHERE catalogo.LIBRO.ISBN = catalogo.EDICION.ISBN AND catalogo.LIBRO_AUTOR.ISBN =
catalogo.EDICION.ISBN AND catalogo.LIBRO.ISBN = (select ISBN from inserted)) = 1
 BEGIN
 UPDATE catalogo.LIBRO SET catalogo.LIBRO.TITULO = (select TITULO from inserted),
catalogo.LIBRO.IDIOMA = (select IDIOMA from inserted) WHERE catalogo.LIBRO.ISBN = (select ISBN from inserted);
 UPDATE catalogo.EDICION SET catalogo.EDICION.ANIO =
(select ANIO from inserted),catalogo.EDICION.NUMERO_COPIAS=(select NUMERO_COPIAS from inserted),catalogo.EDICION.PRECIO=(select PRECIO from inserted) WHERE catalogo.EDICION.ISBN = (select ISBN from inserted)
 END
 ELSE
 BEGIN
 DECLARE @LI_AUTOR_ID INT
 INSERT catalogo.LIBRO (ISBN,TITULO,IDIOMA) SELECT ISBN,TITULO,IDIOMA FROM
INSERTED;
 INSERT catalogo.AUTOR (AUTOR_NOMBRE) SELECT AUTOR_NOMBRE FROM INSERTED;
 SET @LI_AUTOR_ID = (SELECT MAX(AUTOR_ID) FROM catalogo.AUTOR)
 INSERT catalogo.LIBRO_AUTOR (AUTOR_ID,ISBN) SELECT @LI_AUTOR_ID,ISBN FROM
INSERTED;
 INSERT catalogo.EDICION (ISBN,EDICION_NUMERO,ANIO,NUMERO_COPIAS,PRECIO)
SELECT ISBN,EDICION_NUMERO,ANIO,NUMERO_COPIAS,PRECIO FROM INSERTED;
 END

END
GO

/*==============================================================*/
/*					TRIGER CATALOGO.INFO_LIBROS_D				*/
/*==============================================================*/


CREATE TRIGGER catalogo.INFO_LIBROS_D
ON catalogo.INFO_LIBROS
AFTER DELETE
AS
BEGIN
 DELETE catalogo.LIBRO_AUTOR WHERE catalogo.LIBRO_AUTOR.ISBN = (SELECT ISBN FROM deleted)
 DELETE catalogo.EDICION WHERE catalogo.EDICION.ISBN = (SELECT ISBN FROM deleted)
 DELETE catalogo.LIBRO WHERE catalogo.LIBRO.ISBN = (SELECT ISBN FROM deleted)
END
GO


/*==============================================================*/
/*					TRIGER CATALOGO.LIBROS_IU					*/
/*==============================================================*/


CREATE TRIGGER catalogo.LIBRO_IU
ON catalogo.LIBRO
AFTER INSERT,UPDATE
AS
BEGIN
INSERT catalogo.INFO_LIBROS
(ISBN,TITULO,IDIOMA,EDICION_NUMERO,ANIO,NUMERO_COPIAS,PRECIO,AUTOR_NOMBRE
)
 SELECT top(1) catalogo.LIBRO.ISBN, catalogo.LIBRO.TITULO,catalogo.LIBRO.IDIOMA,catalogo.EDICION.EDICION_NUMERO,catalogo.EDICION.ANIO,catalogo.EDICION.NUMERO_COPIAS,catalogo.EDICION.PRECIO,catalogo.AUTOR.AUTOR_NOMBRE
 FROM catalogo.LIBRO, catalogo.EDICION, catalogo.LIBRO_AUTOR, catalogo.AUTOR
 WHERE catalogo.LIBRO.ISBN = catalogo.EDICION.ISBN
 AND catalogo.LIBRO.ISBN = catalogo.LIBRO_AUTOR.ISBN
 AND catalogo.AUTOR.AUTOR_ID = catalogo.LIBRO_AUTOR.AUTOR_ID
 AND catalogo.LIBRO.ISBN = (SELECT ISBN FROM inserted)
 
END
GO


/*==============================================================*/
/*				TRIGER CATALOGO.EDICION_IU						*/
/*==============================================================*/


CREATE TRIGGER catalogo.EDICION_IU
ON catalogo.EDICION
AFTER INSERT,UPDATE
AS
BEGIN
 INSERT catalogo.INFO_LIBROS
(ISBN,TITULO,IDIOMA,EDICION_NUMERO,ANIO,NUMERO_COPIAS,PRECIO,AUTOR_NOMBRE
)
 SELECT top(1)
catalogo.LIBRO.ISBN,catalogo.LIBRO.TITULO,catalogo.LIBRO.IDIOMA,catalogo.EDICION.EDICION_NUMERO,catalogo.EDICION.ANIO,catalogo.EDICION.NUMERO_COPIAS, catalogo.EDICION.PRECIO,catalogo.AUTOR.AUTOR_NOMBRE
 FROM catalogo.LIBRO, catalogo.EDICION, catalogo.LIBRO_AUTOR, catalogo.AUTOR
 WHERE catalogo.LIBRO.ISBN = catalogo.EDICION.ISBN
 AND catalogo.LIBRO.ISBN = catalogo.LIBRO_AUTOR.ISBN
 AND catalogo.AUTOR.AUTOR_ID = catalogo.LIBRO_AUTOR.AUTOR_ID
 AND catalogo.LIBRO.ISBN = (SELECT ISBN FROM inserted)
END
GO


/*==============================================================*/
/*					TRIGER CATALOGO.LIBRO_D						*/
/*==============================================================*/


CREATE TRIGGER catalogo.LIBRO_D
ON catalogo.LIBRO
AFTER DELETE
AS
BEGIN
 DELETE FROM catalogo.INFO_LIBROS WHERE catalogo.INFO_LIBROS.ISBN = (SELECT ISBN FROM deleted)
END
GO

/*==============================================================*/
/*					TRIGER CATALOGO.EDICION_D					*/
/*==============================================================*/


CREATE TRIGGER catalogo.EDICION_D
ON catalogo.EDICION
AFTER DELETE
AS
BEGIN
 DELETE catalogo.INFO_LIBROS WHERE catalogo.INFO_LIBROS.EDICION_NUMERO = (SELECT EDICION_NUMERO FROM deleted)
END
GO

/*==============================================================*/
/*						ALTER TABLE VENTAS						*/
/*==============================================================*/


ALTER TABLE ventas.VENTA
ADD TipoFac varchar(10) NOT NULL
CONSTRAINT fijarNombre DEFAULT ('CONTADO')
ALTER TABLE ventas.VENTA
ADD MontoTotal NUMERIC(8,2)
GO


/*==============================================================*/
/*						DATOS AUTOR								*/
/*==============================================================*/


use BDD_BOOKSTORE
INSERT INTO [catalogo].[AUTOR] VALUES ('Marco Almeida');
INSERT INTO [catalogo].[AUTOR] VALUES ('LUIS FRAILE ');
INSERT INTO [catalogo].[AUTOR] VALUES ('RAUL GAVIRA');
INSERT INTO [catalogo].[AUTOR] VALUES ('RUBEN NAVARRETE');
INSERT INTO [catalogo].[AUTOR] VALUES ('JAIME CAPEL');
INSERT INTO [catalogo].[AUTOR] VALUES ('DOMINGO ZAMORANO');
INSERT INTO [catalogo].[AUTOR] VALUES ('SAMUEL MONZON');
INSERT INTO [catalogo].[AUTOR] VALUES ('CRISTIAN DOPICO');
INSERT INTO [catalogo].[AUTOR] VALUES ('MANUEL PUIG');
INSERT INTO [catalogo].[AUTOR] VALUES ('RICARDO MAQUEDA');
INSERT INTO [catalogo].[AUTOR] VALUES ('HECTOR CALLE');
INSERT INTO [catalogo].[AUTOR] VALUES ('ADRIAN RIQUELME');
INSERT INTO [catalogo].[AUTOR] VALUES ('DANIEL MARCHANTE');
INSERT INTO [catalogo].[AUTOR] VALUES ('FRANCISCO CEA');
INSERT INTO [catalogo].[AUTOR] VALUES ('AITOR VINUESA');
INSERT INTO [catalogo].[AUTOR] VALUES ('DAVID DELGADO');
INSERT INTO [catalogo].[AUTOR] VALUES ('DANIEL ROJANO');
INSERT INTO [catalogo].[AUTOR] VALUES ('SAMUEL ARREDONDO');
INSERT INTO [catalogo].[AUTOR] VALUES ('MARIA VELA');
INSERT INTO [catalogo].[AUTOR] VALUES ('ALFREDO MEJIAS');


/*==============================================================*/
/*						DATOS lIBROS							*/
/*==============================================================*/


use BDD_BOOKSTORE
INSERT INTO [catalogo].[LIBRO] VALUES (1,'Don Quijote de la Mancha','ESP');
INSERT INTO [catalogo].[LIBRO] VALUES (2, 'Romeo y Julieta','ESP');
INSERT INTO [catalogo].[LIBRO] VALUES (3, 'Fausto','ESP');
INSERT INTO [catalogo].[LIBRO] VALUES (4, 'La Divina Comedia','ENG');
INSERT INTO [catalogo].[LIBRO] VALUES (5, 'Madame Bovary','ENG');
INSERT INTO [catalogo].[LIBRO] VALUES (6, 'La Guerra y la Paz','ESP');
INSERT INTO [catalogo].[LIBRO] VALUES (7, 'Oliver Twist','ESP');
INSERT INTO [catalogo].[LIBRO] VALUES (8, 'Tom Sawyer','ESP');
INSERT INTO [catalogo].[LIBRO] VALUES (9, 'Cumbres Borrascosas','ENG');
INSERT INTO [catalogo].[LIBRO] VALUES (10, 'Orgullo y Prejuicio','ENG');
INSERT INTO [catalogo].[LIBRO] VALUES (11, 'El Retrato de Dorian Gray','ENG');
INSERT INTO [catalogo].[LIBRO] VALUES (12, 'Drácula','ESP');
INSERT INTO [catalogo].[LIBRO] VALUES (13, 'Frankenstein','ENG');
INSERT INTO [catalogo].[LIBRO] VALUES (14, 'Alicia en el País de las Maravillas','ESP');
INSERT INTO [catalogo].[LIBRO] VALUES (15, 'Los Viajes de Golliver','ENG');
INSERT INTO [catalogo].[LIBRO] VALUES (16, 'Los tres Mosqueteros','ENG');
INSERT INTO [catalogo].[LIBRO] VALUES (17, 'La Piel de Zapa','ESP');
INSERT INTO [catalogo].[LIBRO] VALUES (18, 'La Vida es Sueño','ENG');
INSERT INTO [catalogo].[LIBRO] VALUES (19, 'Guillermo Tell','ENG');
INSERT INTO [catalogo].[LIBRO] VALUES (20, 'La Odisea','ESP');

SELECT * FROM catalogo.LIBRO;

/*==============================================================*/
/*						DATOS CLIENTES							*/
/*==============================================================*/


INSERT INTO [catalogo].[CLIENTE] VALUES (1303753618, 'Marco Almeida');
INSERT INTO [catalogo].[CLIENTE] VALUES (1706172648, 'LUIS FRAILE ');
INSERT INTO [catalogo].[CLIENTE] VALUES (0100967652, 'RAUL GAVIRA');
INSERT INTO [catalogo].[CLIENTE] VALUES (1103037048, 'RUBEN NAVARRETE');
INSERT INTO [catalogo].[CLIENTE] VALUES (1704997012, 'JAIME CAPEL');
INSERT INTO [catalogo].[CLIENTE] VALUES (1714818299, 'DOMINGO ZAMORANO');
INSERT INTO [catalogo].[CLIENTE] VALUES (1713627071, 'SAMUEL MONZON');
INSERT INTO [catalogo].[CLIENTE] VALUES (0200982163, 'CRISTIAN DOPICO');
INSERT INTO [catalogo].[CLIENTE] VALUES (0401197298, 'MANUEL PUIG');
INSERT INTO [catalogo].[CLIENTE] VALUES (0702648551, 'RICARDO MAQUEDA');
INSERT INTO [catalogo].[CLIENTE] VALUES (1715241434, 'HECTOR CALLE');
INSERT INTO [catalogo].[CLIENTE] VALUES (0917385288, 'ADRIAN RIQUELME');
INSERT INTO [catalogo].[CLIENTE] VALUES (1103756134, 'DANIEL MARCHANTE');
INSERT INTO [catalogo].[CLIENTE] VALUES (0601646623, 'FRANCISCO CEA');
INSERT INTO [catalogo].[CLIENTE] VALUES (1103201461, 'AITOR VINUESA');
INSERT INTO [catalogo].[CLIENTE] VALUES (0102051349, 'DAVID DELGADO');
INSERT INTO [catalogo].[CLIENTE] VALUES (1713580221, 'DANIEL ROJANO');
INSERT INTO [catalogo].[CLIENTE] VALUES (0601899396, 'SAMUEL ARREDONDO');
INSERT INTO [catalogo].[CLIENTE] VALUES (1305267542, 'MARIA VELA');
INSERT INTO [catalogo].[CLIENTE] VALUES (0200562791, 'ALFREDO MEJIAS');
GO

/*==============================================================*/
/*						ALTER TABLE VENTAS						*/
/*==============================================================*/


alter table ventas.VENTA
add constraint chk_tipoFac
check (tipoFac ='CREDITO' or tipoFac='CONTADO')
go
create trigger ventas.MONTO_UPDATE
ON ventas.DETALLE_VENTA
AFTER INSERT
AS
BEGIN
UPDATE ventas.VENTA set MontoTotal = (MontoTotal + (Select PRECIO_UNITARIO*CANTIDAD FROM INSERTED ))
where VENTA_ID = (SELECT VENTA_ID FROM INSERTED)
END
GO


/*==============================================================*/
/*						TABLA VENTAS DEUDOR						*/
/*==============================================================*/


CREATE TABLE ventas.DEUDOR (
DEUDOR_ID INT PRIMARY KEY IDENTITY(1,1),
CLIENTE_CEDULA VARCHAR(15) NOT NULL,
--GARANTE_CEDULA VARCHAR(15) NOT NULL,
LIMITE_CREDITO NUMERIC(8,2),
SALDO_DEUDOR NUMERIC(8,2)
)
GO


/*==============================================================*/
/*					TRIGGER VERIFICAR SALDO						*/
/*==============================================================*/


CREATE TRIGGER ventas.VERIFICAR_SALDO
ON ventas.DEUDOR
AFTER UPDATE
AS
BEGIN
DELETE FROM ventas.DEUDOR
WHERE SALDO_DEUDOR <= 0
END
GO


/*==============================================================*/
/*					TRIGGER VERIFICAR GARANTE					*/
/*==============================================================*/


CREATE TRIGGER ventas.VERIFICAR_GARANTE
ON ventas.DEUDOR
AFTER INSERT
AS
BEGIN
IF NOT EXISTS (SELECT * FROM ventas.DEUDOR WHERE CLIENTE_CEDULA =
(SELECT GARANTE_CEDULA FROM INSERTED))
BEGIN
INSERT
ventas.DEUDOR(CLIENTE_CEDULA,GARANTE_CEDULA,LIMITE_CREDITO,SALDO_DEUDOR)
SELECT
CLIENTE_CEDULA,GARANTE_CEDULA,LIMITE_CREDITO,SALDO_DEUDOR
FROM INSERTED
END
END
GO


/*==============================================================*/
/*				TRIGGER VERIFICAR SALDO DEUDOR					*/
/*==============================================================*/


CREATE TRIGGER ventas.VALIDAR_SALDO_DEUDOR
ON ventas.VENTA
FOR INSERT
AS
DECLARE @LN_SALDO NUMERIC(8,2);
IF EXISTS (SELECT * FROM ventas.DEUDOR where CLIENTE_CEDULA =(SELECT CLIENTE_CEDULA FROM INSERTED))
BEGIN
UPDATE ventas.DEUDOR set SALDO_DEUDOR = SALDO_DEUDOR + (
select MontoTotal from ventas.VENTA where VENTA_ID = (
select VENTA_ID from inserted))
where CLIENTE_CEDULA = (SELECT CLIENTE_CEDULA FROM INSERTED)
END
SELECT @LN_SALDO = SALDO_DEUDOR FROM ventas.DEUDOR WHERE CLIENTE_CEDULA = (SELECT CLIENTE_CEDULA FROM INSERTED)
GO

/*==============================================================*/
/*					TABLA VENTAS PAGOS							*/
/*==============================================================*/


CREATE TABLE ventas.PAGOS(
PAGOS_ID INT PRIMARY KEY IDENTITY(1,1),
CLIENTE_CEDULA VARCHAR(15) NOT NULL,
FECHA_PAGO DATE NOT NULL,
VALOR_PAGO NUMERIC(8,2),
)
GO
