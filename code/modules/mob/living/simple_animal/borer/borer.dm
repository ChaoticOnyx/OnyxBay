/mob/living/simple_animal/borer
	name = "cortical borer"
	real_name = "cortical borer"
	desc = "A small, quivering sluglike creature."
	speak_emote = list("chirrups")
	emote_hear = list("chirrups")
	response_help  = "pokes"
	response_disarm = "prods"
	response_harm   = "stomps on"
	icon_state = "brainslug"
	item_state = "voxslug" // For the lack of a better sprite...
	icon_living = "brainslug"
	icon_dead = "brainslug_dead"
	speed = 5
	a_intent = I_HURT
	stop_automated_movement = 1
	status_flags = CANPUSH
	attacktext = "nipped"
	friendly = "prods"
	wander = 0
	pass_flags = PASS_FLAG_TABLE
	universal_understand = 1
	holder_type = /obj/item/weapon/holder/borer
	mob_size = MOB_SMALL
	can_escape = 1

	var/generation = 1
	var/static/list/borer_names = list(
		"Primary", "Secondary", "Tertiary", "Quaternary", "Quinary", "Senary",
		"Septenary", "Octonary", "Novenary", "Decenary", "Undenary", "Duodenary",
		)

	var/used_dominate
	var/chemicals = 10                      // Chemicals used for reproduction and spitting neurotoxin.
	var/mob/living/carbon/human/host        // Human host for the brain worm.
	var/truename                            // Name used for brainworm-speak.
	var/mob/living/captive_brain/host_brain // Used for swapping control of the body back and forth.
	var/controlling                         // Used in human death check.
	var/docile = FALSE                      // Sugar can stop borers from acting.
	var/has_reproduced
	var/initial = FALSE

/mob/living/simple_animal/borer/initial
	initial = TRUE

/mob/living/simple_animal/borer/Login()
	..()
	if(!initial)
		GLOB.borers.add_antagonist(mind)

/mob/living/simple_animal/borer/New(atom/newloc, gen=1)
	..(newloc)

	add_language("Cortical Link")
	update_abilities()

	generation = gen
	truename = "[borer_names[min(generation, borer_names.len)]] [random_id("borer[generation]", 1000, 9999)]"
	if(!initial)
		request_player()

/mob/living/simple_animal/borer/Life()

	..()

	if(host)
		if(loc != host) //gib or other forced moving from host
			var/stored_loc = loc //leave_host() will try to get host's turf but it is bad
			detatch()
			leave_host()
			loc = stored_loc
			return
		if(!stat && host.stat != DEAD)
			health = min(health + 1, maxHealth)
			if(host.reagents.has_reagent(/datum/reagent/sugar))
				if(!docile)
					to_chat(controlling ? host : src, SPAN("notice", "You feel the soporific flow of sugar in your host's blood, lulling you into docility."))
					docile = TRUE
			else
				if(docile)
					to_chat(controlling ? host : src, SPAN("notice", "You shake off your lethargy as the sugar leaves your host's blood."))
					docile = FALSE

			if(chemicals < 250)
				chemicals++
			if(controlling)

				if(docile)
					to_chat(host, SPAN("notice", "You are feeling far too docile to continue controlling your host..."))
					host.release_control()
					return

				if(prob(5))
					host.adjustBrainLoss(0.1)

				if(prob(host.getBrainLoss()/20))
					host.say("*[pick(list("blink","blink_r","choke","aflap","drool","twitch","twitch_v","gasp"))]")
		else if((stat == DEAD || host.stat == DEAD) && controlling)
			detatch()

/mob/living/simple_animal/borer/Stat()
	. = ..()
	statpanel("Status")

	if(evacuation_controller)
		var/eta_status = evacuation_controller.get_status_panel_eta()
		if(eta_status)
			stat(null, eta_status)

	if (client.statpanel == "Status")
		stat("Chemicals", chemicals)

/mob/living/simple_animal/borer/handle_environment(datum/gas_mixture/environment)
	var/external_temperature = host ? host.bodytemperature : environment.temperature
	if( abs(external_temperature - bodytemperature) > 40 )
		bodytemperature += (external_temperature - bodytemperature) / 5
	//Atmos effect
	if(bodytemperature < minbodytemp)
		fire_alert = 2
		adjustBruteLoss(cold_damage_per_tick)
	else if(bodytemperature > maxbodytemp)
		fire_alert = 1
		adjustBruteLoss(heat_damage_per_tick)
	else
		fire_alert = 0

	if(host)
		oxygen_alert = 0
		toxins_alert = 0
		return
	var/atmos_suitable = 1
	if(min_gas)
		for(var/gas in min_gas)
			if(environment.gas[gas] < min_gas[gas])
				atmos_suitable = 0
				oxygen_alert = 1
			else
				oxygen_alert = 0
	if(max_gas)
		for(var/gas in max_gas)
			if(environment.gas[gas] > max_gas[gas])
				atmos_suitable = 0
				toxins_alert = 1
			else
				toxins_alert = 0

	if(!atmos_suitable)
		adjustBruteLoss(unsuitable_atoms_damage)

//Procs for grabbing players.
/mob/living/simple_animal/borer/proc/request_player()
	var/datum/ghosttrap/G = get_ghost_trap("cortical borer")
	G.request_player(src, "A cortical borer needs a player.")
