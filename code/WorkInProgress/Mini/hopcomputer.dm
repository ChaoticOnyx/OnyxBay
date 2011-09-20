/obj/machinery/computer/crew
	name = "Crew Computer"
	icon_state = "id"
	var/datum/data/record/gen_rec
	var/datum/data/record/med_rec
	var/datum/data/record/sec_rec
	var/entered = 0
	New()
		..()
		make_new_manifest_entry()

/obj/machinery/computer/crew/attack_hand(mob/M)
	var/dat = ""
	dat += "<h3><b><center>Manifest Entry</center></b></h3><br>"
	dat += "<b><center>General Record</center></b><br>"
	dat += "Name: <a href='?src=\ref[src]&gen=1&med=1&sec=1&entry=name'>[gen_rec.fields["name"]]</a> ID:[gen_rec.fields["id"]]<br>"
	dat += "Rank: <a href='?src=\ref[src]&gen=1&entry=rank'>[gen_rec.fields["rank"]]</a><br>"
	dat += "Sex: <a href='?src=\ref[src]&gen=1&entry=sex&sex=[gen_rec.fields["sex"]]'>[gen_rec.fields["sex"]]</a><br>"
	dat += "Age: <a href='?src=\ref[src]&gen=&entry=age'>[gen_rec.fields["age"]]</a><br>"
	dat += "Fingerprint: <a href='?src=\ref[src]&gen=1&entry=fingerprint'>[gen_rec.fields["fingerprint"]]</a><br>"
	dat += "Physical Status: <a href='?src=\ref[src]&gen=1&entry=p_stat'>[gen_rec.fields["p_stat"]]</a><br>"
	dat += "Mental Status: <a href='?src=\ref[src]&gen=1&entry=m_stat'>[gen_rec.fields["m_stat"]]</a><br>"
	dat += "<br>"
	dat += "<h4><center>Medical Record</center></h4><br>"
	dat += "Blood Type: <a href='?src=\ref[src]&med=1&entry=b_type'>[med_rec.fields["b_type"]]</a><br>"
	dat += "DNA: <a href='?src=\ref[src]&med=1&entry=bloodsample'>[med_rec.fields["bloodsample"]]</a><br>"
	dat += "Minor Disabilities: <a href='?src=\ref[src]&med=1&entry=mi_dis'>[med_rec.fields["mi_dis"]]</a><br>"
	dat += "\tDetails: <a href='?src=\ref[src]&med=1&entry=mi_dis_d'>[med_rec.fields["mi_dis_d"]]</a><br>"
	dat += "Major Disabilities: <a href='?src=\ref[src]&med=1&entry=ma_dis'>[med_rec.fields["ma_dis"]]</a><br>"
	dat += "\tDetails: <a href='?src=\ref[src]&med=1&entry=ma_dis_d'>[med_rec.fields["ma_dis_d"]]</a><br>"
	dat += "Allergies: <a href='?src=\ref[src]&med=1&entry=alg'>[med_rec.fields["alg"]]</a><br>"
	dat += "\tDetails: <a href='?src=\ref[src]&med=1&entry=alg_d'>[med_rec.fields["alg_d"]]</a><br>"
	dat += "Current Diseases: <a href='?src=\ref[src]&med=1&entry=cdi'>[med_rec.fields["cdi"]]</a><br>"
	dat += "\tDetails: <a href='?src=\ref[src]&med=1&entry=cdi_d'>[med_rec.fields["cdi_d"]]</a><br>"
	dat += "Other Notes: <a href='?src=\ref[src]&med=1&entry=notes'>[med_rec.fields["notes"]]</a><br>"
	dat += "<br>"
	dat += "<h4><center>Security Record</center></h4><br>"
	dat += "Criminal Status: <a href='?src=\ref[src]&sec=1&entry=criminal'>[sec_rec.fields["criminal"]]</a><br>"
	dat += "Minor Crimes: <a href='?src=\ref[src]&sec=1&entry=mi_crim'>[sec_rec.fields["mi_crim"]]</a><br>"
	dat += "\tDetails: <a href='?src=\ref[src]&sec=1&entry=mi_crim_d'>[sec_rec.fields["mi_crim_d"]]</a><br>"
	dat += "Major Crimes: <a href='?src=\ref[src]&sec=1&entry=ma_crim'>[sec_rec.fields["ma_crim"]]</a><br>"
	dat += "\tDetails: <a href='?src=\ref[src]&sec=1&entry=ma_crim_d'>[sec_rec.fields["ma_crim_d"]]</a><br>"
	dat += "Other Notes: <a href='?src=\ref[src]&sec=1&entry=notes'>[sec_rec.fields["notes"]]</a><br>"
	dat += "<br>"
	dat += "<br>"
	dat += "<a href='?src=\ref[src]&add=1'>Add</a> | <a href='?src=\ref[src]&reset=1'>Reset</a> | <a href='?src=\ref[src]&load=1'>Load</a>"
	M << browse(dat, "window=powcomp;size=420x700")

/obj/machinery/computer/crew/proc/make_new_manifest_entry()
	entered = 0
	//general record
	gen_rec = new /datum/data/record()
	gen_rec.fields["name"] = "New Entry"
	gen_rec.fields["id"] = text("[]", add_zero(num2hex(rand(1, 1.6777215E7)), 6))
	gen_rec.fields["rank"] = "Unassigned"
	gen_rec.fields["sex"] = "Male"
	gen_rec.fields["age"] = "0"
	gen_rec.fields["fingerprint"] = "Unknown"
	gen_rec.fields["p_stat"] = "Active"
	gen_rec.fields["m_stat"] = "Stable"
	//medical record
	med_rec = new /datum/data/record()
	med_rec.fields["name"] = gen_rec.fields["name"]
	med_rec.fields["id"] = gen_rec.fields["id"]
	med_rec.name = text("Medical Record #[]", med_rec.fields["id"])
	med_rec.fields["b_type"] = "Unknown"
	med_rec.fields["bloodsample"] = "Unknown"
	med_rec.fields["mi_dis"] = "None"
	med_rec.fields["mi_dis_d"] = "No minor disabilities have been declared."
	med_rec.fields["ma_dis"] = "None"
	med_rec.fields["ma_dis_d"] = "No major disabilities have been diagnosed."
	med_rec.fields["alg"] = "None"
	med_rec.fields["alg_d"] = "No allergies have been detected in this patient."
	med_rec.fields["cdi"] = "None"
	med_rec.fields["cdi_d"] = "No diseases have been diagnosed at the moment."
	med_rec.fields["notes"] = "No notes."
	//security record
	sec_rec = new /datum/data/record()
	sec_rec.fields["name"] = gen_rec.fields["name"]
	sec_rec.fields["id"] = gen_rec.fields["id"]
	sec_rec.name = text("Security Record #[]", sec_rec.fields["id"])
	sec_rec.fields["criminal"] = "None"
	sec_rec.fields["mi_crim"] = "None"
	sec_rec.fields["mi_crim_d"] = "No minor crime convictions."
	sec_rec.fields["ma_crim"] = "None"
	sec_rec.fields["ma_crim_d"] = "No major crime convictions."
	sec_rec.fields["notes"] = "No notes."

/obj/machinery/computer/crew/Topic(href, href_list)
	if(href_list["gen"])	//rank (rank), sex (sex), physical status (p_stat), mental status (m_stat)
		if(href_list["entry"] == "rank")
			if(href_list["rank"])
				if(href_list["rank"] == "Custom"
					gen_rec.fields["rank"] = input("Job name:")
				else
					gen_rec.fields["rank"] = href_list["rank"]
			else
				var/dat = ""
				for(var/job in (get_all_jobs() + "Custom"))
					dat += "<a href='?src=\ref[src]&gen=1&entry=rank&rank=[job]'>[dd_replacetext(job, " ", "&nbsp")]</a>&nbsp;"
				dat += "<br>"
				dat += "<a href='?src=\ref[src]'>Back</a>"
				usr << browse(dat, "window=powcomp;size=420x700")
				return
		else if(href_list["entry"] == "sex")
			if(href_list["sex"] == "Male")
				gen_rec.fields["sex"] = "Female"
			else
				gen_rec.fields["sex"] = "Male"
		else if(href_list["entry"] == "p_stat")
			if(href_list["p_stat"])
				gen_rec.fields["p_stat"] = href_list["p_stat"]
			else
				var/dat = ""
				dat += "<a href='?src=\ref[src]&med=1&entry=&p_stat&p_stat=active'>Active</a><br>"
				dat += "<a href='?src=\ref[src]&med=1&entry=&p_stat&p_stat=unfit'>Physically Unfit</a><br>"
				dat += "<a href='?src=\ref[src]&med=1&entry=&p_stat&p_stat=unconscious'>*Unconscious*</a><br>"
				dat += "<a href='?src=\ref[src]&med=1&entry=&p_stat&p_stat=deceased'>*Deceased*</a><br>"
				dat += "<a href='?src=\ref[src]'>Back</a>"
				usr << browse(dat, "window=powcomp;size=420x700")
				return
		else if(href_list["entry"] == "m_stat")
			if(href_list["m_stat"])
				gen_rec.fields["m_stat"] = href_list["m_stat"]
			else
				var/dat = ""
				dat += "<a href='?src=\ref[src]&med=1&entry=&m_stat&m_stat=stable'>Stable</a><br>"
				dat += "<a href='?src=\ref[src]&med=1&entry=&m_stat&m_stat=watch'>*Watch*</a><br>"
				dat += "<a href='?src=\ref[src]&med=1&entry=&m_stat&m_stat=unstable'>*Unstable*</a><br>"
				dat += "<a href='?src=\ref[src]&med=1&entry=&m_stat&m_stat=insane'>*Insane*</a><br>"
				dat += "<a href='?src=\ref[src]'>Back</a>"
				usr << browse(dat, "window=powcomp;size=420x700")
				return
		else
			var/input = ""
			while(input == "")
				input = input("Enter [href_list["entry"]]:")
			gen_rec.fields[href_list["entry"]] = input

	if(href_list["med"])	//blood type (b_type)
		if(href_list["entry"] == "b_type")
			if(href_list["b_type"])
				gen_rec.fields["b_type"] = href_list[href_list["entry"]]
			else
				var/dat = ""
				dat += "Blood Type:<br>"
				dat += "<a href='?src=\ref[src]&med=1&entry=b_type&b_type=an'>A-</a>&nbsp; <a href='?src=\ref[src]&med=1&entry=b_type&b_type=ap'>A+</a><br>"
				dat += "<a href='?src=\ref[src]&med=1&entry=b_type&b_type=bn'>B-</a>&nbsp; <a href='?src=\ref[src]&med=1&entry=b_type&b_type=bp'>B+</a><br>"
				dat += "<a href='?src=\ref[src]&med=1&entry=b_type&b_type=abn'>AB-</a> <a href='?src=\ref[src]&med=1&entry=b_type&b_type=abp'>AB+</a><br>"
				dat += "<a href='?src=\ref[src]&med=1&entry=b_type&b_type=on'>O-</a>&nbsp; <a href='?src=\ref[src]&med=1&entry=b_type&b_type=op'>O+</a><br>"
				dat += "<a href='?src=\ref[src]'>Back</a>"
				usr << browse(dat, "window=powcomp;size=420x700")
				return
		else
			med_rec.fields[href_list["entry"]] = href_list[href_list["entry"]]

	if(href_list["sec"])	//criminal status (criminal)
		if(href_list["entry"] == "criminal")
			if(href_list["criminal"])
				gen_rec.fields["criminal"] = href_list[href_list["entry"]]
			else
				var/dat = ""
				dat += "Criminal Status:<br>"
				dat += "<a href='?src=\ref[src]&sec=1&entry=criminal&criminal=none'>None</a><br>"
				dat += "<a href='?src=\ref[src]&sec=1&entry=criminal&criminal=arrest'>*Arrest*</a><br>"
				dat += "<a href='?src=\ref[src]&sec=1&entry=criminal&criminal=incarcerated'>Incarcerated</a><br>"
				dat += "<a href='?src=\ref[src]&sec=1&entry=criminal&criminal=parolled'>Parolled</a><br>"
				dat += "<a href='?src=\ref[src]&sec=1&entry=criminal&criminal=released'>Released</a><br>"
				dat += "<a href='?src=\ref[src]'>Back</a>"
				usr << browse(dat, "window=powcomp;size=420x700")
				return
		else
			sec_rec.fields[href_list["entry"]] = href_list[href_list["entry"]]

	if(href_list["add"])
		if(!entered)
			data_core.general += gen_rec
			data_core.medical += med_rec
			data_core.security += sec_rec
		make_new_manifest_entry()

	if(href_list["reset"])
		make_new_manifest_entry()

	if(href_list["load"])
		if(!href_list["load_me"])
			var/dat = ""
			for(var/datum/data/record/R in data_core.general)
				dat += "<a href='?src=\ref[src]&load=1&load_me=[R.fields["id"]]'>[R.fields["name"]]</a><br>"
			dat += "<a href='?src=\ref[src]'>Back</a>"
			usr << browse(dat, "window=powcomp;size=420x700")
			return
		else
			for(var/datum/data/record/R in data_core.general)
				if(R.fields["id"] == href_list["load_me"])
					gen_rec = R
					break
			for(var/datum/data/record/R in data_core.medical)
				if(R.fields["id"] == href_list["load_me"])
					med_rec = R
					break
			for(var/datum/data/record/R in data_core.security)
				if(R.fields["id"] == href_list["load_me"])
					sec_rec = R
					break
	src.attack_hand(usr)
