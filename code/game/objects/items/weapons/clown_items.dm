/* Clown Items
 * Contains:
 *		Bike Horns and C-Taperecorder
 */

/*
 * Bike Horns
 */
/obj/item/bikehorn
	name = "bike horn"
	desc = "A horn off of a bicycle."
	icon = 'icons/obj/items.dmi'
	icon_state = "bike_horn"
	item_state = "bike_horn"
	throwforce = 3
	w_class = ITEM_SIZE_SMALL
	mod_weight = 0.25
	mod_reach = 0.5
	mod_handy = 0.5
	throw_range = 15
	attack_verb = "HONKED"
	var/spam_flag = 0

/obj/item/bikehorn/attack_self(mob/user)
	if(spam_flag == 0)
		spam_flag = 1
		playsound(src.loc, 'sound/items/bikehorn.ogg', 50, 1)
		src.add_fingerprint(user)
		spawn(20)
			spam_flag = 0
	return

//Oh no
/obj/item/bikehorn/vuvuzela
	name = "VUVUZELA"
	desc = "RIPS YOUR EARS OFF!!!"
	icon_state = "vuvuzela"
	item_state = "vuvuzela"
	w_class = ITEM_SIZE_NORMAL
	mod_weight = 0.5
	mod_reach = 1.0
	mod_handy = 0.5
	attack_verb = list("HONKED","WORLD CUPPED","FOOTBALLED")

/obj/item/bikehorn/vuvuzela/attack_self(mob/user)
	if (spam_flag == 0)
		spam_flag = 1
		playsound(src.loc, 'sound/items/AirHorn.ogg', 100, 1)
		src.add_fingerprint(user)
		spawn(20)
			spam_flag = 0
	return

/obj/item/bikehorn/vuvuzela/traitor

/obj/item/bikehorn/vuvuzela/traitor/attack_self(mob/user)
	if (spam_flag == 0)
		spam_flag = 1
		playsound(src.loc, 'sound/items/AirHorn.ogg', 100, 1)
		src.add_fingerprint(user)
		if(prob(33))
			for(var/mob/living/carbon/M in ohearers(3, src))
				if(istype(M, /mob/living/carbon/human))
					if(M.get_ear_protection() > 2)
						continue
				M.sleeping = 0
				M.stuttering += 20
				M.ear_deaf += 20
				M.Weaken(3)
				if(prob(30))
					M.Stun(10)
					M.Paralyse(4)
		spawn(50)
			spam_flag = 0
	return

//Ha-ha-ha
/obj/item/device/clowntaperecorder
	name = "clown taperecorder"
	desc = "A funny-looking tiny taperecorder. It smells like bananas."
	icon = 'icons/obj/device.dmi'
	icon_state = "stereo"
	item_state = "stereo"
	throwforce = 5
	w_class = ITEM_SIZE_SMALL
	mod_weight = 0.5
	mod_reach = 0.5
	mod_handy = 0.5
	throw_range = 15
	attack_verb = "HONKED"

	var/spam_flag = FALSE
	var/spam_cooldown = 10 SECONDS

	var/current_honk_sound = 1
	var/static/list/honk_sounds = list(
		'sound/items/sitcom_laugh.ogg',
		'sound/items/ba_dum_tss.ogg'
	)

/obj/item/device/clowntaperecorder/attack_self(mob/user)
	if(spam_flag)
		to_chat(user, SPAN("notice", "\The [src] needs a moment to rewind."))
		return

	spam_flag = TRUE
	playsound(loc, honk_sounds[current_honk_sound], 100, TRUE)
	add_fingerprint(user)
	flick("[icon_state]_playing", src)

	set_next_think(world.time + spam_cooldown)
	return

/obj/item/device/clowntaperecorder/think()
	spam_flag = FALSE
	return

/obj/item/device/clowntaperecorder/verb/change_sound()
	set name = "Change Taperecorder Sound"
	set category = "Object"
	set src in usr

	if(!isliving(usr))
		to_chat(usr, SPAN("warning", "You can't do that."))
		return

	var/mob/living/L = usr

	if(L.incapacitated())
		return

	current_honk_sound = (current_honk_sound == length(honk_sounds) ? 1 : current_honk_sound + 1)
	to_chat(L, SPAN("notice", "You press a tiny button on \the [src] and wonder what comes next."))
	return
