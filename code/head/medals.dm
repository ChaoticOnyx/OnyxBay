/mob/proc/unlock_medal(title, announce, desc, diff)

	spawn ()
		if (ismob(src) && src.key)
		//	var/list/keys = list()
			var/DBQuery/cquery = dbcon.NewQuery("SELECT `medal` FROM `medals` WHERE ckey='[src.ckey]'")
			if(!cquery.Execute())
				message_admins(cquery.ErrorMsg())
				debug(cquery.ErrorMsg())
			else
				while(cquery.NextRow())
					var/list/column_data = cquery.GetRowData()
					if(title == column_data["medal"])
						return
			var/medaldesc2 = dbcon.Quote(desc)
			var/tit2 = dbcon.Quote(title)
			var/DBQuery/xquery = dbcon.NewQuery("REPLACE INTO `medals` (`ckey`, `medal`, `medaldesc`, `medaldiff`) VALUES ('[src.ckey]', [tit2], [medaldesc2], '[diff]');")
			if(!xquery.Execute())
				message_admins(xquery.ErrorMsg())
				debug(xquery.ErrorMsg())
				src << "Medal save failed"
			var/H
			switch(diff)
				if ("medium")
					H = "#EE9A4D"
				if ("easy")
					H = "green"
				if ("hard")
					H = "red"
			if (announce)
				world << "<b>Achievement Unlocked!: [src.key] unlocked the '<font color = [H]>[title]</font color>' achievement.</b></font>"
				src << text("[desc]")
			else if (!announce)
				src << "<b>Achievement Unlocked!: You unlocked the '<font color = [H]>[title]</font color>' achievement.</b></font>"
				src << text("[desc]")

mob/verb/show_medal()
	set name = "Show Achievements"
	set category = "Commands"
	var/DBQuery/xquery = dbcon.NewQuery("SELECT `ckey` FROM `medals` WHERE ckey='[src.ckey]'")
	var/DBQuery/gquery = dbcon.NewQuery("SELECT * FROM `medals` WHERE ckey='[src.ckey]'")
	var/list/keys = list()
	if(xquery.Execute())
		while(xquery.NextRow())
			keys = xquery.GetRowData()
	else
		src << "You have no medals"
		message_admins(xquery.ErrorMsg())
		debug(xquery.ErrorMsg())
	if(gquery.Execute())
		while(gquery.NextRow())
			var/list/column_data = gquery.GetRowData()
			for(var/P in keys)
				var/title = column_data["medal"]
				var/desc = column_data["medaldesc"]
				var/diff = column_data["medaldiff"]
				var/H
				switch(diff)
					if ("medium")
						H = "#EE9A4D"
					if ("easy")
						H = "green"
					if ("hard")
						H = "red"
				src << "<font color = [H]>[title]</font color></b></font>"
				src << text("[desc]")