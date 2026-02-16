@echo off
set CONTAINER=projectdb
set ROOTPASS=root123
set DBNAME=colombia
set CSV=DIVIPOLA.csv

echo ================================
echo  INICIANDO PROYECTO COMPLETO
echo ================================

echo Verificando Docker...
docker info >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Docker no esta corriendo.
    start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    timeout /t 20
)

echo.
echo Creando contenedor Ubuntu...
docker inspect %CONTAINER% >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    docker run -dit --name %CONTAINER% ubuntu:22.04
)

docker start %CONTAINER% >nul 2>&1

echo.
echo Actualizando Ubuntu e instalando MariaDB...
docker exec %CONTAINER% bash -c "apt update && apt install -y mariadb-server mariadb-client"

echo.
echo Iniciando MariaDB...
docker exec %CONTAINER% service mariadb start

echo.
echo Configurando root...
docker exec %CONTAINER% bash -c "mysql -e \"ALTER USER 'root'@'localhost' IDENTIFIED BY '%ROOTPASS%'; FLUSH PRIVILEGES;\""

echo.
echo Creando base de datos...
docker exec %CONTAINER% bash -c "mysql -u root -p%ROOTPASS% -e \"CREATE DATABASE IF NOT EXISTS %DBNAME%;\""

echo.
echo Copiando CSV al contenedor...
docker cp %CSV% %CONTAINER%:/%CSV%

echo.
echo Creando tabla e importando datos...
docker exec %CONTAINER% bash -c "mysql -u root -p%ROOTPASS% %DBNAME% -e \"
CREATE TABLE IF NOT EXISTS municipios (
    codigo_departamento INT,
    nombre_departamento VARCHAR(100),
    codigo_municipio INT,
    nombre_municipio VARCHAR(100),
    tipo VARCHAR(150),
    longitud VARCHAR(20),
    latitud VARCHAR(20)
);
LOAD DATA INFILE '/%CSV%'
INTO TABLE municipios
FIELDS TERMINATED BY ','
ENCLOSED BY '\"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
\""

echo.
echo Abriendo VS Code...
start code .

echo.
echo Conectando a MariaDB...
docker exec -it %CONTAINER% mysql -u root -p%ROOTPASS% %DBNAME%

pause
