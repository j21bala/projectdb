/* =====================================================
   ACTIVAR EVENT SCHEDULER (si no está activo)
===================================================== */

SET GLOBAL event_scheduler = ON;
SHOW VARIABLES LIKE 'event_scheduler';



/* =====================================================
   4 VISTAS
===================================================== */

/* 1) Vista: Empleados con su departamento */
CREATE VIEW vista_emp_departamento AS
SELECT e.nombres, e.apellidos, d.departamento_nombre
FROM empleados e
JOIN departamentos d 
ON e.departamento_id = d.departamento_id;

/* Ver vista */
SELECT * FROM vista_emp_departamento;



/* 2) Vista: Empleados con su ciudad */
CREATE VIEW vista_emp_ciudad AS
SELECT e.nombres, e.apellidos, u.ciudad
FROM empleados e
JOIN departamentos d ON e.departamento_id = d.departamento_id
JOIN ubicaciones u ON d.ubicacion_id = u.ubicacion_id;

/* Ver vista */
SELECT * FROM vista_emp_ciudad;



/* 3) Vista: Empleados con salario mayor a 5000 */
CREATE VIEW vista_salario_alto AS
SELECT nombres, apellidos, salario
FROM empleados
WHERE salario > 5000;

/* Ver vista */
SELECT * FROM vista_salario_alto;



/* 4) Vista: Promedio salarial por departamento */
CREATE VIEW vista_promedio_dep AS
SELECT departamento_id, AVG(salario) AS promedio
FROM empleados
GROUP BY departamento_id;

/* Ver vista */
SELECT * FROM vista_promedio_dep;



/* =====================================================
   3 INDICES
===================================================== */

/* 1) Índice compuesto: departamento y salario */
CREATE INDEX idx_emp_dep_sal
ON empleados(departamento_id, salario);

/* Ver índices */
SHOW INDEX FROM empleados;



/* 2) Índice compuesto: nombres y apellidos */
CREATE INDEX idx_emp_nombre
ON empleados(nombres, apellidos);

/* Ver índices */
SHOW INDEX FROM empleados;



/* 3) Índice compuesto en departamentos */
CREATE INDEX idx_dep_ubicacion_nombre
ON departamentos(ubicacion_id, departamento_nombre);

/* Ver índices */
SHOW INDEX FROM departamentos;


/* =================================================
   ACA INICIAN LAS FUNCIONES :)
===================================================*/

/* FUNCION #1 - Poder calcular el salario anual de los esclavos */

DELIMITER // /*Basicamente esto toma el salario del mes y lo multiplica por 12 = 1 año para el que no sabe*/

CREATE FUNCTION salario_anual(sal DECIMAL (10,3))
RETURNS DECIMAL (10,3)
DETERMINISTIC
BEGIN
   RETURN sal * 12;
END //

DELIMITER;

/* Como consultar esta cosa porque gongora no sabe*/
SELECT nombres, salario, salario_anual(salario) AS salario_anual
FROM empleados;



/*FUNCION #2 - Poder clasificar los salarios*/

DELIMITER // /*Basicamente determinar que tan bajo o que tan alto tiene alguien el salario, es decir si lo roban, le pagan el minimo o es el que roba*/

CREATE FUNCTION clasificacion_salario (sal DECIMAL(10,3))
RETURNS VARCHAR(35) 
DETERMINISTIC
BEGIN
   DECLARE categoria VARCHAR(35);

   IF sal < 4000 THEN
      SET categoria ='POBRE o LE PAGAN UNA MISERIA';
   ELSEIF sal BETWEEN 4000 AND 7000 THEN
      SET categoria ='MEDIO, LE PAGAN LO BASICO';
   ELSE
      SET categoria='ALTO o SE ROBA LA PLATA';
   END IF;

   RETURN categoria;

END //

DELIMITER;

/*Como probar esta cosa*/
SELECT nombres, salario, clasificacion_salario(salario) AS categoria
FROM empleados;

/* Como mirar que esto si exista y no sea mentira */
SHOW FUNCTION STATUS WHERE Db = DATABASE();




/* ===============================================================
   ACA INICIAN LOS PROCEDIMIENTOS ALMACENADOS (NI IDEA QUE ES ESO)
   ===============================================================*/

/* PROCEDIMIENTO #1 - Los empleados por departamento */

DELIMITER //

CREATE PROCEDURE empleados_departamento_uwu (IN dep INT)
BEGIN
   SELECT nombres, apellidos, salario
   FROM empleados
   WHERE departamento_id = dep;
END //

DELIMITER;

/* Como ejecutar esta cosa rara*/
CALL empleados_departamento_uwu(1); /*Aca el numerito se puede cambiar segun el id del departamento*/



/* PROCEDIMIENTO #2 - Sacar las estadisticas de salarios por departamento
es decir, mirar a quien le pagan mas o menos x departamento y ver quien se roba mas la plata */

DELIMITER //

CREATE PROCEDURE estadisticas_departamento (IN dep INT)
BEGIN
   SELECT
      COUNT(*) AS total_empleados_esclavos,
      AVG(salario) AS salario_promedio_de_los_esclavos,
      MAX(salario) AS salario_maximo_que_se_les_paga
   FROM empleados
   WHERE departamento_id = dep;
END //

DELIMITER;

/* Como ejecutamos esta cosa*/
CALL estadisticas_departamento(2); /* Aca el numerito se puede cambiar segun el numero del departamento*/

/* Como mirar que esto si exista y no sea mentira */
SHOW PROCEDURE STATUS WHERE Db = DATABASE();



/* ==================================================
   ACA INICIAN LOS TRIGGERS (O COMO SE ESCRIBA)
   ==================================================*/

/* antes de hacer los tigres, toca hacer una tabla para tener como un historial entonces, pues eso*/

CREATE TABLE IF NOT EXISTS log_salarios (
   id INT AUTO_INCREMENT PRIMARY KEY,
   empleado_id INT,
   salario_anterior DECIMAL (10,3),
   salario_nuevo DECIMAL (10,3),
   fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/* Ahora si los triggers*/

DELIMITER //

CREATE TRIGGER alerta_cambio_salario
AFTER UPDATE ON empleados
FOR EACH ROW
BEGIN
   IF OLD.salario <> NEW.salario THEN
      INSERT INTO log_salarios
      (empleado_id, salario_anterior, salario_nuevo)
      VALUES
      (OLD.empleado_id, OLD.salario, NEW.salario);
   END IF;
END //

DELIMITER;

/* Como presentar los tigres

1. Se hace cualquier cambio en un salario 

   UPDATE empleados
   SET salario = salario + 500
   WHERE empleado_id = 1;

2. Luego se ve el historial para pues comprobar los cambios

   SELECT * FROM log_salarios; */

/* Ahora, como comprobar que esto existe*/
SHOW TRIGGERS;


/* ====================================================
   ACA VA EL PARTICIONAMIENTO (LO MAS FEO)
   ==================================================*/

/* Esto toca por pasos, entonces, para no llegar a romper la BD,
se puede crear una tabla alterna en donde al no tener dependencias,
se pueda hacer una correcta particion de los datos

1. crear una tabla que sea compatible */ 

CREATE TABLE empleados_particion (
   empleado_id INT NOT NULL,
   nombres VARCHAR (30),
   apellidos VARCHAR(30) NOT NULL,
   email VARCHAR (100) NOT NULL,
   numero_telefono VARCHAR(20),
   fecha_ingreso DATE NOT NULL,
   trabajo_id INT NOT NULL,
   salario DECIMAL (8,2) NOT NULL,
   gerencia_id INT,
   departamento_id INT,

   PRIMARY KEY (empleado_id, salario)

);

/*
2. Ahora se copian los datos*/

INSERT INTO empleados_particion (
   empleado_id, nombres, apellidos, email, numero_telefono,
   fecha_ingreso, trabajo_id, salario, gerencia_id, departamento_id
)
SELECT
   empleado_id, nombres, apellidos, email, numero_telefono,
   fecha_ingreso, trabajo_id, salario, gerencia_id, departamento_id
FROM empleados;


/* Ahora si el PARTICIONAMIENTO*/

ALTER TABLE empleados_particion
PARTITION BY RANGE (salario) (
   PARTITION p_bajo VALUES LESS THAN (4000),
   PARTITION p_medio VALUES LESS THAN (8000),
   PARTITION p_alto VALUES LESS THAN (15000),
   PARTITION p_top VALUES LESS THAN MAXVALUE
);


/* Ahora comprobar como funciona */
--Para ver la estructura 
SHOW CREATE TABLE empleados_particion;

--Para ver las particiones reales 
   SELECT PARTITION_NAME, TABLE_ROWS
   FROM INFORMATION_SCHEMA.PARTITIONS
   WHERE TABLE_NAME = 'empleados_particion';
   
--Y una consulta funcional 
   
   SELECT * FROM empleados_particion WHERE salario < 4000;



/* =====================================================
   1 EVENTO
===================================================== */

/* Escenario: aumentar 3% a salarios menores de 4000 cada día */
CREATE EVENT evento_aumento_bajo_salario
ON SCHEDULE EVERY 1 DAY
DO
UPDATE empleados
SET salario = salario * 1.03
WHERE salario < 4000;

/* Ver eventos */
SHOW EVENTS;


/* =====================================================
   1 CUBO (Analisis multidimensional)
===================================================== */

/* Salario promedio por departamento y trabajo */
SELECT d.departamento_nombre,
       t.trabajo_nombre,
       AVG(e.salario) AS promedio_salario
FROM empleados e
JOIN departamentos d ON e.departamento_id = d.departamento_id
JOIN trabajos t ON e.trabajo_id = t.trabajo_id
GROUP BY d.departamento_nombre, t.trabajo_nombre
WITH ROLLUP;
