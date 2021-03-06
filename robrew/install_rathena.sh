root_pass="root"
ragnarok_db="ragnarok"
ragnarok_user="ragnarok"
ragnarok_pass="ragnarok"
echo ""
echo "[+] Installing depencies..."
echo ""
apt-get install git make gcc libmysqlclient-dev zlib1g-dev libpcre3-dev

echo ""
echo "[+] Installing mysql..."
echo ""
apt-get install mysql-server mysql-client
debconf-set-selections <<< 'mysql-server mysql-server/root_password password $root_pass'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password $root_pass'
apt-get -y install mysql-server

MYSQL=`which mysql`
  
Q1="CREATE DATABASE IF NOT EXISTS $ragnarok_db;"
Q2="GRANT USAGE ON $ragnarok_db.* TO $ragnarok_user@localhost IDENTIFIED BY '$ragnarok_pass';"
Q3="GRANT ALL PRIVILEGES ON $ragnarok_db.* TO $ragnarok_user@localhost;"
Q4="FLUSH PRIVILEGES;"
SQL="${Q1}${Q2}${Q3}${Q4}"

$MYSQL -uroot -p$root_pass -e "$SQL"

if [ ! -d ~/rAthena ]; then
echo ""
echo "[+] Downloading rAthena..."
echo ""
git clone https://github.com/rathena/rathena.git ~/rAthena
fi

echo ""
echo "[+] Importing sql schemas: main, logs..."
echo ""
$MYSQL -uroot -p$root_pass ragnarok < ~/rAthena/sql-files/main.sql
$MYSQL -uroot -p$root_pass ragnarok < ~/rAthena/sql-files/logs.sql


echo ""
echo "[+] Importing sql schemas: item dbs..."
echo ""
$MYSQL -uroot -p$root_pass ragnarok < ~/rAthena/sql-files/item_db.sql
$MYSQL -uroot -p$root_pass ragnarok < ~/rAthena/sql-files/item_db2.sql
$MYSQL -uroot -p$root_pass ragnarok < ~/rAthena/sql-files/item_db_re.sql
$MYSQL -uroot -p$root_pass ragnarok < ~/rAthena/sql-files/item_db2_re.sql

echo ""
echo "[+] Importing sql schemas: mob dbs..."
echo ""
$MYSQL -uroot -p$root_pass ragnarok < ~/rAthena/sql-files/mob_db.sql
$MYSQL -uroot -p$root_pass ragnarok < ~/rAthena/sql-files/mob_db2.sql
$MYSQL -uroot -p$root_pass ragnarok < ~/rAthena/sql-files/mob_db_re.sql
$MYSQL -uroot -p$root_pass ragnarok < ~/rAthena/sql-files/mob_db2_re.sql

echo ""
echo "[+] Compiling rAthena..."
echo ""
cd ~/rAthena && ./configure make clean && make sql

echo ""
echo "[+] Chmoding :) server bins..."
echo ""
chmod a+x login-server && chmod a+x char-server && chmod a+x map-server

echo ""
echo "[+] Done!"
echo ""