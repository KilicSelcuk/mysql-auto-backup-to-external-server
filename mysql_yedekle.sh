#!/bin/sh
# SORUCEVAP.com
echo "****************************"
echo "****************************"
echo "****************************"
echo "****************************"
echo "****************************"
echo "****************************"
echo "******** SORUCEVAP.COM *********"
echo "******** SORUCEVAP.COM *********"
echo "******** SORUCEVAP.COM *********"
echo "****************************"
echo "****************************"
echo "****************************"
echo "****************************"
echo "****************************"
echo "****************************"


#
# Cronjop ile her gun duzenli araliklarla yedek almasini saglayin. Asagidaki satir gunde 1 kere (gece saat 01:01) yedek almanizi saglar.
#
# crontab -e
# i harfine basarak yazim moduna gecin.
# asagidaki satiri kopyalayin ve en alt satira ekleyin
# 1 1 * * * sh /root/mysql_yedekle.sh
# esc basin ve yazim modundan cikin
# :wq yazip enter yapin 
#

# Sadece asagidaki 3 alani duzenlemeniz yeterli. Sadece sifreyi duzenlesenizde yeterli olacaktir.
mysql_kullanici_adi="MYSQL_KULLANICI_ADI"
mysqlsifreniz="MYSQL_KULLANICI_SIFRESI"

mysql_ana_yedek_klasoru="/home/mysql_yedek" # degistirmesenizde olur. :)
mysql_sql_yedek_klasoru_ismi="sql_yedekler" # degistirmesenizde olur. :)



#karsi yedekleme sunucusu ayarlari
#Bu kismi kullanmak istemiyorsaniz "yedek_sunucu_ip" alanini bos birakin.. O zaman yedekleri mysql sunucusunda mysql_ana_yedek_klasoru alaninda belirttiginiz yere kaydeder.
yedek_sunucu_ip="" # SUNUCU IP SI YADA BOS BIRAKIN (KULLANMAYACAKSANIZ)
yedek_sunucu_kullanici="root"
yedek_sunucu_sifresi="YEDEK_SUNUCU_SIFRESI"
yedek_sunucu_yuklenecek_yer="/home/"


mysql_sql_yedek_klasoru="$mysql_ana_yedek_klasoru/$mysql_sql_yedek_klasoru_ismi"
tarih=`date +"%d.%m.%Y"`
zaman=`date +"%d.%m.%Y-%T"`

echo "home dizininde $mysql_sql_yedek_klasoru klasoru var mi."
if [ -d $mysql_sql_yedek_klasoru ]; then
echo "home dizininde $mysql_sql_yedek_klasoru klasoru var."
else
echo "home dizininde $mysql_sql_yedek_klasoru klasoru yok ama simdi olusturuyorum."

	if [ -d $mysql_ana_yedek_klasoru ]; then
		mkdir $mysql_sql_yedek_klasoru
		echo "mysql_yedek ve sql_yedek klasorleri olusturuldu."
	else
		mkdir $mysql_ana_yedek_klasoru
		mkdir $mysql_sql_yedek_klasoru
		echo "sql_yedek klasoru olusturuldu."
	fi
fi


#eski yedekler icin klasor olusturulur
if [ -d $mysql_ana_yedek_klasoru/eski_yedekler ]; then
rm -rf $mysql_ana_yedek_klasoru/eski_yedekler/*
 echo "eski_yedekler klasoru bosaltildi"
 
 ##Onceki yedekleri, eski_yedekler klasorune tasiriz.
 echo "onceki yedekler, eski_yedekler klasorune tasinir."
 mv $mysql_sql_yedek_klasoru/* $mysql_ana_yedek_klasoru/eski_yedekler/


echo "Eski yedekler klasoru bosaltildi"
else
 mkdir $mysql_ana_yedek_klasoru/eski_yedekler
 echo "eski_yedekler klasoru olusturuldu"
 
 ##Onceki yedekleri, eski_yedekler klasorune tasiriz.
 echo "onceki yedekler, eski_yedekler klasorune tasinir."
 mv $mysql_sql_yedek_klasoru/* $mysql_ana_yedek_klasoru/eski_yedekler/

fi


# tarih klasoru olustururuz. Boylece her gun alinan yedekler ayni klasorde depolanir.
if [ -d $mysql_sql_yedek_klasoru/$tarih ]; then
rm -rf $mysql_sql_yedek_klasoru/$tarih/*
echo
else
 mkdir $mysql_sql_yedek_klasoru/$tarih
fi




	echo "......."
	echo "......."
	echo "......."
	echo "......."
	echo "SQL yedek almaya basliyor"
	echo "......."
	echo "......."
	echo "......."
	echo "......."
find /var/lib/mysql/ -type d | cut -d. -f1 | cut -d/ -f5 > $mysql_sql_yedek_klasoru/$tarih/list
_db="$(gawk -F: '{ print $1 }' $mysql_sql_yedek_klasoru/$tarih/list)"
for u in $_db
do

sshpass -p $mysqlsifreniz mysqldump -u $mysql_kullanici_adi -p$1 ${u} > $mysql_sql_yedek_klasoru/$tarih/$zaman-${u}.sql
echo "YEDEKLENDI > $mysql_sql_yedek_klasoru/$tarih/$zaman-${u}"
done

	echo "......."
	echo "......."
	echo "......."
	echo "......."
		echo "VERITABANLARI SQL FORMATINDA YEDEKLENDI: $mysql_sql_yedek_klasoru/$tarih"
	echo "......."
	echo "......."
	echo "......."
	echo "......."
	
	
	echo "......."
	echo "......."
	echo "......."
	echo "......."
		echo "SQL formatindaki butun veritabanlari tar.gz formatinda tek dosyada birlestiriliyor (ayri olarak).."
	echo "......."
	echo "......."
	echo "......."
	echo "......."
	
tar cvzf $mysql_ana_yedek_klasoru/$zaman-mysql.tar.gz $mysql_sql_yedek_klasoru/$tarih

	echo "......."
	echo "......."
	echo "......."
	echo "......."
		echo "tar.gz formatinda birlestirme bitti. Simdi tar.gz formatindaki yedegi tarihsel klasore tasiyoruz."
	echo "......."
	echo "......."
	echo "......."
	echo "......."
mv $mysql_ana_yedek_klasoru/$zaman-mysql.tar.gz $mysql_sql_yedek_klasoru/$tarih/$zaman-mysql.tar.gz

	echo "......."
	echo "......."
	echo "......."
	echo "......."
		echo "TUM VERI TABANLARI tar.gz formatinda YEDEKLENDI: $mysql_ana_yedek_klasoru/$tarih/$zaman-mysql.tar.gz"
	echo "......."
	echo "......."
	echo "......."
	echo "......."

if [ -z $yedek_sunucu_ip ]; then
echo "Yedekleme aktif edilmedigi icin ayri bir sunucuya gonderilmedi."
else
	echo "......."
	echo "......."
	echo "......."
	echo "......."
		echo "Simdi mysql yedeklerini, belirledigmiz yedek sunucuya gonderiyoruz (rsync)"
	echo "......."
	echo "......."
	echo "......."
	echo "......."
	
	ssh-keyscan -t rsa $yedek_sunucu_ip >> ~/.ssh/known_hosts
	sshpass -p $yedek_sunucu_sifresi rsync -avzu -t -l $mysql_ana_yedek_klasoru $yedek_sunucu_kullanici@$yedek_sunucu_ip:$yedek_sunucu_yuklenecek_yer

	echo "......."
	echo "......."
	echo "......."
	echo "......."
		echo "Yedekleme islemide bitti.."
	echo "......."
	echo "......."
	echo "......."
	echo "......."
	
	echo "......."
	echo "......."
	echo "......."
	echo "......."
	echo "Eski dosyalar silinmeye basliyor (son yedek haric)"
	echo "......."
	echo "......."
	echo "......."
	echo "......."
		rm -rf $mysql_ana_yedek_klasoru/eski_yedekler/*
	echo "......."
	echo "......."
	echo "......."
	echo "......."
	echo "Silme islemi basarili"
	echo "......."
	echo "......."
	echo "......."
	echo "......."
	
fi

echo "****************************"
echo "****************************"
echo "****************************"
echo "****************************"
echo "****************************"
echo "****************************"
echo "******** SORUCEVAP.COM *********"
echo "******** SORUCEVAP.COM *********"
echo "******** SORUCEVAP.COM *********"
echo "****************************"
echo "****************************"
echo "****************************"
echo "****************************"
echo "****************************"
echo "****************************"
