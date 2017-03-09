#!/bin/bash

clear

echo "================================================================="
echo "            ¡¡El ultra-instalador de WordPress!!"
echo "================================================================="

# Usuario de WordPress
echo "Usuario de WordPress: "
read -e wpuser
# Nombre de la base de datos
echo "Nombre DB: "
read -e dbname

# Usuario de la base de datos
echo "Usuario DB: "
read -e dbuser

# Contraseña base de datos
echo "Contraseña DB: "
read -e dbpass

# Nombre del sitio
echo "Nombre del sitio: "
read -e sitename

# url de la pagina
echo "Direccion del sitio (sin http://): "
read -e url

# Crear páginas
echo "Crear número de páginas: "
read -e allpages

# idioma de la instalacion. Por defecto es_ES
echo "Lenguaje de la instalación(es_ES por defecto)"
read -e lengua

if [ "$lengua" = "" ]; then
	lengua="es_ES"
fi

# Confirmación para la instalación
echo "¿Instalar? (s/n)"
read -e run

# Si dice que n, se sale del if
if [ "$run" == n ] ; then
exit
else

# descargar WordPress
wp core download --locale=$lengua --force

# Crear el wp-config con los datos proporcionados
wp core config --force --dbname=$dbname --dbuser=$dbuser --dbpass=$dbpass --extra-php <<PHP
define( 'WP_DEBUG', true );
define( 'DISALLOW_FILE_EDIT', true );
PHP

# parse the current directory name
currentdirectory=${PWD##*/}

# genera una contraseña aleatoria de 12 caracteres
password=$(LC_CTYPE=C tr -dc A-Za-z0-9_\!\@\#\$\%\^\&\*\(\)-+= < /dev/urandom | head -c 12)

# copy password to clipboard
#echo $password | pbcopy


#instalar el WordPress
wp core install --url="http://$url/" --title="$sitename" --admin_user="$wpuser" --admin_password="$password" --admin_email="user@example.org"

# disuade de los motores de búsqueda
wp option update blog_public 0

echo "Mostrar sólo 6 post por página"
wp option update posts_per_page 6

echo "Borrar la página de ejemplo y crear una página Home"
wp post delete $(wp post list --post_type='page' --post_status=publish --format=ids)
wp post create --post_type=page --post_title=Home --post_status=publish --post_author=$(wp user get $wpuser --field=ID --format=ids)

echo "Poner como inicio una página estática"
wp option update show_on_front 'page'

echo "Poner la página creada como páina de inicio"
wp option update page_on_front $(wp post list --post_type=page --post_status=publish --posts_per_page=1 --pagename=home --field=ID --format=ids)

# Crear las páginas
# export IFS=","
for page in $allpages; do
    wp post create --post_type=page --post_status=publish --post_author=$(wp user get $wpuser --field=ID --format=ids) --post_title="$(echo $page)"
done

# enlaces permanentes
wp rewrite structure '/%postname%/' --hard
wp rewrite flush --hard

# eliminar hello dolly
wp plugin delete hello

# instalar plugin tinymce-advanced
wp plugin install tinymce-advanced --activate

# instalar un started theme del directorio
wp theme install start --activate

#clear

# Menú
wp menu create "Menu principal"

# añadir las páginas al menú
export IFS=" "
for pageid in $(wp post list --order="ASC" --orderby="date" --post_type=page --post_status=publish --posts_per_page=-1 --field=ID --format=ids); do
    wp menu item add-post main-navigation $pageid
done

# el menú creado lo asignams como menú primario
wp menu location assign main-navigation primary

#clear

echo "==========================================================================="
echo "Instalacion completada. Apunta tu usuario y contraseña."
echo ""
echo "Usuario: $wpuser"
echo "Contraseña: $password"
echo "Entrar a Ajustes-Enlaces permanentes y guardar para regenerar el .htaccess"
echo "==========================================================================="

fi