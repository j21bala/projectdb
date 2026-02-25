@echo off
set CONTAINER=sqlavanzado
set ROOTPASS=root123
set DBNAME=bdrh
set PORT=8282
set SQLFILE=%~dp0bdrh.sql

echo ======================================
echo INICIANDO DOCKER DESKTOP
echo ======================================

start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"

echo Esperando que Docker inicie...

:dockerwait
docker info >nul 2>&1
if errorlevel 1 (
    timeout /t 5 >nul
    goto dockerwait
)

echo Docker listo.

echo ======================================
echo DESCARGANDO IMAGEN MARIADB
echo ======================================
docker pull mariadb:11

echo ======================================
echo ELIMINANDO CONTENEDOR ANTERIOR
echo ======================================
docker rm -f %CONTAINER% >nul 2>&1

echo ======================================
echo CREANDO CONTENEDOR
echo ======================================
docker run -d ^
 --name %CONTAINER% ^
 -e MARIADB_ROOT_PASSWORD=%ROOTPASS% ^
 -p %PORT%:3306 ^
 mariadb:11

echo Esperando que MariaDB inicie...

:mariadbwait
docker exec %CONTAINER% mariadb -uroot -p%ROOTPASS% -e "SELECT 1" >nul 2>&1
if errorlevel 1 (
    timeout /t 3 >nul
    goto mariadbwait
)

echo MariaDB listo.

echo ======================================
echo CREANDO BASE DE DATOS
echo ======================================
docker exec -i %CONTAINER% mariadb -uroot -p%ROOTPASS% -e "CREATE DATABASE %DBNAME%;"

echo ======================================
echo IMPORTANDO BASE DE DATOS bdrh.sql
echo ======================================
docker exec -i %CONTAINER% mariadb -uroot -p%ROOTPASS% %DBNAME% < "%SQLFILE%"

echo ======================================
echo ENTORNO LISTO
echo ======================================
echo.
echo Conectate desde SQLTools con:
echo Host: localhost
echo Puerto: %PORT%
echo Usuario: root
echo Password: %ROOTPASS%
echo Base de datos: %DBNAME%
echo.

echo ======================================
echo ABRIENDO VISUAL STUDIO CODE
echo ======================================
start "" code

pause