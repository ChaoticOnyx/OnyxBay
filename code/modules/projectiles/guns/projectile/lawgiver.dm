GLOBAL_LIST_INIT(lawgiver_modes, list(
		list(mode_name = "stun",			fire_delay = 6,		ammo_per_shot = 1,		projectile_type = /obj/item/projectile/energy/electrode/stunsphere, burst = 1, screen_shake = 0, voice_activator = list()),
		list(mode_name = "laser",			fire_delay = 6,		ammo_per_shot = 1,		projectile_type = /obj/item/projectile/beam/laser/small,			burst = 1, screen_shake = 0, voice_activator = list() ),
		list(mode_name = "rapid",			fire_delay = 6,		ammo_per_shot = 1/3,	projectile_type = /obj/item/projectile/bullet/pistol/lawgiver,		burst = 3, screen_shake = 1, voice_activator = list() ),
		list(mode_name = "flash",			fire_delay = 6,		ammo_per_shot = 1,		projectile_type = /obj/item/projectile/energy/flash,				burst = 1, screen_shake = 1, voice_activator = list() ),
		list(mode_name = "armor piercing",	fire_delay = 15,	ammo_per_shot = 1,		projectile_type = /obj/item/projectile/bullet/magnetic/lawgiver,	burst = 1, screen_shake = 1, voice_activator = list()),
		))

/obj/item/gun/projectile/lawgiver
	name = "lawgiver"
	desc = "The Lawgiver II. A twenty-five round sidearm with mission-variable voice-programmed ammunition. \
	You can see the words STUN, LASER, RAPID, FLASH and AP written in small print on its barreling. \
	There's a little notation on it: \"Designed by combat specialist R.R. for combat specialists.\""
	icon_state = "lawgiver"
	item_state = "lawgiver"
	load_method = MAGAZINE
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 5, TECH_ENGINEERING = 5)
	w_class = ITEM_SIZE_NORMAL
	matter = list(MATERIAL_STEEL = 2000)
	magazine_type = /obj/item/ammo_magazine/lawgiver
	allowed_magazines = /obj/item/ammo_magazine/lawgiver
	burst = 1
	screen_shake = 0
	caliber = "lawgiver"
	var/projectile_type = /obj/item/projectile/energy/electrode/stunsphere
	var/dna_profile = null
	var/list/voice_activator
	var/ammo_per_shot = 1

	var/static/voice_activators_init_complete = FALSE

	var/hack_in_progress = FALSE // if anyone remembers how to do it with do_after by internal tools, replace this shit by internal tools
	var/hacks_remains = 3
	has_safety = FALSE

/obj/item/gun/projectile/lawgiver/get_description_info()
	. = ..()
	. += "\n\The [src] fires 5 different types of charges: stun, laser, rapid, flash, armor piercing.\n\
	Charge type selection is controlled by voice.\n\
	For the voice recognition module to work, you must give your DNA to \the [src].\n\
	To reload the gun magazine you must remove it from the gun and place it in the recharger.\n\
	List of words/word combinations to activate different types of charges:\n"
	for(var/list/mode in GLOB.lawgiver_modes)
		. += "[mode["mode_name"]] - [english_list(mode["voice_activator"])]\n"

/obj/item/gun/projectile/lawgiver/proc/init_voice_activators()
	if(voice_activators_init_complete)
		return
	if(!fexists("strings/names/lawgiver.txt"))
		CRASH("Lawgiver voice activators file not found")
	voice_activators_init_complete = TRUE
	var/list/voice_activators = world.file2list("strings/names/lawgiver.txt")
	var/ind
	for(ind = 1, ind <= length(GLOB.lawgiver_modes), ind++)
		GLOB.lawgiver_modes[ind]["voice_activator"] = splittext(voice_activators[ind], ";")

/obj/item/gun/projectile/lawgiver/Initialize()
	init_voice_activators()
	firemodes = GLOB.lawgiver_modes.Copy()
	. = ..()
	verbs -= /obj/item/gun/projectile/lawgiver/verb/erase_DNA_sample
	update_icon()
	// for firemode voice-triggers
	GLOB.listening_objects += src

/obj/item/gun/projectile/lawgiver/equipped(mob/M, hand)
	update_icon()
	return ..()

/obj/item/gun/projectile/lawgiver/dropped(mob/living/user)
	update_icon()
	return ..()

/obj/item/gun/projectile/lawgiver/on_update_icon()
	ClearOverlays()
	var/obj/item/ammo_magazine/lawgiver/M = ammo_magazine
	var/datum/firemode/F = firemodes[sel_mode]
	if(M)
		var/image/magazine_overlay = image('icons/obj/guns/gun.dmi', src, "[initial(icon_state)]Mag")
		var/image/ammo_overlay = null
		var/icon_state_suffix = round(M.ammo_counters[F.name], 1)
		ammo_overlay = image('icons/obj/guns/gun.dmi', src, "[initial(icon_state)][icon_state_suffix]")
		AddOverlays(magazine_overlay)
		AddOverlays(ammo_overlay)

	if (istype(loc,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = loc
		var/image/DNA_overlay = null
		if(istype(H))
			if(dna_profile)
				if(dna_profile == H.dna.unique_enzymes)
					DNA_overlay = image('icons/obj/guns/gun.dmi', src, "[initial(icon_state)]DNAgood")
				else
					DNA_overlay = image('icons/obj/guns/gun.dmi', src, "[initial(icon_state)]DNAbad")
				AddOverlays(DNA_overlay)

/obj/item/gun/projectile/lawgiver/attack_self(mob/user )
	unload_ammo(user)

/obj/item/gun/projectile/lawgiver/consume_next_projectile()
	var/obj/item/ammo_magazine/lawgiver/M = ammo_magazine
	var/datum/firemode/F = firemodes[sel_mode]
	if(!ammo_magazine)
		return
	if(M.ammo_counters[F.name] >= ammo_per_shot)
		M.ammo_counters[F.name] -= ammo_per_shot
		return new projectile_type(src)

/obj/item/gun/projectile/lawgiver/verb/submit_DNA_sample()
	set name = "Submit DNA sample"
	set category = "Object"
	set src in usr

	var/mob/living/carbon/human/H = loc

	if(!dna_profile)
		dna_profile = H.dna.unique_enzymes
		to_chat(usr, SPAN("notice", "You submit a DNA sample to \the [src]."))
		verbs += /obj/item/gun/projectile/lawgiver/verb/erase_DNA_sample
		verbs -= /obj/item/gun/projectile/lawgiver/verb/submit_DNA_sample
		update_icon()
		return 1

/obj/item/gun/projectile/lawgiver/AltClick()
	if(submit_DNA_sample())
		return
	return ..()

/obj/item/gun/projectile/lawgiver/verb/erase_DNA_sample()
	set name = "Erase DNA sample"
	set category = "Object"
	set src in usr

	var/mob/living/carbon/human/H = loc

	if(dna_profile)
		if(dna_profile == H.dna.unique_enzymes)
			to_chat(usr, SPAN("notice", "You erase the DNA profile from \the [src]."))
			remove_dna()
		else
			bad_dna_action(H)

/obj/item/gun/projectile/lawgiver/proc/remove_dna()
	dna_profile = null
	audible_message("<b>\The [src]</b> reports, \"No DNA profile found.\"", splash_override = "No DNA profile found.")
	verbs += /obj/item/gun/projectile/lawgiver/verb/submit_DNA_sample
	verbs -= /obj/item/gun/projectile/lawgiver/verb/erase_DNA_sample
	update_icon()

/obj/item/gun/projectile/lawgiver/emp_act(severity)
	if(ismob(loc) && prob(25))
		bad_dna_action(loc)
		return
	if(prob(35))
		set_firemode(rand(1, length(firemodes)))
		return
	if(prob(80) && ammo_magazine)
		var/obj/item/ammo_magazine/lawgiver/M = ammo_magazine
		M.discharge_magazine()
		update_icon()

/obj/item/gun/projectile/lawgiver/emag_act(remaining_charges, mob/user, emag_source)
	if(--remaining_charges)
		to_chat(user, SPAN("notice", "You short out the DNA profile from \the [src]."))
		remove_dna()
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, 0, src.loc)
		spark_system.start()

/obj/item/gun/projectile/lawgiver/attackby(obj/item/A, mob/user)
	. = ..()
	if(isMultitool(A) && !hack_in_progress)
		if(!dna_profile)
			to_chat(user, SPAN("notice", "You think you're being silly trying to reset the DNA profile from \the [src] because there is no DNA profile here."))
			return
		hack_in_progress = TRUE
		if(do_after(user, 10 SECOND, src, luck_check_type = LUCK_CHECK_COMBAT) && prob(25))
			hack_in_progress = FALSE
			if(--hacks_remains)
				to_chat(user, SPAN("notice", "\The [src] cracks, after a few tries, you will be able to reset the DNA lock."))
			else
				to_chat(user, SPAN("notice", "You reset the DNA profile from \the [src]."))
				remove_dna()
				hacks_remains = initial(hacks_remains)
			var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
			spark_system.set_up(5, 0, src.loc)
			spark_system.start()
		else
			to_chat(user, SPAN("notice", "It looks like the lock is harder than you think. You must make one more attempt to reset it."))
			hack_in_progress = FALSE

/obj/item/gun/projectile/lawgiver/proc/bad_dna_action(mob/user)
	if(access_security in user.GetAccess())
		audible_message("<b>\The [src]</b> reports, \"ERROR: DNA PROFILE DOES NOT MATCH.\"", splash_override = "ERROR: DNA PROFILE DOES NOT MATCH.")
		return
	else
		audible_message("<b>\The [src]</b> reports, \"UNAUTHORIZED ACCESS DETECTED.\"", splash_override = "UNAUTHORIZED ACCESS DETECTED.")
		if(electrocute_mob(user, get_area(src), src, 0.7))
			var/datum/effect/effect/system/spark_spread/spark = new /datum/effect/effect/system/spark_spread()
			spark.set_up(3, 1, src)
			spark.start()
			QDEL_IN(spark, 5)

/obj/item/gun/projectile/lawgiver/special_check(mob/user)
	if(!dna_check(user))
		return FALSE
	return ..()

/obj/item/gun/projectile/lawgiver/proc/dna_check(mob/living/carbon/human/user)
	if(!user)
		if(istype(loc))
			user = loc
		else
			return 0
	if(!istype(user))
		return
	if(dna_profile)
		if(dna_profile != user.dna.unique_enzymes)
			bad_dna_action(user)
			return 0
	else
		handle_click_empty(user)
		audible_message("<b>\The [src]</b> reports, \"PLEASE REGISTER A DNA SAMPLE.\"", splash_override = "PLEASE REGISTER A DNA SAMPLE.")
		return 0
	return 1

/obj/item/gun/projectile/lawgiver/hear_talk(mob/living/M, msg)
	var/mob/living/carbon/human/owner = loc
	// Only gunholder can change firemodes
	if(!istype(owner) || !istype(M) || owner.GetVoice() != M.GetVoice())
		return
	if(!dna_profile)
		return
	if(dna_profile != owner.dna.unique_enzymes)
		return
	var/ind
	msg = sanitize_phrase(lowertext(msg))
	for(var/datum/firemode/F in firemodes)
		ind++
		if(msg in F.settings["voice_activator"])
			set_firemode(ind)

/obj/item/gun/projectile/lawgiver/set_firemode(ind)
	sel_mode = ind
	var/datum/firemode/F = firemodes[sel_mode]
	F.apply_to(src)
	update_icon()
	playsound(playsound(src, 'sound/effects/weapons/energy/toggle_mode1.ogg', rand(50, 75), FALSE))
	audible_message("<b>\The [src]</b> reports, \"[uppertext("[F.name].\"")]", splash_override = "[uppertext("[F.name].\"")]")

/obj/item/gun/projectile/lawgiver/proc/sanitize_phrase(phrase)
	var/list/replacechars = list("'" = "","\"" = "",">" = "","<" = "","(" = "",")" = "","-" = "","," = "",":" = "","!" = "","." = "","?" = "",";" = "")
	//added every char from speechcheker just for sure
	return replace_characters(phrase, replacechars)

/obj/item/gun/projectile/lawgiver/examine(mob/user, infix)
	. = ..()

	var/obj/item/ammo_magazine/lawgiver/M = ammo_magazine
	if(!M)
		return

	. += M.generate_description()
