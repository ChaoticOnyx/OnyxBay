/*
CONTAINS:
T-RAY
DETECTIVE SCANNER
HEALTH ANALYZER
GAS ANALYZER
MASS SPECTROMETER
REAGENT SCANNER
*/


/obj/item/device/healthanalyzer
	name = "health analyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject."
	icon_state = "health"
	item_state = "analyzer"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = ITEM_SIZE_SMALL
	throw_speed = 5
	throw_range = 10
	matter = list(DEFAULT_WALL_MATERIAL = 200)
	origin_tech = list(TECH_MAGNET = 1, TECH_BIO = 1)
	var/mode = 1;

/obj/item/device/healthanalyzer/do_surgery(mob/living/M, mob/living/user)
	if(user.a_intent != I_HELP) //in case it is ever used as a surgery tool
		return ..()
	scan_mob(M, user) //default surgery behaviour is just to scan as usual
	return 1

/obj/item/device/healthanalyzer/attack(mob/living/M, mob/living/user)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	scan_mob(M, user)

/obj/item/device/healthanalyzer/proc/scan_mob(var/mob/living/carbon/human/H, var/mob/living/user)

	if (!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You are not nimble enough to use this device.</span>")
		return

	if (!istype(H) || H.isSynthetic())
		to_chat(user, "<span class='warning'>\The [src] is designed for organic humanoid patients only.</span>")
		return
	//user << browse(medical_scan_results(H, mode), "window=scanconsole;size=550x400")
	ui_interact(user,target = H)

/obj/item/device/healthanalyzer/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1,var/mob/living/carbon/human/target)
	
	var/data[0]

	if ((CLUMSY in user.mutations) && prob(60))
		user.visible_message("<span class='notice'>\The [user] runs \the [src] over the floor.")
		data["p_name"] = "<span class='black'><b>Scan results for the floor:</b><br></span>"
		data["brain"] = "<span class='black'>Overall Status: Healthy</span>"
	else
		user.visible_message("<span class='notice'>\The [user] runs \the [src] over \the [target].</span>")
		var/list/scan_data = medical_scan_results(target, mode, 1)
		for(var/i = 1,i <= scan_data.len,i++)
			scan_data[i] = replacetext(scan_data[i],"'notice'","'black'")
			scan_data[i] = replacetext(scan_data[i],"'warning'","'average'")
			scan_data[i] = replacetext(scan_data[i],"'danger'","'bad'")
		data["p_name"] = scan_data[1]
		data["brain"] = scan_data[2]
		data["blood"] = scan_data[3]
		data["status"] = scan_data[4]
		data["s_limb"] = scan_data[5]
		data["o_limb"] = scan_data[6]
		data["reagent"] = scan_data[7]
		data["virus"] = scan_data[8]
	
	ui = GLOB.nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "healthanalyzer.tmpl", " ", 640, 370)
		ui.set_initial_data(data)
		ui.set_window_options("focus=0;can_close=1;can_minimize=1;can_maximize=0;can_resize=0;titlebar=1;")
		ui.open()


proc/medical_scan_results(var/mob/living/carbon/human/H, var/verbose, var/separate_result)
	
	. = list()
	var/p_name = list()
	p_name = "<span class='notice'><b>Scan results for \the [H]:</b></span>"

	// Brain activity.
	var/brain_data = list()
	var/brain_result = "normal"
	var/obj/item/organ/internal/brain/brain = H.internal_organs_by_name[BP_BRAIN]
	if(H.should_have_organ(BP_BRAIN))
		if(!brain || H.stat == DEAD || (H.status_flags & FAKEDEATH))
			brain_result = "<span class='danger'>none, patient is braindead</span>"
		else if(H.stat != DEAD)
			switch(brain.get_current_damage_threshold())
				if(0)
					brain_result = "<span class='notice'>normal</span>"
				if(1 to 2)
					brain_result = "<span class='notice'>minor brain damage</span>"
				if(3 to 5)
					brain_result = "<span class='warning'>weak</span>"
				if(6 to 8)
					brain_result = "<span class='danger'>extremely weak</span>"
				if(9 to INFINITY)
					brain_result = "<span class='danger'>fading</span>"
				else
					brain_result = "<span class='danger'>ERROR - Hardware fault</span>"
	else
		brain_result = "<span class='danger'>ERROR - Nonstandard biology</span>"
	brain_data += "<span class='notice'>Brain activity:</span> [brain_result]."

	if(brain && (H.stat == DEAD || (H.status_flags & FAKEDEATH)))
		brain_data += "<span class='notice'><b>Time of Death:</b> [worldtime2stationtime(H.timeofdeath)]</span>"

	if (H.internal_organs_by_name[BP_STACK])
		brain_data += "<span class='notice'>Subject has a neural lace implant.</span>"

	// Pulse rate.
	var/blood_data = list()
	var/pulse_result = "normal"
	if(H.should_have_organ(BP_HEART))
		if(H.status_flags & FAKEDEATH)
			pulse_result = 0
		else
			pulse_result = H.get_pulse(1)
	else
		pulse_result = "<span class='danger'>ERROR - Nonstandard biology</span>"

	blood_data += "<span class='notice'>Pulse rate: <b>[pulse_result]</b>bpm.</span>"

	// Blood pressure. Based on the idea of a normal blood pressure being 120 over 80.
	if(H.get_blood_volume() <= 70)
		blood_data += "<span class='danger'>Severe blood loss detected.</span>"
	blood_data += "Blood pressure: <b>[H.get_blood_pressure()] ([H.get_blood_oxygenation()]</b>% blood oxygenation)"
	if (H.chem_effects[CE_BLOCKAGE])
		blood_data += "<span class='danger'>Warning: Blood clotting detected, blood transfusion recommended.</span>"

	var/status_data = list()
	// Body temperature.
	status_data += "<span class='notice'>Body temperature: <b>[H.bodytemperature-T0C]&deg;C ([H.bodytemperature*1.8-459.67]&deg;F)</b></span>"

	// Radiation.
	switch(H.radiation)
		if(-INFINITY to 0)
			status_data += "<span class='notice'>No radiation detected.</span>"
		if(1 to 30)
			status_data += "<span class='notice'>Patient shows minor traces of radiation exposure.</span>"
		if(31 to 60)
			status_data += "<span class='notice'>Patient is suffering from mild radiation poisoning.</span>"
		if(61 to 90)
			status_data += "<span class='warning'>Patient is suffering from advanced radiation poisoning.</span>"
		if(91 to 120)
			status_data += "<span class='warning'>Patient is suffering from severe radiation poisoning.</span>"
		if(121 to 240)
			status_data += "<span class='danger'>Patient is suffering from extreme radiation poisoning. Immediate treatment recommended.</span>"
		if(241 to INFINITY)
			status_data += "<span class='danger'>Patient is suffering from acute radiation poisoning. Immediate treatment recommended.</span>"

	// Other general warnings.
	if(H.getOxyLoss() > 50)
		status_data += "<font color='blue'><b>Severe oxygen deprivation detected.</b></font>"
	if(H.getToxLoss() > 50)
		status_data += "<font color='green'><b>Major systemic organ failure detected.</b></font>"
	if(H.getFireLoss() > 50)
		status_data += "<font color='#ffa500'><b>Severe burn damage detected.</b></font>"
	if(H.getBruteLoss() > 50)
		status_data += "<font color='red'><b>Severe anatomical damage detected.</b></font>"

	if(H.stat != DEAD)
		// Traumatic shock.
		if(H.is_asystole())
			status_data += "<span class='danger'>Patient is suffering from cardiovascular shock. Administer CPR immediately.</span>"
		else if(H.shock_stage > 80)
			status_data += "<span class='warning'>Patient is at serious risk of going into shock. Pain relief recommended.</span>"
		var/is_bleeding
		for(var/obj/item/organ/external/E in H.organs)
			if(E.status & ORGAN_BLEEDING)
				is_bleeding = TRUE
				break
		if(!H.reagents.has_reagent(/datum/reagent/inaprovaline) && (H.is_asystole() || H.shock_stage > 80 || is_bleeding || H.getOxyLoss() > 50))
			status_data += "<span class='danger'>Patient is unstable, administer a single dose of inaprovaline.</span>"
		if(H.get_blood_volume() <= 500 && H.nutrition < 150)
			status_data += "<span class='warning'>Administer food or recommend the patient to eat.</span>"

	var/specific_limb_data = list()
	var/overall_limbs_data = list()
	var/found_fracture
	var/found_closed_fracture
	var/found_extreme_infection
	var/found_bleed
	var/found_tendon
	var/found_disloc
	var/found_infection
	var/found_injuries

	// Limb status.
	if(verbose)
		specific_limb_data += "<span class='notice'><b>Specific limb damage:</b></span>"

		for(var/obj/item/organ/external/E in H.organs)
			var/limb_damaged	//in some cases we dont need apply this flag cause it already will be applied
			var/limb_result = "<b>[capitalize(E.name)][(E.robotic >= ORGAN_ROBOT) ? " (Cybernetic)" : ""]:</b>"
			if(E.is_stump())
				limb_damaged = TRUE
				limb_result = "<span class='danger'><b>[capitalize(E.name)]</b></span>"
				specific_limb_data += limb_result
				continue
			if(E.brute_dam > 0)
				limb_damaged = TRUE
				limb_result = "[limb_result] \[<font color = 'red'>[get_wound_severity(E.brute_ratio, E.vital)] physical trauma</font>\]"
			if(E.burn_dam > 0)
				limb_damaged = TRUE
				limb_result = "[limb_result] \[<font color = '#ffa500'>[get_wound_severity(E.burn_ratio, E.vital)] burns</font>\]"
			if(E.status & ORGAN_BLEEDING)
				limb_damaged = TRUE
				limb_result = "[limb_result] \[<span class='danger'>bleeding</span>\]"
			if(E.status & ORGAN_BROKEN)
				limb_damaged = TRUE
				if(((E.organ_tag == BP_L_ARM) || (E.organ_tag == BP_R_ARM) || (E.organ_tag == BP_L_LEG) || (E.organ_tag == BP_R_LEG)) && (!E.splinted))
					limb_result = "[limb_result] \[<span class='danger'>fracture</span>\]"
					found_fracture = TRUE
				else
					found_closed_fracture = TRUE
			for(var/datum/wound/W in E.wounds)
				if (W.damage_type == CUT && W.current_stage <= W.max_bleeding_stage && !W.bandaged)
					limb_result = "[limb_result] \[<span class='danger'>open wound</span>\]"
					break
			if(E.has_infected_wound())
				limb_damaged = TRUE
				if(E.germ_level >= INFECTION_LEVEL_THREE)
					limb_result = "[limb_result] \[<span class='danger'>extreme infection</span>\]"
					found_extreme_infection = TRUE
				else
					limb_result = "[limb_result] \[<span class='danger'>infection</span>\]"
			if(!found_bleed && (E.status & ORGAN_ARTERY_CUT))
				found_bleed = TRUE
			if(!found_tendon && (E.status & ORGAN_TENDON_CUT))
				limb_damaged = TRUE
				found_tendon = TRUE
			if(!found_disloc && E.dislocated == 2)
				limb_damaged = TRUE
				found_disloc = TRUE
			if (limb_damaged)
				specific_limb_data += limb_result
				found_injuries = TRUE
		if (!found_injuries)
			specific_limb_data += "No detectable limb injuries."

		if (found_infection)
			overall_limbs_data += "<span class='warning'>Infected wound detected. Disinfection recommended.</span>"
		if (found_extreme_infection && !H.reagents.has_reagent(/datum/reagent/spaceacillin,15))
			overall_limbs_data += "<span class='danger'>Subject has extreme infection. Administering more than 15u of antibiotics or amputation recommended.</span>"
		if (found_fracture)
			overall_limbs_data += "<span class='warning'>Unsecured fracture detected. Splinting recommended for transport.</span>"
		if (found_closed_fracture)
			overall_limbs_data += "<span class='warning'>Closed bone fractures detected. Advanced scanner required for location.</span>"
		if (found_disloc)
			overall_limbs_data += "<span class='warning'>Dislocation detected. Advanced scanner required for location.</span>"
		if (found_bleed)
			overall_limbs_data += "<span class='danger'>Arterial bleeding detected. Advanced scanner required for location.</span>"
		if (found_tendon)
			overall_limbs_data += "<span class='warning'>Tendon or ligament damage detected. Advanced scanner required for location.</span>"
	
	var/reagents_data = list()
	// Reagent data.
	reagents_data += "<span class='notice'><b>Reagent scan:</b></span>"

	var/print_reagent_default_message = TRUE
	if(H.reagents.total_volume)
		var/unknown = 0
		var/reagent_info[0]
		var/is_overdosed = 0
		for(var/A in H.reagents.reagent_list)
			var/datum/reagent/R = A
			if(R.scannable)
				print_reagent_default_message = FALSE
				if (R.volume >= R.overdose)
					is_overdosed = 1
				reagent_info[R.type] = "<span class='notice'>    [round(H.reagents.get_reagent_amount(R.type), 1)]u <b>[R.name]</b></span>"
			else
				unknown++
		if(reagent_info.len)
			print_reagent_default_message = FALSE
			reagents_data += "<span class='notice'>Beneficial reagents detected in subject's blood:</span>"
			for(var/d in reagent_info)
				reagents_data += reagent_info[d]
		if (is_overdosed)
			reagents_data += "<span class='warning'>Warning: Medicine overdose detected.</span>"
		if(unknown)
			print_reagent_default_message = FALSE
			reagents_data += "<span class='warning'>Warning: Unknown substance[(unknown>1)?"s":""] detected in subject's blood.</span>"
	if(H.ingested && H.ingested.total_volume)
		var/unknown = 0
		for(var/datum/reagent/R in H.ingested.reagent_list)
			if(R.scannable)
				print_reagent_default_message = FALSE
				reagents_data += "<span class='notice'><b>[R.name]</b> found in subject's stomach.</span>"
			else
				++unknown
		if(unknown)
			print_reagent_default_message = FALSE
			reagents_data += "<span class='warning'>Non-medical reagent[(unknown > 1)?"s":""] found in subject's stomach.</span>"
	if (H.chem_effects[CE_ALCOHOL])
		reagents_data += "<span class='warning'>Alcohol byproducts detected in subject's blood.</span>"
	if (H.chem_effects[CE_ALCOHOL_TOXIC])
		reagents_data += "<span class='danger'>Warning: Subject suffering from alcohol intoxication.</span>"

	if(H.chem_doses.len)
		var/list/chemtraces = list()
		for(var/T in H.chem_doses)
			var/datum/reagent/R = T
			if(initial(R.scannable))
				chemtraces += "[initial(R.name)] ([H.chem_doses[T]])"
		if(chemtraces.len)
			reagents_data += "<span class='notice'>Metabolism products of [english_list(chemtraces)] found in subject's system.</span>"
	var/virus_data = list()
	if(H.virus2.len)
		for (var/ID in H.virus2)
			if (ID in virusDB)
				print_reagent_default_message = FALSE
				var/datum/computer_file/data/virus_record/V = virusDB[ID]
				virus_data += "<span class='warning'>Warning: Pathogen <b>[V.fields["name"]]</b> detected in subject's blood. Known antigen : <b>[V.fields["antigen"]]</b></span>"

	if(print_reagent_default_message)
		reagents_data += "No results."

	p_name = jointext(p_name,"<br>")
	brain_data = jointext(brain_data,"<br>")
	blood_data = jointext(blood_data,"<br>")
	status_data = jointext(status_data,"<br>")
	specific_limb_data = jointext(specific_limb_data,"<br>")
	overall_limbs_data = jointext(overall_limbs_data,"<br>")
	reagents_data = jointext(reagents_data,"<br>")
	virus_data = jointext(virus_data,"<br>")
	if(separate_result) 	//return as list
		. += p_name
		. += brain_data
		. += blood_data
		. += status_data
		if(verbose)
			. += specific_limb_data
			. += overall_limbs_data
		. += reagents_data
		. += virus_data
	else 	//return as text
		. += p_name
		. += "<hr>"
		. += brain_data
		. += "<hr>"
		. += blood_data
		. += "<hr>"
		. += status_data
		. += "<hr>"
		if(verbose)
			. += specific_limb_data
			. += "<br>"
			. += overall_limbs_data
			. += "<hr>"
		. += reagents_data
		. += "<hr>"
		. += virus_data
		. = jointext(.,"")

// Calculates severity based on the ratios defined external limbs.
proc/get_wound_severity(var/damage_ratio, var/vital = 0)
	var/degree

	switch(damage_ratio)
		if(0 to 0.1)
			degree = "minor"
		if(0.1 to 0.25)
			degree = "moderate"
		if(0.25 to 0.5)
			degree = "significant"
		if(0.5 to 0.75)
			degree = "severe"
		if(0.75 to 1)
			degree = "extreme"
		else
			if(vital)
				degree = "critical"
			else
				degree = "irreparable"

	return degree

/obj/item/device/healthanalyzer/verb/toggle_mode()
	set name = "Switch Verbosity"
	set category = "Object"

	mode = !mode
	if(mode)
		to_chat(usr, "The scanner now shows specific limb damage.")
	else
		to_chat(usr, "The scanner no longer shows limb damage.")

/obj/item/device/healthanalyzer_advanced
	name = "advanced health analyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject as well as all."
	icon_state = "health_adv"
	item_state = "analyzer"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_POCKET
	throwforce = 3
	w_class = ITEM_SIZE_SMALL
	throw_speed = 5
	throw_range = 10
	matter = list(DEFAULT_WALL_MATERIAL = 800)
	origin_tech = list(TECH_MAGNET = 4, TECH_BIO = 6)
	var/dat = null
	var/mob/living/carbon/last_target = null


/obj/item/device/healthanalyzer_advanced/do_surgery(mob/living/carbon/human/M, mob/living/user)
	if(user.a_intent != I_HELP) //in case it is ever used as a surgery tool
		return ..()

	if (istype(M,/mob/living/carbon/human))
		dat = M.get_medical_data()
		last_target = M
		user << browse(dat, "window=scanconsole;size=430x600")
	return 1

/obj/item/device/healthanalyzer_advanced/attack_self(mob/user)
	if (last_target && dat)
		user << browse(dat, "window=scanconsole;size=430x600")

/obj/item/device/healthanalyzer_advanced/examine(mob/user)
	..()
	if (last_target)
		to_chat(user, "It contains saved data for [last_target].")
	

/obj/item/device/healthanalyzer_advanced/attack(mob/living/carbon/human/M, mob/living/user)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	if (istype(M,/mob/living/carbon/human))
		dat = M.get_medical_data()
		last_target = M
		user << browse(dat, "window=scanconsole;size=430x600")
		if(isrobot(user))
			var/mob/living/silicon/robot/R = user
			if(R.cell)
				R.cell.use(60)

/obj/item/device/healthanalyzer_advanced/verb/print_data()
	set name = "Print Data"
	set category = "Object"
	if (last_target && dat)
		new/obj/item/weapon/paper/(get_turf(src), "<tt>[dat]</tt>", "Body scan report - [last_target]")
		src.visible_message("<span class='notice'>[src] prints out \the scan result.</span>")


/obj/item/device/analyzer
	name = "analyzer"
	desc = "A hand-held environmental scanner which reports current gas levels."
	icon_state = "atmos"
	item_state = "analyzer"
	w_class = ITEM_SIZE_SMALL
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20

	matter = list(DEFAULT_WALL_MATERIAL = 30,"glass" = 20)

	origin_tech = list(TECH_MAGNET = 1, TECH_ENGINEERING = 1)
	var/advanced_mode = 0

/obj/item/device/analyzer/verb/verbosity(mob/user)
	set name = "Toggle Advanced Gas Analysis"
	set category = "Object"
	set src in usr

	if (!user.incapacitated())
		advanced_mode = !advanced_mode
		to_chat(user, "You toggle advanced gas analysis [advanced_mode ? "on" : "off"].")

/obj/item/device/analyzer/attack_self(mob/user)

	if (user.incapacitated())
		return
	if (!user.IsAdvancedToolUser())
		return

	analyze_gases(user.loc, user,advanced_mode)
	return 1

/obj/item/device/analyzer/afterattack(obj/O, mob/user, proximity)
	if(!proximity)
		return
	if (user.incapacitated())
		return
	if (!user.IsAdvancedToolUser())
		return
	if(istype(O) && O.simulated)
		analyze_gases(O, user, advanced_mode)

/obj/item/device/mass_spectrometer
	name = "mass spectrometer"
	desc = "A hand-held mass spectrometer which identifies trace chemicals in a blood sample."
	icon_state = "spectrometer"
	item_state = "analyzer"
	w_class = ITEM_SIZE_SMALL
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20

	matter = list(DEFAULT_WALL_MATERIAL = 30,"glass" = 20)

	origin_tech = list(TECH_MAGNET = 2, TECH_BIO = 2)
	var/details = 0
	var/recent_fail = 0

/obj/item/device/mass_spectrometer/New()
	..()
	create_reagents(5)

/obj/item/device/mass_spectrometer/on_reagent_change()
	update_icon()

/obj/item/device/mass_spectrometer/update_icon()
	icon_state = initial(icon_state)
	if(reagents.total_volume)
		icon_state += "_s"

/obj/item/device/mass_spectrometer/attack_self(mob/user as mob)
	if (user.incapacitated())
		return
	if (!user.IsAdvancedToolUser())
		return
	if(reagents.total_volume)
		var/list/blood_traces = list()
		var/list/blood_doses = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			if(R.type != /datum/reagent/blood)
				reagents.clear_reagents()
				to_chat(user, "<span class='warning'>The sample was contaminated! Please insert another sample</span>")
				return
			else
				blood_traces = params2list(R.data["trace_chem"])
				blood_doses = params2list(R.data["dose_chem"])
				break
		var/dat = "Trace Chemicals Found: "
		for(var/T in blood_traces)
			var/datum/reagent/R = T
			if(details)
				dat += "[initial(R.name)] ([blood_traces[T]] units) "
			else
				dat += "[initial(R.name)] "
		if(details)
			dat += "\nMetabolism Products of Chemicals Found:"
			for(var/T in blood_doses)
				var/datum/reagent/R = T
				dat += "[initial(R.name)] ([blood_doses[T]] units) "
		to_chat(user, "[dat]")
		reagents.clear_reagents()
	return

/obj/item/device/mass_spectrometer/adv
	name = "advanced mass spectrometer"
	icon_state = "adv_spectrometer"
	details = 1
	origin_tech = list(TECH_MAGNET = 4, TECH_BIO = 2)

/obj/item/device/reagent_scanner
	name = "reagent scanner"
	desc = "A hand-held reagent scanner which identifies chemical agents."
	icon_state = "reagent"
	item_state = "analyzer"
	w_class = ITEM_SIZE_SMALL
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20
	matter = list(DEFAULT_WALL_MATERIAL = 30,"glass" = 20)

	origin_tech = list(TECH_MAGNET = 2, TECH_BIO = 2)
	var/details = 0
	var/recent_fail = 0

/obj/item/device/reagent_scanner/afterattack(obj/O, mob/user as mob, proximity)
	if(!proximity)
		return
	if (user.incapacitated())
		return
	if (!user.IsAdvancedToolUser())
		return
	if(!istype(O))
		return

	if(!isnull(O.reagents))
		var/dat = ""
		if(O.reagents.reagent_list.len > 0)
			var/one_percent = O.reagents.total_volume / 100
			for (var/datum/reagent/R in O.reagents.reagent_list)
				dat += "\n \t <span class='notice'>[R][details ? ": [R.volume / one_percent]%" : ""]</span>"
		if(dat)
			to_chat(user, "<span class='notice'>Chemicals found: [dat]</span>")
		else
			to_chat(user, "<span class='notice'>No active chemical agents found in [O].</span>")
	else
		to_chat(user, "<span class='notice'>No significant chemical agents found in [O].</span>")

	return

/obj/item/device/reagent_scanner/adv
	name = "advanced reagent scanner"
	icon_state = "adv_reagent"
	details = 1
	origin_tech = list(TECH_MAGNET = 4, TECH_BIO = 2)

/obj/item/device/price_scanner
	name = "price scanner"
	desc = "Using an up-to-date database of various costs and prices, this device estimates the market price of an item up to 0.001% accuracy."
	icon_state = "price_scanner"
	origin_tech = list(TECH_MATERIAL = 6, TECH_MAGNET = 4)
	slot_flags = SLOT_BELT
	w_class = ITEM_SIZE_SMALL
	throwforce = 0
	throw_speed = 3
	throw_range = 3
	matter = list(DEFAULT_WALL_MATERIAL = 25, "glass" = 25)

/obj/item/device/price_scanner/afterattack(atom/movable/target, mob/user as mob, proximity)
	if(!proximity)
		return

	var/value = get_value(target)
	user.visible_message("\The [user] scans \the [target] with \the [src]")
	user.show_message("Price estimation of \the [target]: [value ? value : "N/A"] Thalers")

/obj/item/device/slime_scanner
	name = "xenolife scanner"
	desc = "Multipurpose organic life scanner. With spectral breath analyzer you can find out what snacks Ian had! Or what gasses alien life breathes."
	icon_state = "xenobio"
	item_state = "analyzer"
	slot_flags = SLOT_BELT
	w_class = ITEM_SIZE_SMALL
	origin_tech = list(TECH_MAGNET = 1, TECH_BIO = 1)
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	matter = list(DEFAULT_WALL_MATERIAL = 30,"glass" = 20)

/obj/item/device/slime_scanner/proc/list_gases(var/gases)
	. = list()
	for(var/g in gases)
		. += "[gas_data.name[g]] ([gases[g]]%)"
	return english_list(.)

/obj/item/device/slime_scanner/afterattack(mob/target, mob/user, proximity)
	if(!proximity)
		return

	if(!istype(target))
		return

	user.visible_message("\The [user] scans \the [target] with \the [src]")
	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		user.show_message("<span class='notice'>Data for [H]:</span>")
		user.show_message("Species:\t[H.species]")
		user.show_message("Breathes:\t[gas_data.name[H.species.breath_type]]")
		user.show_message("Exhales:\t[gas_data.name[H.species.exhale_type]]")
		user.show_message("Known toxins:\t[gas_data.name[H.species.poison_type]]")
		user.show_message("Temperature comfort zone:\t[H.species.cold_discomfort_level] K to [H.species.heat_discomfort_level] K")
		user.show_message("Pressure comfort zone:\t[H.species.warning_low_pressure] kPa to [H.species.warning_high_pressure] kPa")
	else if(istype(target, /mob/living/simple_animal))
		var/mob/living/simple_animal/A = target
		user.show_message("<span class='notice'>Data for [A]:</span>")
		user.show_message("Species:\t[initial(A.name)]")
		user.show_message("Breathes:\t[list_gases(A.min_gas)]")
		user.show_message("Known toxins:\t[list_gases(A.max_gas)]")
		user.show_message("Temperature comfort zone:\t[A.minbodytemp] K to [A.maxbodytemp] K")
	else if(istype(target, /mob/living/carbon/slime/))
		var/mob/living/carbon/slime/T = target
		user.show_message("<span class='notice'>Slime scan result for \the [T]:</span>")
		user.show_message("[T.colour] [T.is_adult ? "adult" : "baby"] slime")
		user.show_message("Nutrition:\t[T.nutrition]/[T.get_max_nutrition()]")
		if(T.nutrition < T.get_starve_nutrition())
			user.show_message("<span class='alert'>Warning:\tthe slime is starving!</span>")
		else if (T.nutrition < T.get_hunger_nutrition())
			user.show_message("<span class='warning'>Warning:\tthe slime is hungry.</span>")
		user.show_message("Electric charge strength:\t[T.powerlevel]")
		user.show_message("Health:\t[round(T.health / T.maxHealth)]%")

		var/list/mutations = T.GetMutations()

		if(!mutations.len)
			user.show_message("This slime will never mutate.")
		else
			var/list/mutationChances = list()
			for(var/i in mutations)
				if(i == T.colour)
					continue
				if(mutationChances[i])
					mutationChances[i] += T.mutation_chance / mutations.len
				else
					mutationChances[i] = T.mutation_chance / mutations.len

			var/list/mutationTexts = list("[T.colour] ([100 - T.mutation_chance]%)")
			for(var/i in mutationChances)
				mutationTexts += "[i] ([mutationChances[i]]%)"

			user.show_message("Possible colours on splitting:\t[english_list(mutationTexts)]")

		if (T.cores > 1)
			user.show_message("Anomalous slime core amount detected.")
		user.show_message("Growth progress:\t[T.amount_grown]/10.")
	else
		user.show_message("Incompatible life form, analysis failed.")
