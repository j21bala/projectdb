SHOW DATABASES;

USE colombia;

SHOW TABLES;

DESCRIBE municipios;

SELECT COUNT(*) FROM municipios;

SELECT * FROM municipios LIMIT 10;

SELECT nombre_departamento, COUNT(*) AS total
FROM municipios
GROUP BY nombre_departamento
ORDER BY total DESC;

SELECT nombre_municipio
FROM municipios
WHERE nombre_departamento = 'ANTIOQUIA';

SELECT *
FROM municipios
WHERE nombre_municipio = 'MEDELLÍN';


-- Municipios que empiezan por A
SELECT nombre_municipio
FROM municipios
WHERE nombre_municipio LIKE 'A%';

-- Municipios que contienen "SAN"
SELECT nombre_municipio
FROM municipios
WHERE nombre_municipio LIKE '%SAN%';
