#!/bin/bash
cd /home/xubuntu/VM_SHARE/task
HOST='138.201.56.185'
USER='rekrut'
PASS='zI4wG9yM5krQ3d'

ftp -nv $HOST << DOWNLOAD
	ascii
	user $USER $PASS
	prompt
	get task.rar
	exit
DOWNLOAD

unrar e -o+ task.rar
sed -i 's/\t/;/g' weight.txt
sed -i 's/,/./g' deposit.csv
sed -i 's/,/./g' price.csv
sed -i 's/"//g' quantity.csv
mysql -u root -psql_pass --local-infile=1 << PROCESS
	USE task;
	
	LOAD DATA LOCAL INFILE 'data.csv'
	INTO TABLE data
	FIELDS TERMINATED BY ';'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;
	
	LOAD DATA LOCAL INFILE 'weight.txt'
	INTO TABLE weight
	FIELDS TERMINATED BY ';'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;
	
	LOAD DATA LOCAL INFILE 'deposit.csv'
	INTO TABLE deposit
	FIELDS TERMINATED BY ';'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;
	
	LOAD DATA LOCAL INFILE 'price.csv'
	INTO TABLE price
	FIELDS TERMINATED BY ';'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;
	
	LOAD DATA LOCAL INFILE 'quantity.csv'
	INTO TABLE quantity
	FIELDS TERMINATED BY ';'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;
PROCESS
mysql -u root -psql_pass -e "USE task; $(cat query.sql)" | sed 's/\t/;/g' > result.csv

ftp -nv $HOST << DOWNLOAD
	ascii
	user $USER $PASS
	prompt
	cd complete/Kruk
	put result.csv
	exit
DOWNLOAD