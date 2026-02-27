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



/* =====================================================
   1 EVENTO
===================================================== */

/* Escenario: aumentar 3% a salarios menores de 4000 cada minuto */
CREATE EVENT evento_aumento_bajo_salario
ON SCHEDULE EVERY 1 MINUTE
DO
UPDATE empleados
SET salario = salario * 1.03
WHERE salario < 4000;




/* Ver eventos */
SHOW EVENTS;


SELECT empleado_id, nombres, salario
FROM empleados
WHERE salario < 4000;



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