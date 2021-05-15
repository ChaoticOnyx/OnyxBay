/client/proc/checkAccount()
	set name = "Check multiaccounts"
	set category = "Admin"

	if(!holder) return
	switch(alert("Chose checktype",,"All","Select player","Type ckey","Cancel"))
		if("All")
			holder.checkAllAccounts()
		if("Select player")
			var/targets = list()
			var/list/mobs = sortmobs()
			for(var/mob/M in mobs)
				if(M.ckey) targets += "[M.ckey]"
			holder.showAccounts(input("Select ckey", "Ckey") in targets)
		if("Type ckey")
			var/target = ckey(input(usr, "Type in ckey for check.", "Ckey") as text|null)
			if(!target) //Cancel works now
				return
			holder.showAccounts(target)

/datum/admins/proc/showAccounts(targetkey)
	var/size = 0
	var/output = "<meta charset=\"utf-8\"><center><table border='1'> <caption>Matching computerID</caption><tr> <th width='100px' >ckey</th><th width='100px'>firstseen</th><th width='100px'>lastseen</th><th width='100px'>ip</th><th width='100px'>computerid </th></tr>"

	var/DBQuery/query = dbcon.NewQuery("SELECT ckey,firstseen,lastseen,ip,computerid FROM erro_player WHERE computerid IN (SELECT DISTINCT computerid FROM erro_player WHERE ckey LIKE '[targetkey]')")
	query.Execute()
	while(query.NextRow())
		size += 1
		output+="<tr><td>[query.item[1]]</td>"
		output+="<td>[query.item[2]]</td>"
		output+="<td>[query.item[3]]</td>"
		output+="<td>[query.item[4]]</td>"
		output+="<td>[query.item[5]]</td></tr>"

	output+="</table>"

	output += "<center><table border='1'> <caption>Matching IP</caption><tr> <th width='100px' >ckey</th><th width='100px'>firstseen</th><th width='100px'>lastseen</th><th width='100px'>ip</th><th width='100px'>computerid </th></tr>"

	query = dbcon.NewQuery("SELECT ckey,firstseen,lastseen,ip,computerid FROM erro_player WHERE ip IN (SELECT DISTINCT ip FROM erro_player WHERE computerid IN (SELECT DISTINCT computerid FROM erro_player WHERE ckey LIKE '[targetkey]'))")
	query.Execute()
	while(query.NextRow())
		size += 1
		output+="<tr><td>[query.item[1]]</td>"
		output+="<td>[query.item[2]]</td>"
		output+="<td>[query.item[3]]</td>"
		output+="<td>[query.item[4]]</td>"
		output+="<td>[query.item[5]]</td></tr>"

	output+="</table></center>"



	show_browser(usr, output, "window=accaunts;size=600x[size*50+100]")

/datum/admins/proc/checkAllAccounts()
	var/DBQuery/query
	var/t1 = ""
	var/output = "<meta charset=\"utf-8\"><B>Matching IP</B><BR><BR>"

	for (var/client/C in GLOB.clients)
		t1 =""
		query = dbcon.NewQuery("SELECT ckey FROM erro_player WHERE ip IN (SELECT DISTINCT ip FROM erro_player WHERE computerid IN (SELECT DISTINCT computerid FROM erro_player WHERE ckey LIKE '[C.ckey]'))")
		query.Execute()
		var/c = 0

		while(query.NextRow())
			c++
			t1 +="[c]: - [query.item[1]]<BR>"
		if (c > 1)
			output+= "Ckey: [C.ckey] <A href='?_src_=holder;showmultiacc=[C.ckey]'>Show</A><BR>" + t1

	output+= "<BR><BR><B>Matching computerID</B><BR><BR>"

	for (var/client/C in GLOB.clients)
		t1 =""
		query = dbcon.NewQuery("SELECT ckey FROM erro_player WHERE computerid IN (SELECT DISTINCT computerid FROM erro_player WHERE ckey LIKE '[C.ckey]'))")
		query.Execute()
		var/c = 0
		while(query.NextRow())
			c++
			t1 +="[c]: [query.item[1]]<BR>"
		if (c > 1)
			output+= "Ckey: [C.ckey] <A href='?_src_=holder;showmultiacc=[C.ckey]'>Show</A><BR>" + t1

	output+= "<BR><BR><B>Matching cookies</B><BR><BR>"

	for (var/msg in GLOB.cookie_match_history)
		output+= "Ckey: [msg["ckey"]] Matched: [msg["banned"]] <A href='?_src_=holder;showmultiacc=[msg["ckey"]]'>Show</A><BR>"

	show_browser(usr, output, "window=accauntsall;size=400x800")
