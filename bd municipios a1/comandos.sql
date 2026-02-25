SELECT codigo_departamento, nombre
FROM departamentos;

SELECT codigo_municipio, nombre, tipo
FROM municipios;

SELECT 
    m.codigo_municipio,
    m.nombre AS municipio,
    d.nombre AS departamento
FROM municipios m
JOIN departamentos d
ON m.codigo_departamento = d.codigo_departamento;

SELECT 
    m.nombre,
    d.nombre
FROM municipios m
JOIN departamentos d
ON m.codigo_departamento = d.codigo_departamento
WHERE d.nombre = 'Antioquia';

SELECT 
    d.nombre,
    COUNT(m.codigo_municipio) AS total_municipios
FROM departamentos d
JOIN municipios m
ON d.codigo_departamento = m.codigo_departamento
GROUP BY d.nombre;

SELECT 
    d.nombre,
    COUNT(m.codigo_municipio) AS total_municipios
FROM departamentos d
JOIN municipios m
ON d.codigo_departamento = m.codigo_departamento
GROUP BY d.nombre
HAVING COUNT(m.codigo_municipio) > 50;

SELECT nombre, latitud
FROM municipios
WHERE latitud > 5;

SELECT codigo_municipio, nombre
FROM municipios
WHERE nombre LIKE 'San%';

SELECT nombre
FROM departamentos
WHERE codigo_departamento = (
    SELECT codigo_departamento
    FROM municipios
    GROUP BY codigo_departamento
    ORDER BY COUNT(codigo_municipio) DESC
    LIMIT 1
);

SELECT nombre
FROM municipios
WHERE codigo_departamento = (
    SELECT codigo_departamento
    FROM municipios
    GROUP BY codigo_departamento
    ORDER BY COUNT(codigo_municipio) DESC
    LIMIT 1
);

SELECT 
    d.nombre,
    AVG(m.latitud) AS promedio_latitud
FROM departamentos d
JOIN municipios m
ON d.codigo_departamento = m.codigo_departamento
GROUP BY d.nombre;