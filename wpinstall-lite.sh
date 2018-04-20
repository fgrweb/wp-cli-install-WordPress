#!/bin/bash

clear

echo "   ____  _    _ ___     ________          _    _   _____             "
echo "  / __ \| |  | | \ \   / /  ____|   /\   | |  | | |  __ \            "
echo " | |  | | |__| | |\ \_/ /| |__     /  \  | |__| | | |  | | _____   __"
echo " | |  | |  __  | | \   / |  __|   / /\ \ |  __  | | |  | |/ _ \ \ / /"
echo " | |__| | |  | |_|  | |  | |____ / ____ \| |  | | | |__| |  __/\ V / "
echo "  \____/|_|  |_(_)  |_|  |______/_/    \_\_|  |_| |_____/ \___| \_/  "
echo "                                                                     "


echo "================================================================="
echo "            ¡¡El ultra-instalador de WordPress!!"
echo "              Vamos a instalar un WordPress en  segundos"
echo "================================================================="
echo " Pulsa intro para continuar..."
read cont

# Usuario de WordPress
echo "Bien, ¡vamos allá!"
echo ""
echo "Indicar nombre de usuario para el administrador del sitio: "
read  wpuser
echo "Indica el correo electrónico del administrador"
read  wpusremail

# Nombre de la base de datos
echo "BASE DE DATOS"
echo "servido para la base de datos (por defecto localhost)"
read  dbhost
if [ "$dbhost" = "" ]
then
    dbhost="localhost"
fi
echo "Nombre de la Base de Datos: "
read  dbname

# Usuario de la base de datos
echo "Usuario de la Base de Datos: "
read  dbuser

# Contraseña base de datos
echo "Contraseña de la Base de Datos: "
read  dbpass

# Prefijo de las tablas
echo "Prefijo para las tablas: "
read  dbprefix

# Nombre del sitio
echo "Nombre del sitio: "
read  sitename

# url de la pagina
echo "URL del sitio: "
read  url

# Crear páginas
echo "Crear número de páginas de ejemplo: "
read  allpages

# idioma de la instalacion. Por defecto es_ES
echo "Lenguaje de la instalación(es_ES por defecto)"
read  lengua

if [ "$lengua" = "" ]
then
	lengua="es_ES"
fi

# Confirmación para la instalación
echo "Se creará una instalación de WordPress con los siguientes datos:"
echo "BASE DE DATOS"
echo "Host de la base de datos: "$dbhost
echo "Nombre de la base de datos: "$dbname
echo "Usuario de la base de datos: "$dbuser
echo "Prefijo para las tablas: "$dbprefix
echo ""
echo "DATOS WORDPRESS"
echo "Nombre del sitio: "$sitename
echo "URL del sitio: "$url
echo "Idioma de la instalacion: "$lengua
echo "Usuario administrador del sitio: "$wpuser" (Nota: la contraseña se generará automáticamente)"
echo "Correo electrónido del administrador"$wpusremail
echo "Revisa bien los datos antes de la instalación"
echo "¿Instalar? (s/n)"
read  run

# Si dice que n, se sale del if
if [ "$run" = "n" ] 
then
    echo "Hasta la vista!!"
    exit
else
    # descargar WordPress
    wp core download --locale=$lengua --force

    # Crear el wp-config con los datos proporcionados
    wp core config --force --dbname=$dbname --dbuser=$dbuser --dbpass=$dbpass --extra-php <<PHP
define( 'WP_DEBUG', true );
define( 'DISALLOW_FILE_EDIT', true );
PHP
    # Cambiar los permisos a wp-config
    chmod 644 wp-config.php

    # Instalación del WordPress
    # genera una contraseña aleatoria de 12 caracteres
    password=$(LC_CTYPE=C tr -dc A-Za-z0-9_\!\@\#\$\%\^\&\*\(\)-+= < /dev/urandom | head -c 12)
    wp core install --url="$url" --title="$sitename" --admin_user="$wpuser" --admin_password="$password" --admin_email="$wpusremail"

    # disuade de los motores de búsqueda
    wp option update blog_public 0

    # Instalar el plugin WP Task After Install: https://es.wordpress.org/plugins/wp-tasks-after-install/
    wp plugin install wp-tasks-after-install --activate
    # Ahora lo desactivamos y lo borramos
    wp plugin uninstall wp-task-after-install --deactivate

    # Crear las páginas de ejemplo que nos ha indicado
    wp post create --post_type=page --post_status=publish --post_author=$(wp user get $wpuser --field=ID --format=ids)

    
    echo "Pulsa una tecla para salir..."
    read cont
fi
