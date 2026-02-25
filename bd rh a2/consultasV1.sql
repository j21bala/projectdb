-- ======================================================
-- BASE DE DATOS: bdrh
-- PROYECTO SQL AVANZADO COMPLETO
-- ======================================================

-- ======================================================
-- TABLA PRINCIPAL
-- ======================================================

CREATE TABLE empleados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    salario DECIMAL(10,2),
    departamento VARCHAR(50),
    fecha_ingreso DATE
);

INSERT INTO empleados (nombre, salario, departamento, fecha_ingreso) VALUES
('Juan', 2000000, 'Sistemas', '2022-01-10'),
('Ana', 3000000, 'RRHH', '2021-03-15'),
('Carlos', 2500000, 'Sistemas', '2020-06-20'),
('Laura', 2800000, 'Finanzas', '2019-09-01');

-- ======================================================
-- VISTA SIMPLE
-- ======================================================

CREATE VIEW vista_empleados AS
SELECT nombre, salario, departamento
FROM empleados;

-- ======================================================
-- INDICE
-- ======================================================

CREATE INDEX idx_departamento
ON empleados(departamento);

-- ======================================================
-- FUNCION ESCALAR
-- ======================================================

DELIMITER //

CREATE FUNCTION calcular_bonus(salario DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN salario * 0.10;
END //

DELIMITER ;

-- ======================================================
-- PROCEDIMIENTO
-- ======================================================

DELIMITER //

CREATE PROCEDURE listar_empleados()
BEGIN
    SELECT nombre, salario FROM empleados;
END //

DELIMITER ;

-- ======================================================
-- TRIGGER
-- ======================================================

CREATE TABLE auditoria (
    id INT AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(255),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

CREATE TRIGGER trigger_insert_empleado
AFTER INSERT ON empleados
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (descripcion)
    VALUES (CONCAT('Se insertó empleado: ', NEW.nombre));
END //

DELIMITER ;

-- ======================================================
-- EVENTO
-- ======================================================

SET GLOBAL event_scheduler = ON;

CREATE EVENT evento_salarios
ON SCHEDULE EVERY 1 DAY
DO
UPDATE empleados SET salario = salario * 1.01;

-- ======================================================
-- CUBO DE INFORMACION
-- ======================================================

CREATE VIEW cubo_salarios AS
SELECT departamento,
       COUNT(*) AS total_empleados,
       SUM(salario) AS total_salarios
FROM empleados
GROUP BY departamento;

-- ======================================================
-- FUNCIONES AGREGADAS (RESUMEN GENERAL)
-- ======================================================

CREATE VIEW resumen_general AS
SELECT 
    COUNT(*) AS total_empleados,
    SUM(salario) AS suma_salarios,
    AVG(salario) AS promedio_salario,
    MAX(salario) AS salario_maximo,
    MIN(salario) AS salario_minimo
FROM empleados;

-- ======================================================
-- PARTICION RANGE
-- ======================================================

CREATE TABLE empleados_range (
    id INT,
    nombre VARCHAR(100),
    salario DECIMAL(10,2),
    departamento VARCHAR(50),
    fecha_ingreso DATE
)
PARTITION BY RANGE (YEAR(fecha_ingreso)) (
    PARTITION p2019 VALUES LESS THAN (2020),
    PARTITION p2021 VALUES LESS THAN (2022),
    PARTITION pmax VALUES LESS THAN MAXVALUE
);

INSERT INTO empleados_range VALUES
(1,'Luis',2000000,'Ventas','2019-05-01'),
(2,'Sofia',3000000,'Marketing','2021-07-01');

-- ======================================================
-- PARTICION HASH
-- ======================================================

CREATE TABLE empleados_hash (
    id INT,
    nombre VARCHAR(100),
    salario DECIMAL(10,2),
    departamento VARCHAR(50),
    fecha_ingreso DATE
)
PARTITION BY HASH(id)
PARTITIONS 4;

INSERT INTO empleados_hash VALUES
(1,'Mario',2100000,'TI','2020-01-01'),
(2,'Elena',2200000,'RRHH','2021-01-01'),
(3,'Andres',2300000,'TI','2022-01-01'),
(4,'Paula',2400000,'Finanzas','2023-01-01');