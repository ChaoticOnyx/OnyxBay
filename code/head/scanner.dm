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
obj/machinery/scanner/attack_hand(mob/living/carbon/human/user)
	if(!ishuman(user) || lastuser == user.real_name)
		return
	lastuser = user.real_name
	//var/datum/data/record/G = new /datum/data/record(  )
	var/mname = user.real_name
	var/dna = user.dna.unique_enzymes
	var/bloodtype = user.b_type
	var/fingerprint = md5(user.dna.uni_identity)
	var/list/marks = list()
	var/age = user.age
	var/gender = user.gender
	var/DBQuery/cquery = dbcon.NewQuery("SELECT * from jobban WHERE ckey='[user.ckey]'")
	if(!cquery.Execute()) return
	else
		while(cquery.NextRow())
			var/list/row = cquery.GetRowData()
			marks += row["rank"]
	var/text = {"
	<font size=4><center>Report</center></font><br>
	<b><u>Name</u></b>: [mname]
	<b><u>Age</u></b>: [age]
	<b><u>Sex</u></b>: [gender]
	<b><u>DNA</u></b>: [dna]
	<b><u>Blood Type</u></b>: [bloodtype]
	<b><u>Fingerprint</u></b>: [fingerprint]

	<b><u>Black Marks</u></b>:<br> "}
	for(var/A in marks)
		text += "\red[A]<br>"
	user << "\blue You feel a sting as the scanner sucks all your information out of you and sticks it in it's database."
	var/turf/T = get_step(src,outputdir)
	var/obj/item/weapon/paper/print = new(T)
	print.name = "[mname] Report"
	print.info = text
	print.stamped = 1

	var/datum/data/record/G = new /datum/data/record(  )
	G.fields["name"] = mname
	G.fields["id"] = text("[]", add_zero(num2hex(rand(1, 1.6777215E7)), 6))
	G.fields["rank"] = "Unassigned"
	G.fields["sex"] = gender
	G.fields["age"] = age
	G.fields["fingerprint"] = fingerprint
	G.fields["p_stat"] = "Active"
	G.fields["m_stat"] = "Stable"
	G.fields["b_type"] = bloodtype
	G.fields["bloodsample"] = dna
	var/duplicate_check = 0
	for(var/datum/data/record/test in data_core.general)
		if (test.fields["name"] == G.fields["name"])
			duplicate_check = 1
	if(!duplicate_check)
		data_core.general += G


