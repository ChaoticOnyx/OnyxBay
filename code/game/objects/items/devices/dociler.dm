/obj/item/device/dociler
	name = "dociler"
	desc = "A complex single use recharging injector that spreads a complex neurological serum that makes animals docile and friendly."
	w_class = ITEM_SIZE_NORMAL
	origin_tech = list(TECH_BIO = 5, TECH_MATERIAL = 2)
	icon_state = "animal_tagger1"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/onmob/items/lefthand_guns.dmi',
		slot_r_hand_str = 'icons/mob/onmob/items/righthand_guns.dmi',
		)
	item_state = "gun"
	force = 1
	var/loaded = 1

	var/state = 1
	var/mode = "completely"
	var/mob/living/simple_animal/mob

/obj/item/device/dociler/examine(mob/user)
	. = ..()
	. += SPAN("notice", "It is currently set to [mode] docile mode.")

/obj/item/device/dociler/attack_self(mob/user)
	if(state == 3)
		mode = "completely"
		state = 1
	else if(state == 1)
		mode = "somewhat"
		state = 2
	else if(state == 2)
		mode = "naming"
		state = 3
	to_chat(user, "You set \the [src] to [mode] docile mode.")

/obj/item/device/dociler/proc/rename(var/mob/living/L, var/mob_name)
	if(length(mob_name))
		L.real_name = mob_name
		L.SetName(mob_name)

/obj/item/device/dociler/proc/make_friendly(var/mob/living/simple_animal/hostile/H, var/mob/U)
	H.LoseTarget()
	H.attack_same = 0
	H.friends += weakref(U)

/obj/item/device/dociler/attack(mob/living/L, mob/user)
	if(!istype(L, /mob/living/simple_animal))
		to_chat(user, SPAN("warning", "\The [src] cannot not work on \the [L]."))
		return
	if(!loaded)
		to_chat(user, SPAN("warning", "The [src] isn't loaded!"))
		return
	else
		mob = L
		user.visible_message("\The [user] thrusts \the [src] deep into \the [L]'s head, injecting something!")
		var/new_name = sanitize(input("How do you want to name this creature?", "Rename \the [mob.name]", mob.name) as null|text)
		switch(state)
			if(1)
				if(istype(L,/mob/living/simple_animal/hostile))
					to_chat(L, SPAN("notice", "You feel pain as \the [user] injects something into you. All of a sudden you feel as if all the galaxy are your friends."))
					L.faction = null
					L.desc += SPAN("notice", "It looks especially docile.")
					loaded = 0
					icon_state = "animal_tagger0"
					make_friendly(L, user)
					rename(L, new_name)
			if(2)
				if(istype(L,/mob/living/simple_animal/hostile))
					to_chat(L, SPAN("notice", "You feel pain as \the [user] injects something into you. All of a sudden you feel as if [user] is the friendliest and nicest person you've ever know. You want to be friends with him and all his friends."))
					L.faction = user.faction
					L.desc += SPAN("notice", "It looks especially docile.")
					loaded = 0
					icon_state = "animal_tagger0"
					make_friendly(L, user)
					rename(L, new_name)
			if(3)
				var/mob/living/simple_animal/A = L
				if(A.renamable)
					rename(L, new_name)

	spawn(1450)
		loaded = 1
		icon_state = "animal_tagger1"
		src.visible_message("\The [src] beeps, refilling itself.")
