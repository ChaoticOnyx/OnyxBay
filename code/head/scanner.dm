obj/machinery/scanner
	name = "Scanner"
	var/outputdir = 0
	icon = 'computer.dmi'
	icon_state = "aiupload"
	density = 1
	anchored = 1
	var/lastuser = null
obj/machinery/scanner/New()
	if(!outputdir)
		switch(dir)
			if(1)
				outputdir = 2
			if(2)
				outputdir = 1
			if(4)
				outputdir = 8
			if(8)
				outputdir = 4
		if(!outputdir)
			outputdir = 8
obj/machinery/scanner/attack_hand(mob/user)
	if(!ishuman(user) || lastuser == user.real_name)
		return
	lastuser = user.real_name
	var/mname = user.real_name
	var/dna = user.dna.unique_enzymes
	var/bloodtype = user:b_type
	var/fingerprint = md5(user.dna.uni_identity)
	var/list/marks = list()
	var/DBQuery/cquery = dbcon.NewQuery("SELECT * from jobban WHERE ckey='[user.ckey]'")
	if(!cquery.Execute()) return
	else
		while(cquery.NextRow())
			var/list/row = cquery.GetRowData()
			marks += row["rank"]
	var/text = {"
	<center>Report</center><br>
	Name:[mname]<br>
	DNA:[dna]<br>
	Blood Type:[bloodtype]<br>
	Fingerprint:[fingerprint]<br>

	Black Marks<br> "}
	for(var/A in marks)
		text += "\red[A]<br>"
	user << "\blue You feel a sting"
	var/turf/T = get_step(src,outputdir)
	var/obj/item/weapon/paper/print = new(T)
	print.name = "[mname] Report"
	print.info = text
	print.stamped = 1
