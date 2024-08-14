// fun if you want to typecast humans/monkeys/etc without writing long path-filled lines.
/proc/isxenomorph(A)
	if(istype(A, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = A
		return istype(H.species, /datum/species/xenos)
	return 0

/proc/issmall(A)
	if(A && istype(A, /mob/living))
		var/mob/living/L = A
		return L.mob_size <= MOB_SMALL
	return 0

//returns the number of size categories between two mob_sizes, rounded. Positive means A is larger than B
/proc/mob_size_difference(mob_size_A, mob_size_B)
	return round(log(2, mob_size_A/mob_size_B), 1)

/mob/proc/can_wield_item(obj/item/W)
	if(W.w_class >= ITEM_SIZE_LARGE && issmall(src))
		return FALSE //M is too small to wield this
	return TRUE

/mob/living/proc/isSynthetic()
	return 0

/mob/living/carbon/human/isSynthetic()
	if(isnull(full_prosthetic))
		robolimb_count = 0
		for(var/obj/item/organ/external/E in organs)
			if(BP_IS_ROBOTIC(E))
				robolimb_count++
		full_prosthetic = (robolimb_count == organs.len)
	return full_prosthetic

/mob/living/silicon/isSynthetic()
	return 1

/proc/isMonkey(A)
	if (istype(A,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = A
		return istype(H.species, /datum/species/monkey)
	return 0

/proc/isdeaf(A)
	if(isliving(A))
		var/mob/living/M = A
		return (M.sdisabilities & DEAF) || M.ear_deaf
	return 0

/proc/hasorgans(A) // Fucking really??
	return ishuman(A)

/proc/iscuffed(A)
	if(istype(A, /mob/living/carbon))
		var/mob/living/carbon/C = A
		if(C.handcuffed)
			return 1
	return 0

/proc/hassensorlevel(A, level)
	var/mob/living/carbon/human/H = A
	if(istype(H) && istype(H.w_uniform, /obj/item/clothing/under))
		var/obj/item/clothing/under/U = H.w_uniform
		return U.sensor_mode >= level
	return 0

/proc/getsensorlevel(A)
	var/mob/living/carbon/human/H = A
	if(istype(H) && istype(H.w_uniform, /obj/item/clothing/under))
		var/obj/item/clothing/under/U = H.w_uniform
		return U.sensor_mode
	return SUIT_SENSOR_OFF


/proc/is_admin(mob/user)
	return check_rights(R_ADMIN, 0, user) != 0

/*
	Miss Chance
*/

//TODO: Integrate defence zones and targeting body parts with the actual organ system, move these into organ definitions.

//The base miss chance for the different defence zones
var/list/global/base_miss_chance = list(
	BP_HEAD = 25,
	BP_CHEST = 10,
	BP_GROIN = 20,
	BP_L_LEG = 30,
	BP_R_LEG = 30,
	BP_L_ARM = 25,
	BP_R_ARM = 25,
	BP_L_HAND = 40,
	BP_R_HAND = 40,
	BP_L_FOOT = 60,
	BP_R_FOOT = 60,
)

//Used to weight organs when an organ is hit randomly (i.e. not a directed, aimed attack).
//Also used to weight the protection value that armour provides for covering that body part when calculating protection from full-body effects.
var/list/global/organ_rel_size = list(
	BP_HEAD = 25,
	BP_CHEST = 70,
	BP_GROIN = 30,
	BP_L_LEG = 25,
	BP_R_LEG = 25,
	BP_L_ARM = 25,
	BP_R_ARM = 25,
	BP_L_HAND = 10,
	BP_R_HAND = 10,
	BP_L_FOOT = 10,
	BP_R_FOOT = 10,
)

/proc/check_zone(zone)
	if(!zone)	return BP_CHEST
	switch(zone)
		if(BP_EYES)
			zone = BP_HEAD
		if(BP_MOUTH)
			zone = BP_HEAD
	return zone

// Returns zone with a certain probability. If the probability fails, or no zone is specified, then a random body part is chosen.
// Do not use this if someone is intentionally trying to hit a specific body part.
// Use get_zone_with_miss_chance() for that.
/proc/ran_zone(zone, probability)
	if (zone)
		zone = check_zone(zone)
		if (prob(probability))
			return zone

	var/ran_zone = zone
	while (ran_zone == zone)
		ran_zone = pick (
			organ_rel_size[BP_HEAD];   BP_HEAD,
			organ_rel_size[BP_CHEST];  BP_CHEST,
			organ_rel_size[BP_GROIN];  BP_GROIN,
			organ_rel_size[BP_L_ARM];  BP_L_ARM,
			organ_rel_size[BP_R_ARM];  BP_R_ARM,
			organ_rel_size[BP_L_LEG];  BP_L_LEG,
			organ_rel_size[BP_R_LEG];  BP_R_LEG,
			organ_rel_size[BP_L_HAND]; BP_L_HAND,
			organ_rel_size[BP_R_HAND]; BP_R_HAND,
			organ_rel_size[BP_L_FOOT]; BP_L_FOOT,
			organ_rel_size[BP_R_FOOT]; BP_R_FOOT,
		)

	return ran_zone

// Emulates targetting a specific body part, and miss chances
// May return null if missed
// miss_chance_mod may be negative.
/proc/get_zone_with_miss_chance(zone, mob/target, miss_chance_mod = 0, ranged_attack=0)
	zone = check_zone(zone)

	if(!ranged_attack)
		// target isn't trying to fight
		if(target.a_intent == I_HELP)
			return zone
		// you cannot miss if your target is prone or restrained
		if(target.buckled || target.lying)
			return zone
		// if your target is being grabbed aggressively by someone you cannot miss either
		for(var/obj/item/grab/G in target.grabbed_by)
			if(G.stop_move())
				return zone

	var/miss_chance = 10
	if (zone in base_miss_chance)
		miss_chance = base_miss_chance[zone]
	miss_chance = max(miss_chance + miss_chance_mod, 0)
	if(prob(miss_chance))
		if(prob(0))
			return null
		return pick(base_miss_chance)
	return zone


/proc/stars(message, not_changing_char_chance = 25)
	if (not_changing_char_chance < 0)
		return null
	if (not_changing_char_chance >= 100)
		return message

	var/message_length = length_char(message)
	var/output_message = ""
	var/intag = FALSE

	var/first_char = copytext_char(message, 1, 2) //for not to processing message as emote if first char would made into "*"
	if (first_char == "<")
		intag = TRUE
	output_message = text("[][]", output_message, first_char)

	var/pointer = 2

	while(pointer <= message_length)
		var/char = copytext_char(message, pointer, pointer + 1)
		if (char == "<") //let's try to not break tags
			intag = TRUE
		if (intag || char == " " || prob(not_changing_char_chance))
			output_message = text("[][]", output_message, char)
		else
			output_message = text("[]*", output_message)
		if (char == ">")
			intag = FALSE
		pointer++
	return output_message

// This is temporary effect, often caused by alcohol
/proc/slur(phrase)
	phrase = html_decode(phrase)
	var/new_phrase = ""
	var/list/replacements_consonants = list(
		"s" = "ch", "c" = "k",
		"г" = "х", "к" = "х", "з" = "с", "ц" = "с", "ч" = "щ", "щ" = "шш", "п" = "б"
		)
	var/list/replacements_vowels = list(
		"o" = "u",
		"ы" = "'", "а" = "'", "е" = "э", "ё" = "'", "и" = "'", "о" = "'", "у" = "'", "ю" = "'"
		)
	for(var/i = 1, i <= length_char(phrase), i++)
		var/letter = copytext_char(phrase, i, i + 1)
		if(lowertext(letter) in replacements_consonants)
			if(prob(40))
				letter = replacements_consonants[lowertext(letter)]
		else if(lowertext(letter) in replacements_vowels)
			if(prob(12))
				letter = replacements_vowels[lowertext(letter)]
		new_phrase += pick(
			65; letter,
			20; lowertext(letter),
			15; uppertext(letter),
			)
	return html_encode(new_phrase)

// This is temporary effect, often caused by shock
/proc/stutter(phrase)
	phrase = html_decode(phrase)
	var/new_phrase = ""
	for(var/i = 1, i <= length_char(phrase), i++)
		var/letter = copytext_char(phrase, i, i + 1)
		new_phrase += letter
		if(lowertext(letter) in list("б", "г", "д", "к", "п", "т", "ц", "ч", "b", "c", "d", "f", "g", "j", "k", "p", "q", "t", "x"))
			while(prob(45))
				new_phrase += "-[letter]"
	return html_encode(new_phrase)

/proc/Gibberish(t, p)//t is the inputted message, and any value higher than 70 for p will cause letters to be replaced instead of added
	/* Turn text into complete gibberish! */
	var/returntext = ""
	for(var/i = 1, i <= length_char(t), i++)

		var/letter = copytext_char(t, i, i+1)
		if(prob(50))
			if(p >= 70)
				letter = ""

			for(var/j = 1, j <= rand(0, 2), j++)
				letter += pick("#","@","*","&","%","$","/", "<", ">", ";","*","*","*","*","*","*","*")

		returntext += letter

	return returntext


/proc/ninjaspeak(n)
/*
The difference with stutter is that this proc can stutter more than 1 letter
The issue here is that anything that does not have a space is treated as one word (in many instances). For instance, "LOOKING," is a word, including the comma.
It's fairly easy to fix if dealing with single letters but not so much with compounds of letters./N
*/
	var/te = html_decode(n)
	var/t = ""
	n = length_char(n)
	var/p = 1
	while(p <= n)
		var/n_letter
		var/n_mod = rand(1,4)
		if(p+n_mod>n+1)
			n_letter = copytext(te, p, n+1)
		else
			n_letter = copytext(te, p, p+n_mod)
		if (prob(50))
			if (prob(30))
				n_letter = text("[n_letter]-[n_letter]-[n_letter]")
			else
				n_letter = text("[n_letter]-[n_letter]")
		else
			n_letter = text("[n_letter]")
		t = text("[t][n_letter]")
		p=p+n_mod
	return sanitize(t)

/mob/proc/log_message(message, message_type, message_tag)
	if(!LAZYLEN(message) || !message_type)
		return

	if(!islist(logging[message_type]))
		logging[message_type] = list()

	var/list/message_data = list("message" = message, "tag" = message_tag)

	var/list/timestamped_message = list("[LAZYLEN(logging[message_type]) + 1]\[[time_stamp()]\] [message_tag] [key_name(src)]" = message_data)

	logging[message_type] += timestamped_message

/proc/shake_camera(mob/M, duration, strength=1)
	if(!M || !M.client || M.shakecamera || M.stat || isEye(M) || isAI(M))
		return
	M.shakecamera = 1
	spawn(1)
		if(!M.client)
			return

		var/atom/oldeye=M.client.eye
		var/aiEyeFlag = 0
		if(istype(oldeye, /mob/observer/eye/aiEye))
			aiEyeFlag = 1

		var/x
		for(x=0; x<duration, x++)
			if(!M.client)
				return

			if(aiEyeFlag)
				M.client.eye = locate(dd_range(1,oldeye.loc.x+rand(-strength,strength),world.maxx),dd_range(1,oldeye.loc.y+rand(-strength,strength),world.maxy),oldeye.loc.z)
			else
				M.client.eye = locate(dd_range(1,M.loc.x+rand(-strength,strength),world.maxx),dd_range(1,M.loc.y+rand(-strength,strength),world.maxy),M.loc.z)
			sleep(1)
		M.client.eye=oldeye
		M.shakecamera = 0


/proc/findname(msg)
	for(var/mob/M in SSmobs.mob_list)
		if (M.real_name == text("[msg]"))
			return 1
	return 0


/mob/proc/abiotic(full_body = FALSE)
	if(full_body && ((src.l_hand && src.l_hand.simulated) || (src.r_hand && src.r_hand.simulated) || (src.back || src.wear_mask)))
		return TRUE

	if((src.l_hand && src.l_hand.simulated) || (src.r_hand && src.r_hand.simulated))
		return TRUE

	return FALSE

//converts intent-strings into numbers and back
var/list/intents = list(I_HELP,I_DISARM,I_GRAB,I_HURT)
/proc/intent_numeric(argument)
	if(istext(argument))
		switch(argument)
			if(I_HELP)		return 0
			if(I_DISARM)	return 1
			if(I_GRAB)		return 2
			else			return 3
	else
		switch(argument)
			if(0)			return I_HELP
			if(1)			return I_DISARM
			if(2)			return I_GRAB
			else			return I_HURT

//change a mob's act-intent. Input the intent as a string such as "help" or use "right"/"left
/mob/verb/a_intent_change(input as text)
	set name = "a-intent"
	set hidden = 1

	if(ishuman(src) || isbrain(src) || ismetroid(src))
		switch(input)
			if(I_HELP,I_DISARM,I_GRAB,I_HURT)
				a_intent = input
			if("right")
				a_intent = intent_numeric((intent_numeric(a_intent)+1) % 4)
			if("left")
				a_intent = intent_numeric((intent_numeric(a_intent)+3) % 4)

		if(is_pacifist(src))
			a_intent = I_HELP

		if(hud_used && hud_used.action_intent)
			hud_used.action_intent.icon_state = "intent_[a_intent]"

	else if(isrobot(src))
		switch(input)
			if(I_HELP)
				a_intent = I_HELP
			if(I_HURT)
				a_intent = I_HURT
			if("right","left")
				a_intent = intent_numeric(intent_numeric(a_intent) - 3)

		if(is_pacifist(src))
			a_intent = I_HELP

		if(hud_used && hud_used.action_intent)
			if(a_intent == I_HURT)
				hud_used.action_intent.icon_state = I_HURT
			else
				hud_used.action_intent.icon_state = I_HELP

/proc/is_blind(A)
	if(istype(A, /mob/living/carbon))
		var/mob/living/carbon/C = A
		if(C.sdisabilities & BLIND || C.blinded)
			return 1
	return 0

/proc/is_pacifist(A)
	if(istype(A, /mob/living))
		var/mob/living/C = A
		return HAS_TRAIT(C, TRAIT_PACIFISM)
	return 0

/proc/broadcast_security_hud_message(message, broadcast_source)
	broadcast_hud_message(message, broadcast_source, GLOB.sec_hud_users, /obj/item/clothing/glasses/hud)

/proc/broadcast_medical_hud_message(message, broadcast_source)
	broadcast_hud_message(message, broadcast_source, GLOB.med_hud_users, /obj/item/clothing/glasses/hud)

/proc/broadcast_hud_message(message, broadcast_source, list/targets, icon)
	var/turf/sourceturf = get_turf(broadcast_source)
	for(var/mob/M in targets)
		var/turf/targetturf = get_turf(M)
		if(!sourceturf || (targetturf.z in GetConnectedZlevels(sourceturf.z)))
			M.show_message("<span class='info'>\icon[icon] [message]</span>", 1)

/proc/mobs_in_area(area/A)
	var/list/mobs = new
	for(var/mob/living/M in SSmobs.mob_list)
		if(get_area(M) == A)
			mobs += M
	return mobs

//Announces that a ghost has joined/left, mainly for use with wizards
/proc/announce_ghost_joinleave(O, joined_ghosts = 1, message = "")
	var/client/C
	//Accept any type, sort what we want here
	if(istype(O, /mob))
		var/mob/M = O
		if(M.client)
			C = M.client
	else if(istype(O, /client))
		C = O
	else if(istype(O, /datum/mind))
		var/datum/mind/M = O
		var/mob/living/original_mob = M.original_mob?.resolve()
		if(M.current?.client)
			C = M.current.client
		else if(istype(original_mob) && original_mob.client)
			C = original_mob.client

	if(C)
		var/name = key_name(C)
		var/diedat = ""
		if(C.mob.lastarea)
			diedat = " at [C.mob.lastarea]"
		if(joined_ghosts)
			message = "The ghost of <span class='name'>[name]</span> now [pick("skulks","lurks","prowls","creeps","stalks")] among the dead[diedat]. [message]"
		else
			message = "<span class='name'>[name]</span> no longer [pick("skulks","lurks","prowls","creeps","stalks")] in the realm of the dead. [message]"
		communicate(/decl/communication_channel/dsay, C || O, message, /decl/dsay_communication/direct)

/mob/proc/switch_to_camera(obj/machinery/camera/C)
	if (!C.can_use() || stat || (get_dist(C, src) > 1 || machine != src || blinded))
		return 0
	check_eye(src)
	return 1

/mob/living/silicon/ai/switch_to_camera(obj/machinery/camera/C)
	if(!C.can_use() || !is_in_chassis())
		return 0

	eyeobj.setLoc(C)
	return 1

// Returns true if the mob has a client which has been active in the last given X minutes.
/mob/proc/is_client_active(active = 1)
	return client && client.inactivity < active MINUTES

/mob/proc/can_eat()
	return 1

/mob/proc/can_force_feed()
	return 1

#define SAFE_PERP -50
/mob/living/proc/assess_perp(obj/access_obj, check_access, auth_weapons, check_records, check_arrest)
	if(is_ooc_dead())
		return SAFE_PERP

	return 0

/mob/living/carbon/assess_perp(obj/access_obj, check_access, auth_weapons, check_records, check_arrest)
	if(handcuffed)
		return SAFE_PERP

	return ..()

/mob/living/carbon/human/assess_perp(obj/access_obj, check_access, auth_weapons, check_records, check_arrest)
	var/threatcount = ..()
	if(. == SAFE_PERP)
		return SAFE_PERP

	//Agent cards lower threatlevel.
	var/obj/item/card/id/id = get_id_card()
	if(id && istype(id, /obj/item/card/id/syndicate))
		threatcount -= 2
	// A proper	CentCom id is hard currency.
	else if(id && istype(id, /obj/item/card/id/centcom))
		return SAFE_PERP

	if(check_access && !access_obj.allowed(src))
		threatcount += 4

	if(auth_weapons && !access_obj.allowed(src))
		if(istype(l_hand, /obj/item/gun) || istype(l_hand, /obj/item/melee))
			threatcount += 4

		if(istype(r_hand, /obj/item/gun) || istype(r_hand, /obj/item/melee))
			threatcount += 4

		if(istype(belt, /obj/item/gun) || istype(belt, /obj/item/melee))
			threatcount += 2

		if(species.name != SPECIES_HUMAN)
			threatcount += 2

	if(check_records || check_arrest)
		var/perpname = name
		if(id)
			perpname = id.registered_name

		var/datum/computer_file/crew_record/CR = get_crewmember_record(perpname)
		if(check_records && !CR && !isMonkey(src))
			threatcount += 4

		if(check_arrest && CR && (CR.get_criminalStatus() == GLOB.arrest_security_status))
			threatcount += 4

	return threatcount

/mob/living/simple_animal/hostile/assess_perp(obj/access_obj, check_access, auth_weapons, check_records, check_arrest)
	var/threatcount = ..()
	if(. == SAFE_PERP)
		return SAFE_PERP

	if(!istype(src, /mob/living/simple_animal/hostile/retaliate/goat))
		threatcount += 4
	return threatcount

#undef SAFE_PERP

/mob/proc/get_multitool(obj/item/device/multitool/P)
	if(istype(P))
		return P

/mob/observer/ghost/get_multitool()
	return can_admin_interact() && ..(ghost_multitool)

/mob/living/carbon/human/get_multitool()
	return ..(get_active_hand())

/mob/living/silicon/robot/get_multitool()
	return ..(get_active_hand())

/mob/living/silicon/ai/get_multitool()
	return ..(aiMulti)

/proc/get_both_hands(mob/living/carbon/M)
	if(!istype(M))
		return
	var/list/hands = list(M.l_hand, M.r_hand)
	return hands

/mob/proc/refresh_client_images()
	if(client)
		client.images |= client_images

/mob/proc/hide_client_images()
	if(client)
		client.images -= client_images

/mob/proc/add_client_image(image)
	if(image in client_images)
		return
	client_images += image
	if(client)
		client.images += image

/mob/proc/remove_client_image(image)
	client_images -= image
	if(client)
		client.images -= image

/mob/proc/flash_eyes(intensity = FLASH_PROTECTION_MODERATE, override_blindness_check = FALSE, affect_silicon = FALSE, visual = FALSE, type = /atom/movable/screen/fullscreen/flash)
	return

/mob/proc/fully_replace_character_name(new_name, in_depth = TRUE)
	if(!new_name || new_name == real_name)	return 0
	real_name = new_name
	SetName(new_name)
	if(mind)
		mind.name = new_name
	if(dna)
		dna.real_name = real_name
	return 1

/mob/proc/ssd_check()
	return !client && !teleop

/mob/proc/jittery_damage()
	return //Only for living/carbon/human/

/mob/living/carbon/human/jittery_damage()
	var/mob/living/carbon/human/H = src
	var/obj/item/organ/internal/heart/L = H.internal_organs_by_name[BP_HEART]
	if(L && istype(L))
		if(BP_IS_ROBOTIC(L))
			return 0//Robotic hearts don't get jittery.
	if(src.jitteriness >= 400 && prob(5)) //Kills people if they have high jitters.
		if(prob(1))
			L.take_internal_damage(L.max_damage / 2, 0)
			to_chat(src, "<span class='danger'>Something explodes in your heart.</span>")
			admin_victim_log(src, "has taken <b>lethal heart damage</b> at jitteriness level [src.jitteriness].")
		else
			L.take_internal_damage(1, 0)
			to_chat(src, "<span class='danger'>The jitters are killing you! You feel your heart beating out of your chest.</span>")
			admin_victim_log(src, "has taken <i>minor heart damage</i> at jitteriness level [src.jitteriness].")
	return 1

//This gets an input while also checking a mob for whether it is incapacitated or not.
/mob/proc/get_input(message, title, default, choice_type, obj/required_item)
	if(src.incapacitated() || (required_item && !GLOB.hands_state.can_use_topic(required_item,src)))
		return null
	var/choice
	if(islist(choice_type))
		choice = input(src, message, title, default) as null|anything in choice_type
	else
		switch(choice_type)
			if(MOB_INPUT_TEXT)
				choice = input(src, message, title, default) as null|text
			if(MOB_INPUT_NUM)
				choice = input(src, message, title, default) as null|num
			if(MOB_INPUT_MESSAGE)
				choice = input(src, message, title, default) as null|message
	if(isnull(choice) || src.incapacitated() || (required_item && !GLOB.hands_state.can_use_topic(required_item,src)))
		return null
	return choice

// Checks if the mob is eligible for antag automatic/storyteller spawn. Manual role assignment (i.e. runic convert or badmin magic) bypasses this.
/mob/proc/is_eligible_for_antag_spawn(antag_id)
	return FALSE

/**
 * Fancy notifications for ghosts
 *
 * The kitchen sink of notification procs
 *
 * Arguments:
 * * message
 * * ghost_sound sound to play
 * * enter_link Href link to enter the ghost role being notified for
 * * source The source of the notification
 * * alert_overlay The alert overlay to show in the alert message
 * * action What action to take upon the ghost interacting with the notification, defaults to NOTIFY_FOLLOW
 * * flashwindow Flash the byond client window
 * * ignore_key  Ignore keys if they're in the GLOB.poll_ignore list
 * * header The header of the notifiaction
 * * notify_suiciders If it should notify suiciders (who do not qualify for many ghost roles)
 * * notify_volume How loud the sound should be to spook the user
 */
/proc/notify_ghosts(message, ghost_sound = null, atom/source = null, mutable_appearance/alert_overlay = null, action = NOTIFY_JUMP, posses_mob = FALSE, flashwindow = TRUE, ignore_mapload = TRUE, header = null, notify_volume = 75) //Easy notification of ghosts.
	if(ignore_mapload && SSatoms.init_state != INITIALIZATION_INNEW_REGULAR) //don't notify for objects created during a map load
		return

	for(var/mob/observer/ghost/O in GLOB.player_list)

		var/follow_link = ""
		if (source && (action == NOTIFY_FOLLOW || action == NOTIFY_POSSES))
			follow_link = create_ghost_link(O, source, "(F)")

		var/posses_link = posses_mob ? possess_link(O, source) : ""

		to_chat(O, SPAN_NOTICE("[follow_link][message][posses_link]"))

		if(ghost_sound)
			sound_to(O, sound(ghost_sound, repeat = 0, wait = 0, volume = notify_volume, channel = 1))

		if(flashwindow)
			winset(O.client, "mainwindow", "flash=5")

		if(source)
			var/atom/movable/screen/movable/alert/notify_action/A = O.throw_alert("\ref[source]_notify_action", /atom/movable/screen/movable/alert/notify_action)
			if(A)

				var/ui_style = O.client?.prefs?.UI_style

				if(ui_style)
					A.icon = ui_style2icon(ui_style)

				if (header)
					A.name = header

				A.desc = message
				A.action = action
				A.target = source

				if(!alert_overlay)
					alert_overlay = new(source)
					var/icon/size_check = icon(source.icon, source.icon_state)
					var/scale = 1
					var/width = size_check.Width()
					var/height = size_check.Height()

					if(width > world.icon_size || height > world.icon_size)
						if(width >= height)
							scale = world.icon_size / width
						else
							scale = world.icon_size / height

					alert_overlay.transform = alert_overlay.transform.Scale(scale)
					alert_overlay.appearance_flags |= TILE_BOUND

				alert_overlay.layer = FLOAT_LAYER
				alert_overlay.plane = FLOAT_PLANE
				A.AddOverlays(alert_overlay)

/mob/proc/shift_view(new_pixel_x = 0, new_pixel_y = 0, animate = 0)
	if(!client)
		is_view_shifted = FALSE
		return

	var/old_shifted = is_view_shifted
	if(animate)
		animate(client, pixel_x = new_pixel_x, pixel_y = new_pixel_y, time = 2, easing = SINE_EASING)
	else
		client.pixel_x = new_pixel_x
		client.pixel_y = new_pixel_y

	if(new_pixel_x == 0 && new_pixel_y == 0)
		is_view_shifted = FALSE
	else
		is_view_shifted = TRUE

	SEND_SIGNAL(src, SIGNAL_VIEW_SHIFTED_SET, src, old_shifted, is_view_shifted)

/proc/directional_recoil(mob/M, strength=1, angle = 0)
	if(!M || !M.client)
		return
	var/client/C = M.client
	var/recoil_x = -sin(angle) * 4 * strength + rand(-strength, strength)
	var/recoil_y = -cos(angle) * 4 * strength + rand(-strength, strength)
	animate(C, pixel_x = recoil_x, pixel_y = recoil_y, time = 1, easing = SINE_EASING | EASE_OUT, flags = ANIMATION_PARALLEL | ANIMATION_RELATIVE)
	sleep(2)
	animate(C, pixel_x = 0, pixel_y = 0, time = 3, easing = SINE_EASING | EASE_IN)

/mob/verb/open_ghost_arena_menu()
	set category = "Ghost"
	set name = "Ghost arena menu"
	set desc = "Play Toolbox Strike: Greytide Offensive"

	if(isnull(ghost_arena_menu))
		ghost_arena_menu = new(src)

	ghost_arena_menu.tgui_interact(src)
