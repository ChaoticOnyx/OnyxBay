var/DBConnection/dbcon = new()
world
	proc
		startmysql(var/silent)
			dbcon.Connect("dbi:mysql:[DB_DBNAME]:[DB_SERVER]:3306","[DB_USER]","[DB_PASSWORD]")
			if(!dbcon.IsConnected()) world << dbcon.ErrorMsg()
			else
				if(!silent)
					world << "\red \b Mysql connection established..."
				keepalive()
		keepalive()
			spawn while(1)
				sleep(200)
				var/DBQuery/key_query = dbcon.NewQuery("SELECT * FROM ADMINS")
				if(!dbcon.IsConnected())
					dbcon.Connect("dbi:mysql:[DB_DBNAME]:[DB_SERVER]:3306","[DB_USER]","[DB_PASSWORD]")


