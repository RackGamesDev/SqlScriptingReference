ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE;
-- CREATE DATABASE EG1 --Crear base de datos (ejecutar las consultas en dicha base)




--OPERACIONES CON TABLAS

--Borrar tabla, si no existe no da error, de normal seria DROP TABLE X
DROP TABLE USUARIO CASCADE CONSTRAINTS;
DROP TABLE TELEFONO CASCADE CONSTRAINTS;
DROP TABLE USUARIO_TELEFONO CASCADE CONSTRAINTS;
DROP TABLE CASA CASCADE CONSTRAINTS;

--Crear tabla con esas propiedades
--Tipos de datos: VARCHAR[2](tamagno maximo), DATE, TIMESTAMP, NUMBER, NUMBER(cifras), NUMBER(cifras, cifra decimal), CHAR(medida obligatoria), FLOAT, LONG, binarios(raw, long raw, blob, clob, nlob, bfile), ROWID autonumerico
CREATE TABLE USUARIO(uuid VARCHAR(63), nombre VARCHAR(127) NOT NULL, apellido VARCHAR(255), fecha DATE, numero NUMBER(5, 2), calificacion NUMBER(5, 2) DEFAULT '1');
CREATE TABLE TELEFONO(id NUMBER, prefijo VARCHAR(5), numero VARCHAR(9), fecha DATE);
CREATE TABLE USUARIO_TELEFONO(uuid_USUARIO VARCHAR(63), id_TELEFONO NUMBER); --Esta tabla sale de una relacion n:m
CREATE TABLE CASA(id NUMBER(8), uuid_USUARIO VARCHAR(63)); --Esta tabla tendra una clave ajena a la pk de otra tabla
--Para hacer atributos autoincrementales hay que ver como se hace en cada gestor de base de datos ya que no hay un estandar

--Agregar la restriccion de clave primaria a esa tabla (puede estar compuesta de varias propiedades)
--Tipos de constraint: UNIQUE uk_, PRIMARY KEY pk_, FOREIGN KEY fk_, CHECK ck_
ALTER TABLE USUARIO ADD CONSTRAINT pk_USUARIO PRIMARY KEY (uuid);
ALTER TABLE TELEFONO ADD CONSTRAINT pk_TELEFONO PRIMARY KEY (id);
ALTER TABLE USUARIO_TELEFONO ADD CONSTRAINT pk_USUARIO_TELEFONO PRIMARY KEY (uuid_USUARIO, id_TELEFONO);

--Agregar la restriccion de clave unica a esa tabla a una propiedad (puede estar compuesta de varias propiedades)
ALTER TABLE USUARIO ADD CONSTRAINT uk_USUARIO_numero UNIQUE (numero);

--Agregar la restriccion de clave ajena a esa tabla con una clave primaria de otra (puede estar compuesta de varias propiedades)
ALTER TABLE USUARIO_TELEFONO ADD CONSTRAINT fk_USUARIO_TELEFONO_uuid_USUARIO FOREIGN KEY (uuid_USUARIO) REFERENCES USUARIO(uuid);
ALTER TABLE USUARIO_TELEFONO ADD CONSTRAINT fk_USUARIO_TELEFONO_id_TELEFONO FOREIGN KEY (id_TELEFONO) REFERENCES TELEFONO(id);
ALTER TABLE CASA ADD CONSTRAINT fk_CASA_uuid_USUARIO FOREIGN KEY (uuid_USUARIO) REFERENCES USUARIO(uuid);

--Manejar otro tipo de restricciones sobre ciertas propiedades
ALTER TABLE USUARIO ADD CONSTRAINT ck_USUARIO_calificacion CHECK ((calificacion<=100) AND (calificacion > 0)); --Todas estas condiciones tambien pueden ser usadas en consultas con registros
ALTER TABLE USUARIO ADD CONSTRAINT ck_USUARIO_apellido CHECK ((apellido) IN ('una opcion', 'otra opcion'));
ALTER TABLE USUARIO ADD CONSTRAINT ck_USUARIO_numero CHECK ((numero) BETWEEN 1 AND 100);
ALTER TABLE USUARIO DISABLE CONSTRAINT ck_USUARIO_calificacion;
ALTER TABLE USUARIO ENABLE CONSTRAINT ck_USUARIO_calificacion;
ALTER TABLE USUARIO DROP CONSTRAINT ck_USUARIO_calificacion;

--Agnadir o eliminar propiedades en tablas
ALTER TABLE USUARIO ADD correo VARCHAR(255);
ALTER TABLE USUARIO DROP COLUMN correo;




--OPERACIONES CON REGISTROS (SELECT, FROM, WHERE, GROUP BY, HAVING, ORDER BY)

INSERT INTO TELEFONO (id , numero, fecha) VALUES (0, '123456789', TO_DATE('21/03/2022', 'DD/MM/YYYY')); --Aagnadir un entry a la tabla, TO_DATE se puede reemplazar por SYSDATE para poner la fecha actual
INSERT INTO TELEFONO VALUES (1, '+52', NULL, TO_DATE('21/03/2022', 'DD/MM/YYYY')); --Si se agnaden todos los campos no hace falta ponerlos
UPDATE TELEFONO SET numero = '398458643', prefijo = '+20' WHERE id = 1 AND (prefijo = '+33' OR prefijo = '+34'); --Actualizar el contenido de una tabla donde se cumpla cierta condicion
DELETE FROM TELEFONO WHERE id = 1; --Elminar un entry especifico segun una condicion (IMPORTANTE PONER EL FROM PARA NO BORRAR LA TABLA)
TRUNCATE TABLE TELEFONO; --Borra todos los entrys de una tabla pero no la tabla


SELECT * FROM TELEFONO; --Devuelve todos los entrys de la tabla con todas las columnas
SELECT * FROM TELEFONO WHERE prefijo = '+52'; --Devuelve todos los entrys de la tabla en base a ciertas condiciones (similar a update, AND y OR tambien funcionarian) (< > >= <= != <>)
SELECT numero FROM USUARIO WHERE numero = 2 * (numero - 1); --Se pueden hacer operaciones en cualquier parte del select con los datos
SELECT * FROM TELEFONO WHERE prefijo IN ('+52', '+34'); --Devuelve los entrys donde x valor sea igual a alguno de esos valores 
SELECT * FROM TELEFONO WHERE numero BETWEEN 0 AND 5; --Devuelve los entrys donde ese valor numerico este entre esos dos numeros
SELECT * FROM TELEFONO WHERE prefijo IS NOT NULL; --Filtra para ver solo los que no son nulos, tambien se puede hacer solo con los nulos
SELECT * FROM TELEFONO WHERE id LIKE '5_5%'; --Expresiones regulares, % es cualquier cantidad de caracteres y _ es cualquier caracter
SELECT * FROM USUARIO WHERE LOWER(nombre) = 'a'; --Lower convierte cualquier cosa en mayusculas, tambien esta upper. Tambien se podria hacer = LOWER('ASDF')
SELECT nombre, apellido AS ape FROM USUARIO; --Muestra solo las columnas especificadas, tambien se le pueden cambiar el nombre a las columnas
SELECT * FROM USUARIO ORDER BY nombre DESC, apellido; --Ordenar de menor a mayor o alfabeticamente los registros, si ese valor es igual se evaluara el siguiente, DESC hace que sea descendente en este caso o ASC ascendente, se puede reemplazar el nombre de la propiedad por su numero
SELECT * FROM USUARIO ORDER BY nombre FETCH FIRST 3 ROWS ONLY; --Muestra los x primeros registros solo, depende de la version esto se podria reemplazar por LIMIT x , o por SELECT TOP x * FROM...
SELECT DISTINCT nombre FROM USUARIO; --Evita mostar resultadtos repetidos en esa propiedad

SELECT COUNT(*) AS cantidad FROM USUARIO; --Devuelve la cantidad de registros
SELECT COUNT(*) AS "la cantidad" FROM USUARIO; --Para poner mas de una palabra en el nombre
SELECT MAX(numero) FROM USUARIO; --Devuelve el que tenga el mayor valor, para el menor esta MIN
SELECT AVG(numero) FROM USUARIO; --Devuelve la media de ese valor en todos los registros seleccionados
SELECT AVG(DISTINCT numero) FROM USUARIO; --El distinct se puede aplicar a propiedades sueltas
SELECT SUM(numero) FROM USUARIO; --Devuelve el total de sumar todos esos valores
SELECT REGEXP_SUBSTR(numero, '^\d{3}') FROM TELEFONO; --Recorta el varchar para crear uno nuevo con solo los caracteres que cumplan ese regex, en este caso coge solo los 3 primeros numeros
SELECT * FROM TELEFONO WHERE REGEXP_SUBSTR(numero, '^\d{3}') = '123'; --Tambien se puede usar para filtrar
SELECT * FROM TELEFONO WHERE REGEXP_SUBSTR(numero, '\d{3}', 3, 2, 'i') = '789'; --El tercer parametru representa a partir de que caracter se va a evaluar, el cuarto que ocurrencia cogera (en este caso la segunda), el quinto dependiendo de la letra evalua de maneras distintas (i=case insensitive)
SELECT numero * 10 AS "numero por diez" FROM USUARIO; --Se puede operar con los valores a mostrar
SELECT ABS(numero) FROM USUARIO; --Siempre devuelve numeros positivos
SELECT ROUND(numero, 2) FROM USUARIO; --Redondea un numero, el 2 es que redondea a partir de la segunda cifra (29.54 = 30)

--SELECT * FROM USUARIO,TELEFONO; --Devuelve todas las combinaciones posibles con los registros de ambas tablas, NO RECOMENDADO
SELECT USUARIO.nombre, CASA.id FROM USUARIO, CASA WHERE CASA.uuid_USUARIO = USUARIO.uuid; --Seleccionando datos de dos tablas ya que estas tienen una relacion
--Lo anterior era sacar datos de dos tablas, con los JOIN se pueden unir dos tablas para conseguir una nueva (INNER JOIN = JOIN)
SELECT * FROM USUARIO JOIN CASA ON CASA.uuid_USUARIO = USUARIO.uuid WHERE nombre IS NOT NULL; --El join genera una tabla a partir de las otras 2, esta nueva tabla se puede volver a ampliar con otro join

SELECT COUNT(*) AS cantidad, nombre FROM USUARIO GROUP BY nombre; --Altera funciones como COUNT, AVG, SUM, etc... para agruparlas segun el valor de un campo, en este caso muestra la cantidad de usuarios con cada nombre
SELECT COUNT(*) AS cantidad, nombre FROM USUARIO GROUP BY nombre HAVING COUNT(*) > 3; --Lo mismo que antes pero poniendo un filtro, en este caso devolveria solo las que cumplan esa condicion





















INSERT INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('uuid1', 'John', 'una opcion', TO_DATE('2024-01-01', 'YYYY-MM-DD'), 1.00, 85.00);
INSERT INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('uuid2', 'Jane', 'otra opcion', TO_DATE('2023-12-15', 'YYYY-MM-DD'), 2.00, 90.00);
INSERT INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('uuid3', 'Alice', 'una opcion', TO_DATE('2022-05-22', 'YYYY-MM-DD'), 3.00, 95.00);
INSERT INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('uuid4', 'Bob', 'otra opcion', TO_DATE('2023-07-11', 'YYYY-MM-DD'), 4.00, 80.00);
INSERT INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('uuid5', 'Eve', 'una opcion', TO_DATE('2021-09-27', 'YYYY-MM-DD'), 5.00, 70.00);
INSERT INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('uuid6', 'Charlie', 'otra opcion', TO_DATE('2022-11-18', 'YYYY-MM-DD'), 6.00, 88.00);
INSERT INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('uuid7', 'Dave', 'una opcion', TO_DATE('2022-08-29', 'YYYY-MM-DD'), 7.00, 92.00);
INSERT INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('uuid8', 'Fiona', 'otra opcion', TO_DATE('2021-10-30', 'YYYY-MM-DD'), 8.00, 85.00);
INSERT INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('uuid9', 'George', 'una opcion', TO_DATE('2020-12-14', 'YYYY-MM-DD'), 9.00, 78.00);
INSERT INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('uuid10', 'Hannah', 'otra opcion', TO_DATE('2021-01-01', 'YYYY-MM-DD'), 10.00, 91.00);
INSERT INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('uuid11', 'Ivy', 'una opcion', TO_DATE('2021-12-23', 'YYYY-MM-DD'), 11.00, 87.00);
INSERT INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('uuid12', 'Jack', 'otra opcion', TO_DATE('2022-12-31', 'YYYY-MM-DD'), 12.00, 93.00);
INSERT INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('uuid13', 'Karen', 'una opcion', TO_DATE('2023-12-15', 'YYYY-MM-DD'), 13.00, 89.00);
INSERT INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('uuid14', 'Leo', 'otra opcion', TO_DATE('2023-11-11', 'YYYY-MM-DD'), 14.00, 96.00);
INSERT INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('uuid15', 'Mia', 'una opcion', TO_DATE('2023-10-21', 'YYYY-MM-DD'), 15.00, 82.00);
INSERT INTO TELEFONO (id, prefijo, numero, fecha) VALUES (1, '+1', '123456789', TO_DATE('2023-01-01', 'YYYY-MM-DD'));
INSERT INTO TELEFONO (id, prefijo, numero, fecha) VALUES (2, '+44', '987654321', TO_DATE('2023-02-15', 'YYYY-MM-DD'));
INSERT INTO TELEFONO (id, prefijo, numero, fecha) VALUES (3, '+33', '456789123', TO_DATE('2023-03-22', 'YYYY-MM-DD'));
INSERT INTO TELEFONO (id, prefijo, numero, fecha) VALUES (4, '+49', '321654987', TO_DATE('2023-04-11', 'YYYY-MM-DD'));
INSERT INTO TELEFONO (id, prefijo, numero, fecha) VALUES (5, '+34', '789123456', TO_DATE('2023-05-27', 'YYYY-MM-DD'));
INSERT INTO TELEFONO (id, prefijo, numero, fecha) VALUES (6, '+1', '111222333', TO_DATE('2023-06-18', 'YYYY-MM-DD'));
INSERT INTO TELEFONO (id, prefijo, numero, fecha) VALUES (7, '+44', '444555666', TO_DATE('2023-07-29', 'YYYY-MM-DD'));
INSERT INTO TELEFONO (id, prefijo, numero, fecha) VALUES (8, '+33', '777888999', TO_DATE('2023-08-30', 'YYYY-MM-DD'));
INSERT INTO TELEFONO (id, prefijo, numero, fecha) VALUES (9, '+49', '000111222', TO_DATE('2023-09-14', 'YYYY-MM-DD'));
INSERT INTO TELEFONO (id, prefijo, numero, fecha) VALUES (10, '+34', '333444555', TO_DATE('2023-10-01', 'YYYY-MM-DD'));
INSERT INTO TELEFONO (id, prefijo, numero, fecha) VALUES (11, '+1', '666777888', TO_DATE('2023-11-23', 'YYYY-MM-DD'));
INSERT INTO TELEFONO (id, prefijo, numero, fecha) VALUES (12, '+44', '999000111', TO_DATE('2023-12-31', 'YYYY-MM-DD'));
INSERT INTO TELEFONO (id, prefijo, numero, fecha) VALUES (13, '+33', '222333444', TO_DATE('2023-12-15', 'YYYY-MM-DD'));
INSERT INTO TELEFONO (id, prefijo, numero, fecha) VALUES (14, '+49', '555666777', TO_DATE('2023-11-11', 'YYYY-MM-DD'));
INSERT INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('uuid1', 1);
INSERT INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('uuid2', 2);
INSERT INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('uuid3', 3);
INSERT INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('uuid4', 4);
INSERT INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('uuid5', 5);
INSERT INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('uuid6', 6);
INSERT INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('uuid8', 8);
INSERT INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('uuid9', 9);
INSERT INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('uuid10', 10);
INSERT INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('uuid11', 11);
INSERT INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('uuid12', 12);
INSERT INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('uuid13', 13);
INSERT INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('uuid14', 14);
INSERT INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('uuid15', 15);
INSERT INTO CASA (id, uuid_USUARIO) VALUES (10000001, 'uuid1');
INSERT INTO CASA (id, uuid_USUARIO) VALUES (10000002, 'uuid2');
INSERT INTO CASA (id, uuid_USUARIO) VALUES (10000003, 'uuid3');
INSERT INTO CASA (id, uuid_USUARIO) VALUES (10000004, 'uuid4');
INSERT INTO CASA (id, uuid_USUARIO) VALUES (10000005, 'uuid5');
INSERT INTO CASA (id, uuid_USUARIO) VALUES (10000006, 'uuid6');
INSERT INTO CASA (id, uuid_USUARIO) VALUES (10000007, 'uuid7');
INSERT INTO CASA (id, uuid_USUARIO) VALUES (10000008, 'uuid8');
INSERT INTO CASA (id, uuid_USUARIO) VALUES (10000009, 'uuid9');
INSERT INTO CASA (id, uuid_USUARIO) VALUES (10000010, 'uuid10');
INSERT INTO CASA (id, uuid_USUARIO) VALUES (10000011, 'uuid11');
INSERT INTO CASA (id, uuid_USUARIO) VALUES (10000012, 'uuid12');
INSERT INTO CASA (id, uuid_USUARIO) VALUES (10000013, 'uuid13');
INSERT INTO CASA (id, uuid_USUARIO) VALUES (10000014, 'uuid14');
INSERT INTO CASA (id, uuid_USUARIO) VALUES (10000015, 'uuid15');








