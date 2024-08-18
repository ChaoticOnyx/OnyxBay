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
	holder_type = /obj/item/holder/borer
	mob_size = MOB_SMALL
	can_escape = 1
	bodyparts = /decl/simple_animal_bodyparts/borer

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
	var/controlling = FALSE                 // Is borer controlling host?
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

/mob/living/simple_animal/borer/Initialize()
	. = ..()
	register_signal(src, SIGNAL_MOB_DEATH, CALLBACK(src, nameof(.proc/on_mob_death)))


/mob/living/simple_animal/borer/Life()

	..()

	if(host)
		if(loc != host) //gib or other forced moving from host
			var/stored_loc = loc //leave_host() will try to get host's turf but it is bad
			detatch()
			leave_host()
			forceMove(stored_loc)
			return
		health = min(health + 1, maxHealth)
		if(!stat && !host.is_ic_dead())
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
					host.emote("[pick(list("blink","blink_r","choke","aflap","drool","twitch","twitch_v","gasp"))]")
		else if((is_ooc_dead() || host.is_ooc_dead()) && controlling)
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
	if(host)
		oxygen_alert = 0
		toxins_alert = 0
		return
	..()

//Procs for grabbing players.
/mob/living/simple_animal/borer/proc/request_player()
	var/datum/ghosttrap/G = get_ghost_trap("cortical borer")
	G.request_player(src, "A cortical borer needs a player.")

/mob/living/simple_animal/borer/attack_ghost(mob/observer/ghost/user)
	if(client)
		return ..()

	if(jobban_isbanned(user, MODE_BORER))
		to_chat(user, SPAN("danger", "You are banned from playing a borer."))
		return

	var/confirm = alert(user, "Are you sure you want to join as a borer?", "Become Borer", "No", "Yes")

	if(!src || confirm != "Yes")
		return

	if(!user || !user.ckey)
		return

	if(client) //Already occupied.
		to_chat(user, "Too slow...")
		return

	ckey = user.ckey

	if(mind && !GLOB.borers.is_antagonist(mind))
		GLOB.borers.add_antagonist(mind, 1, 0, 0)

	spawn(-1)
		if(user)
			qdel(user) // Remove the keyless ghost if it exists.

/decl/simple_animal_bodyparts/borer
	hit_zones = list("head", "central segment", "tail segment")
