
-- ======================================================
-- VISTAS
-- ======================================================
-- Empleado por departamento

CREATE VIEW vista_empleados_departamento AS
SELECT e.nombres,
       e.apellidos,
       d.departamento_nombre
FROM empleados e
JOIN departamentos d 
ON e.departamento_id = d.departamento_id;

SELECT * FROM vista_empleados_departamento;

-- Empleado por país

CREATE VIEW vista_empleados_pais AS
SELECT e.nombres,
       e.apellidos,
       p.pais_nombre
FROM empleados e
JOIN departamentos d ON e.departamento_id = d.departamento_id
JOIN ubicaciones u ON d.ubicacion_id = u.ubicacion_id
JOIN paises p ON u.pais_id = p.pais_id;

SELECT * FROM vista_empleados_pais;

-- Empleados con salario mayor a 5000

CREATE VIEW vista_salario_mayor_5000 AS
SELECT empleado_id, nombres, apellidos, salario
FROM empleados
WHERE salario > 5000;

SELECT * FROM vista_salario_mayor_5000;

-- Departamentos por ciudad

CREATE VIEW vista_departamentos_ciudad AS
SELECT d.departamento_nombre,
       u.ciudad
FROM departamentos d
JOIN ubicaciones u ON d.ubicacion_id = u.ubicacion_id;

SELECT * FROM vista_departamentos_ciudad;

-- ======================================================
-- INDICE
-- ======================================================

CREATE INDEX index_empleados
ON empleados(nombres, apellidos);

CREATE INDEX idx_emp_dep_sal
ON empleados(departamento_id, salario);

CREATE INDEX idx_dep_ubicacion_nombre
ON departamentos(ubicacion_id, departamento_nombre);