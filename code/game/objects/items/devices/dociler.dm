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

/obj/item/device/dociler/examine(mob/user)
	. = ..()
	. += SPAN("notice", " It is currently set to [mode] docile mode.")

/obj/item/device/dociler/attack_self(mob/user)
	switch(state)
		if(3)
			mode = "completely"
			state = 1
		if(1)
			mode = "somewhat"
			state = 2
		if(2)
			mode = "naming"
			state = 3
	to_chat(user, "You set \the [src] to [mode] docile mode.")

/obj/item/device/dociler/proc/rename(var/mob/living/simple_animal/L, var/mob/U)
	var/new_name = sanitize(input("How do you want to name this creature?", "Rename \the [L.name]", L.name) as null|text)
	if(new_name)
		log_game("[key_name(U)] named [L.name] as [new_name]")
		L.real_name = L.name = new_name
		L.renamable = FALSE

/obj/item/device/dociler/proc/inject(var/mob/living/simple_animal/hostile/H, var/mob/U)
	//Dociler cooldown
	loaded = 0
	icon_state = "animal_tagger0"
	addtimer(CALLBACK(src, .proc/refill), 5 MINUTES)
	//Mob
	U.visible_message("\The [U] thrusts \the [src] deep into \the [H]'s head, injecting something!")
	H.LoseTarget()
	H.attack_same = 0
	H.friends += weakref(U)
	H.desc += SPAN("notice", " It looks especially docile.")

/obj/item/device/dociler/proc/refill()
	loaded = 1
	icon_state = "animal_tagger1"
	src.visible_message("\The [src] beeps, refilling itself.")

/obj/item/device/dociler/attack(mob/living/L, mob/user)
	if(!istype(L, /mob/living/simple_animal))
		to_chat(user, SPAN("warning", "\The [src] cannot not work on \the [L]."))
		return
	if(L.stat == DEAD)
		to_chat(user, SPAN("warning", "The [L] is completely dead!"))
		return
	if(!loaded)
		to_chat(user, SPAN("warning", "The [src] isn't loaded!"))
		return
	else
		switch(state)
			if(1)
				if(istype(L,/mob/living/simple_animal/hostile))
					to_chat(L, SPAN("notice", "You feel pain as \the [user] injects something into you. All of a sudden you feel as if all the galaxy are your friends."))
					L.faction = null
					inject(L, user)
					rename(L, user)
			if(2)
				if(istype(L,/mob/living/simple_animal/hostile))
					to_chat(L, SPAN("notice", "You feel pain as \the [user] injects something into you. All of a sudden you feel as if [user] is the friendliest and nicest person you've ever know. You want to be friends with him and all his friends."))
					L.faction = user.faction
					inject(L, user)
					rename(L, user)
			if(3)
				var/mob/living/simple_animal/A = L
				if(A?.renamable)
					rename(L, user)
