// SUPER PROTOTYPE SOMETHING BY HEAD
/obj/machinery/computer/database/
	name = "Employee Database"
	var/list/db = list()
	icon = 'washer.dmi'
	icon_state = "land01"
/obj/machinery/computer/database/proc/addentry(var/datum/data/row/R , mob/user)
	if(!R)
		return 0
	src.db += R
	return 1
/obj/machinery/computer/database/proc/getentry(var/names , mob/user)
	if(!src.db)
		return 0
	for(var/datum/data/row/R in src.db)
		if(name == names)
			return R
	return 0
/obj/machinery/computer/database/proc/delentry(var/names , mob/user)
	if(!src.db)
		return 0
	for(var/datum/data/row/R in src.db)
		if(name == names)
			src.db -= R
			del(R)
			return 1
	return 0
datum/data/row/employee
	name = "Unknown"
	var/id = "Unknown"
	var/rank = "Unknown"
	var/age= "Unknown"
	var/fingerprint = "Unknown"
	var/p_stat = "Stable"
	var/m_stat = "Stable"
	var/criminal = "None"
	var/mi_crim = "None"
	var/mi_crim_d = "None"
	var/ma_crim = "None"
	var/ma_crim_d = "None."
	var/notes = "None."
	var/addedby = "no"
/obj/machinery/computer/test
	name = "test"
	icon = 'washer.dmi'
	icon_state = "land01"
	var/dat
	var/obj/machinery/computer/database/db
	var/datum/data/row/employee/cur
/obj/machinery/computer/test/New()
	db = locate(/obj/machinery/computer/database)
	if(db)
		world << "found db"
/obj/machinery/computer/test/attack_hand(mob/user as mob)
	if(dat)
		user << browse(dat,"window=test")
	if(!db)
		dat += "ERROR DATABASE UNREACHABLE"
	else
		dat = "<head>Test</head>"
		dat += "<A href='?src=\ref[src];addr=1'>Add New record</A>"
		dat += "<A href='?src=\ref[src];show=1'>Show records</A>"
	user << browse(dat,"window=test")
/obj/machinery/computer/test/Topic(href, href_list)
	if(href_list["addr"])
		var/datum/data/row/employee/d = new(src)
		cur = d
		d.id = rand(1,12399999999)
		dat = "<br>"
		dat += "<A href='?src=\ref[src];name=[cur.id]'>Name:[cur.name]</A><br>"
		dat += "<A href='?src=\ref[src];rank=[cur.id]'>Rank:[cur.rank]</A><br>"
		dat += "<A href='?src=\ref[src];age=[cur.id]'>Age:[cur.age]</A><br>"
		dat += "<A href='?src=\ref[src];fp=[cur.id]'>Fingerprint:[cur.fingerprint]</A><br>"
		dat += "<A href='?src=\ref[src];done=[cur.id]'>Done</A><br>"
		usr << browse(dat,"window=test")
	if(href_list["show"])
		dat = null
		for(var/datum/data/row/employee/d in db.db)
			dat += "Name:[d.name] Rank:[d.rank] Age:[d.age]<br>"
		usr << browse(dat,"window=test")
	if(href_list["name"])
		var/datum/data/row/employee/D = cur
		if(!D)
			return
		D.name = input(usr,"What name?","Name?",D.name)
		updinput(usr)
		return
	if(href_list["rank"])
		var/datum/data/row/employee/D = cur
		if(!D)
			return
		D.rank = input(usr,"What rank?","rank?",D.rank)
		updinput(usr)
		return
	if(href_list["age"])
		var/datum/data/row/employee/D = cur
		if(!D)
			return
		D.age = input(usr,"What age?","age?",D.age)
		updinput(usr)
		return
	if(href_list["fp"])
		var/datum/data/row/employee/D = cur
		if(!D)
			return
		D.fingerprint = input(usr,"What fingerprint?","fingerprint?",D.fingerprint)
		updinput(usr)
		return
	if(href_list["done"])
		if(db.addentry(cur,usr))
			dat = null
			cur = null
			src.attack_hand(usr)
			return

/obj/machinery/computer/test/proc/updinput(mob/user as mob)
	dat = null
	dat += "<A href='?src=\ref[src];name=[cur.id]'>Name:[cur.name]</A><br>"
	dat += "<A href='?src=\ref[src];rank=[cur.id]'>Rank:[cur.rank]</A><br>"
	dat += "<A href='?src=\ref[src];age=[cur.id]'>Age:[cur.age]</A><br>"
	dat += "<A href='?src=\ref[src];fp=[cur.id]'>Fingerprint:[cur.fingerprint]</A><br>"
	dat += "<A href='?src=\ref[src];done=[cur.id]'>Done</A><br>"
	user << browse(dat,"window=test")