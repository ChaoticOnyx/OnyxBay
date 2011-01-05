mob/proc/add_stat(type,add)
	if (ismob(src) && src.key)
		var/hassave = 0
		var/DBQuery/cquery = dbcon.NewQuery("SELECT `ckey` FROM `stats` WHERE ckey='[src.ckey]'")
		if(!cquery.Execute())
			message_admins(cquery.ErrorMsg())
			debug(cquery.ErrorMsg())
		else
			while(cquery.NextRow())
				var/list/column_data = cquery.GetRowData()
				var/lawl = column_data["ckey"]
				if(src.ckey == lawl)
					hassave = 1
		var/roundplayed = 0
		var/deaths = 0
		var/suicides = 0
		var/traitorwin = 0
		if(hassave)
			var/DBQuery/xquery = dbcon.NewQuery("SELECT * FROM `stats` WHERE ckey='[src.ckey]'")
			if(!xquery.Execute())
				message_admins(xquery.ErrorMsg())
				debug(xquery.ErrorMsg())
				return
			else
				while(xquery.NextRow())
					var/list/column_data = xquery.GetRowData()
					roundplayed = text2num(column_data["roundsplayed"])
					deaths = text2num(column_data["deaths"])
					suicides = text2num(column_data["suicide"])
					traitorwin = text2num(column_data["traitorwin"])
				switch(type)
					if(1)
						roundplayed += add
					if(2)
						deaths += add
					if(3)
						suicides += add
					if(4)
						traitorwin += add
				var/DBQuery/rquery = dbcon.NewQuery("REPLACE INTO `stats` (`ckey`, `deaths`, `roundsplayed`, `suicides`,`traitorwin` ) VALUES ('[src.ckey]', '[deaths]' , '[roundplayed]', '[suicides]','[traitorwin]');")
				if(!rquery.Execute())
					message_admins(rquery.ErrorMsg())
					debug(rquery.ErrorMsg())
					return
		else
			switch(type)
				if(1)
					roundplayed += add
				if(2)
					deaths += add
				if(3)
					suicides += add
				if(4)
					traitorwin += add
			var/DBQuery/rquery = dbcon.NewQuery("REPLACE INTO `stats` (`ckey`, `deaths`, `roundsplayed`, `suicides`,`traitorwin` ) VALUES ('[src.ckey]', '[deaths]' , '[roundplayed]', '[suicides]','[traitorwin]');")
			if(!rquery.Execute())
				message_admins(rquery.ErrorMsg())
				debug(rquery.ErrorMsg())
				return