/obj/machinery/computer/crew
	name = "Crew Computer"
	icon_state = "id"
	var/obj/machinery/computer/med_data/medcomp = new /obj/machinery/computer/med_data()	//all the functionality of these two computers in one small package!
	var/obj/machinery/computer/security/seccomp = new /obj/machinery/computer/security()	//buy now and recieve a free easy manifest addition function!

/obj/machinery/computer/crew/attack_hand(mob/M)
	make_new_manifest_entry(M, input("Please input rank:", "Secure records") in (get_all_jobs() + "Custom"))

/obj/machinery/computer/crew/proc/make_new_manifest_entry(mob/M, var/rank)
	//general record
	var/datum/data/record/G = new /datum/data/record()
	G.fields["name"] = input("Please input name:", "Secure records") as text
	G.fields["id"] = text("[]", add_zero(num2hex(rand(1, 1.6777215E7)), 6))
	if(rank == "Custom")
		G.fields["rank"] = input("Please input rank:", "Secure records") as text
	else
		G.fields["rank"] = rank
	G.fields["sex"] = input("Please input gender:", "Secure records") in list("Male", "Female")
	G.fields["age"] = input("Please input age:", "Secure records") as text
	G.fields["fingerprint"] = input("Please input fingerprint:", "Secure records") as text
	G.fields["p_stat"] = "Active"
	G.fields["m_stat"] = "Stable"
	data_core.general += G
	//medical record
	var/datum/data/record/R = new /datum/data/record()
	R.fields["name"] = G.fields["name"]
	R.fields["id"] = G.fields["id"]
	R.name = text("Medical Record #[]", R.fields["id"])
	R.fields["b_type"] = input("Please input blood type:", "Secure records") in list("A+", "B+", "AB+", "O+", "A-", "B-", "AB-", "O-")
	R.fields["bloodsample"] = input("Please input blood sample:", "Secure records") as text
	R.fields["mi_dis"] = "None"
	R.fields["mi_dis_d"] = "No minor disabilities have been declared."
	R.fields["ma_dis"] = "None"
	R.fields["ma_dis_d"] = "No major disabilities have been diagnosed."
	R.fields["alg"] = "None"
	R.fields["alg_d"] = "No allergies have been detected in this patient."
	R.fields["cdi"] = "None"
	R.fields["cdi_d"] = "No diseases have been diagnosed at the moment."
	R.fields["notes"] = "No notes."
	data_core.medical += R
	//security record
	R = new /datum/data/record()
	R.fields["name"] = G.fields["name"]
	R.fields["id"] = G.fields["id"]
	R.name = text("Security Record #[]", R.fields["id"])
	R.fields["criminal"] = "None"
	R.fields["mi_crim"] = "None"
	R.fields["mi_crim_d"] = "No minor crime convictions."
	R.fields["ma_crim"] = "None"
	R.fields["ma_crim_d"] = "No major crime convictions."
	R.fields["notes"] = "No notes."
	data_core.security += R