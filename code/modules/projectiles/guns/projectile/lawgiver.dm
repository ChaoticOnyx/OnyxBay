GLOBAL_LIST_INIT(lawgiver_modes, list(
		list(mode_name = "stun",			fire_delay = 6,		ammo_per_shot = 1,		projectile_type = /obj/item/projectile/energy/electrode/stunsphere, burst = 1, screen_shake = 0, voice_activator = list("stun", "taser", "стан", "тазер", "оглушающий")),
		list(mode_name = "laser",			fire_delay = 6,		ammo_per_shot = 1,		projectile_type = /obj/item/projectile/beam/smalllaser,				burst = 1, screen_shake = 0, voice_activator = list("laser", "lethal", "beam", "лазер", "летал", "луч") ),
		list(mode_name = "rapid",			fire_delay = 6,		ammo_per_shot = 1/3,	projectile_type = /obj/item/projectile/bullet/pistol/lawgiver,		burst = 3, screen_shake = 1, voice_activator = list("rapid", "auto", "рапид", "авто", "автоматический") ),
		list(mode_name = "flash",			fire_delay = 6,		ammo_per_shot = 1,		projectile_type = /obj/item/projectile/energy/flash,				burst = 1, screen_shake = 1, voice_activator = list("flash", "signal", "флеш", "сигнальный") ),
		list(mode_name = "armor piercing",	fire_delay = 15,	ammo_per_shot = 1,		projectile_type = /obj/item/projectile/bullet/magnetic/lawgiver,	burst = 1, screen_shake = 1, voice_activator = list("armor piercing", "ap", "бронебойный", "бб")),
		))

/obj/item/gun/projectile/lawgiver
	name = "lawgiver"
	desc = "The Lawgiver II. A twenty-five round sidearm with mission-variable voice-programmed ammunition. You can see the words STUN, LASER, RAPID, FLASH and AP written in small print on its barreling."
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

/obj/item/gun/projectile/lawgiver/New()
	firemodes = GLOB.lawgiver_modes.Copy()
	..()
	verbs -= /obj/item/gun/projectile/lawgiver/verb/erase_DNA_sample
	update_icon()
	// for firemode voice-triggers
	GLOB.listening_objects += src

/obj/item/gun/projectile/lawgiver/equipped(mob/M, hand)
	update_icon()

/obj/item/gun/projectile/lawgiver/update_icon()
	overlays.Cut()
	var/obj/item/ammo_magazine/lawgiver/M = ammo_magazine
	var/datum/firemode/F = firemodes[sel_mode]
	if(M)
		var/image/magazine_overlay = image('icons/obj/gun.dmi', src, "[initial(icon_state)]Mag")
		var/image/ammo_overlay = null
		var/icon_state_suffix = round(M.ammo_counters[F.name], 1)
		ammo_overlay = image('icons/obj/gun.dmi', src, "[initial(icon_state)][icon_state_suffix]")
		overlays += magazine_overlay
		overlays += ammo_overlay

	if (istype(loc,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = loc
		var/image/DNA_overlay = null
		if(istype(H))
			if(dna_profile)
				if(dna_profile == H.dna.unique_enzymes)
					DNA_overlay = image('icons/obj/gun.dmi', src, "[initial(icon_state)]DNAgood")
				else
					DNA_overlay = image('icons/obj/gun.dmi', src, "[initial(icon_state)]DNAbad")
				overlays += DNA_overlay

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
			dna_profile = null
			to_chat(usr, SPAN("notice", "You erase the DNA profile from \the [src]."))
			verbs += /obj/item/gun/projectile/lawgiver/verb/submit_DNA_sample
			verbs -= /obj/item/gun/projectile/lawgiver/verb/erase_DNA_sample
			update_icon()
		else
			bad_dna_action(H)

/obj/item/gun/projectile/lawgiver/proc/bad_dna_action(mob/user)
	if(access_security in user.GetAccess())
		audible_message("<b>\The [src]</b> reports, \"ERROR: DNA PROFILE DOES NOT MATCH.\"")
		return
	else
		audible_message("<b>\The [src]</b> reports, \"UNAUTHORIZED ACCESS DETECTED.\"")
		if(electrocute_mob(user, get_area(src), src, 0.7))
			var/datum/effect/effect/system/spark_spread/spark = new /datum/effect/effect/system/spark_spread()
			spark.set_up(3, 1, src)
			spark.start()

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
		audible_message("<b>\The [src]</b> reports, \"PLEASE REGISTER A DNA SAMPLE.\"")
		return 0
	return 1

/obj/item/gun/projectile/lawgiver/hear_talk(mob/M, msg)
	var/mob/living/carbon/human/H = loc
	// Only gunholder can change firemodes
	if(!istype(H) && H != M)
		return
	if(!dna_profile)
		return
	if(dna_profile != H.dna.unique_enzymes)
		return
	var/ind
	msg = sanitize_phrase(lowertext(msg))
	for(var/datum/firemode/F in firemodes)
		ind++
		if(msg in F.settings["voice_activator"])
			sel_mode = ind
			F.apply_to(src)
			update_icon()
			playsound(playsound(src, 'sound/effects/weapons/energy/toggle_mode1.ogg', rand(50, 75), FALSE))
			audible_message("<b>\The [src]</b> reports, \"[uppertext("[F.name].\"")]")

/obj/item/gun/projectile/lawgiver/proc/sanitize_phrase(phrase)
	var/list/replacechars = list("'" = "","\"" = "",">" = "","<" = "","(" = "",")" = "","-" = "","," = "",":" = "","!" = "","." = "","?" = "",";" = "")
	//added every char from speechcheker just for sure
	return replace_characters(phrase, replacechars)

/obj/item/gun/projectile/lawgiver/examine(mob/user)
	. =..()
	var/obj/item/ammo_magazine/lawgiver/M = ammo_magazine
	if(!M)
		return
	. += M.generate_description()
