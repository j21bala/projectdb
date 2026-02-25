@echo off
set CONTAINER=municipiosdb
set ROOTPASS=root123
set DBNAME=colombia
set PORT=8181
set CSV_PATH=C:\Users\USUARIO\Downloads\DIVIPOLA-_C_digos_municipios.csv

echo ======================================
echo Iniciando Docker Desktop
echo ======================================
start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
timeout /t 15 >nul

echo ======================================
echo Eliminando contenedor anterior
echo ======================================
docker rm -f %CONTAINER% >nul 2>&1

echo ======================================
echo Creando contenedor MariaDB
echo ======================================
docker run -d ^
--name %CONTAINER% ^
-p %PORT%:3306 ^
-e MYSQL_ROOT_PASSWORD=%ROOTPASS% ^
-e MYSQL_DATABASE=%DBNAME% ^
-v "%CSV_PATH%:/data/divipola.csv" ^
mariadb:latest

echo ======================================
echo Esperando que MariaDB este listo
echo ======================================

:waitloop
docker exec %CONTAINER% mariadb -uroot -p%ROOTPASS% -e "SELECT 1;" >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    timeout /t 2 >nul
    goto waitloop
)

echo MariaDB esta listo.

echo ======================================
echo Creando tablas
echo ======================================

docker exec %CONTAINER% mariadb -uroot -p%ROOTPASS% %DBNAME% -e "CREATE TABLE departamentos (codigo_departamento INT PRIMARY KEY, nombre VARCHAR(100));"

docker exec %CONTAINER% mariadb -uroot -p%ROOTPASS% %DBNAME% -e "CREATE TABLE municipios (codigo_municipio INT PRIMARY KEY, nombre VARCHAR(150), codigo_departamento INT, tipo VARCHAR(100), longitud VARCHAR(30), latitud VARCHAR(30), FOREIGN KEY (codigo_departamento) REFERENCES departamentos(codigo_departamento));"

docker exec %CONTAINER% mariadb -uroot -p%ROOTPASS% %DBNAME% -e "CREATE TABLE temp_import (codigo_departamento INT, nombre_departamento VARCHAR(100), codigo_municipio INT, nombre_municipio VARCHAR(150), tipo VARCHAR(100), longitud VARCHAR(30), latitud VARCHAR(30));"

echo ======================================
echo Habilitando local_infile
echo ======================================

docker exec %CONTAINER% mariadb -uroot -p%ROOTPASS% -e "SET GLOBAL local_infile=1;"

echo ======================================
echo Importando CSV
echo ======================================

docker exec %CONTAINER% mariadb --local-infile=1 -uroot -p%ROOTPASS% %DBNAME% -e "LOAD DATA LOCAL INFILE '/data/divipola.csv' INTO TABLE temp_import CHARACTER SET utf8mb4 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;"

echo ======================================
echo Insertando datos reales
echo ======================================

docker exec %CONTAINER% mariadb -uroot -p%ROOTPASS% %DBNAME% -e "INSERT IGNORE INTO departamentos SELECT DISTINCT codigo_departamento, nombre_departamento FROM temp_import;"

docker exec %CONTAINER% mariadb -uroot -p%ROOTPASS% %DBNAME% -e "INSERT IGNORE INTO municipios SELECT codigo_municipio, nombre_municipio, codigo_departamento, tipo, longitud, latitud FROM temp_import;"

docker exec %CONTAINER% mariadb -uroot -p%ROOTPASS% %DBNAME% -e "DROP TABLE temp_import;"

echo ======================================
echo Verificando totales
echo ======================================

docker exec %CONTAINER% mariadb -uroot -p%ROOTPASS% %DBNAME% -e "SELECT COUNT(codigo_municipio) AS TOTAL_MUNICIPIOS FROM municipios;"
docker exec %CONTAINER% mariadb -uroot -p%ROOTPASS% %DBNAME% -e "SELECT COUNT(codigo_departamento) AS TOTAL_DEPARTAMENTOS FROM departamentos;"

echo.
echo ======================================
echo Conexion para VSCode
echo Host: localhost
echo Puerto: %PORT%
echo Usuario: root
echo Password: %ROOTPASS%
echo Base de datos: %DBNAME%
echo ======================================

echo.
echo ======================================
echo Abriendo Visual Studio Code
echo ======================================

start "" "C:\Users\USUARIO\AppData\Local\Programs\Microsoft VS Code\Code.exe"

pause