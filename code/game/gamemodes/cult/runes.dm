/obj/effect/rune
	name = "rune"
	desc = "A strange collection of symbols drawn in blood."
	icon = 'icons/effects/uristrunes.dmi'
	icon_state = "blank"
	anchored = TRUE
	unacidable = TRUE
	layer = RUNE_LAYER

	var/blood
	var/bcolor
	var/strokes = 2 // IF YOU EVER SET THIS TO MORE THAN TEN, EVERYTHING WILL BREAK
	var/cultname = ""
	var/animated = FALSE //Whether the rune is pulsating

/obj/effect/rune/New(loc, blcolor = "#c80000", nblood = "blood")
	..()
	bcolor = blcolor
	blood = nblood
	update_icon()

/obj/effect/rune/on_update_icon()
	ClearOverlays()
	if(GLOB.cult.rune_strokes[type])
		var/list/f = GLOB.cult.rune_strokes[type]
		for(var/i in f)
			AddOverlays(image(make_uristword(i, animated)))
	else
		var/list/q = list(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
		var/list/f = list()
		for(var/i = 1 to strokes)
			var/j = pick(q)
			f += j
			q -= f
			AddOverlays(image(make_uristword(j, animated)))
		GLOB.cult.rune_strokes[type] = f.Copy()

	if(animated)
		idle_pulse()
	else
		animate(src)

	desc = "A strange collection of symbols drawn in [blood]."

/obj/effect/rune/proc/make_uristword(word, animated = FALSE)
	var/icon/I = icon('icons/effects/uristrunes.dmi', "blank")
	I.Blend(icon('icons/effects/uristrunes.dmi', "rune-[word]"), ICON_OVERLAY)
	var/finalblood = bcolor
	if (finalblood)
		var/list/blood_hsl = rgb2hsl(GetRedPart(finalblood),GetGreenPart(finalblood),GetBluePart(finalblood))
		var/list/blood_rgb = hsl2rgb(blood_hsl[1],blood_hsl[2],50)//producing a color that is neither too bright nor too dark
		finalblood = rgb(blood_rgb[1],blood_rgb[2],blood_rgb[3])

	var/bc1 = finalblood + "C8"
	var/bc2 = finalblood + "64"

	I.SwapColor(rgb(0, 0, 0, 100), bc1)
	I.SwapColor(rgb(0, 0, 0, 50), bc1)

	for(var/x = 1, x <= WORLD_ICON_SIZE, x++)
		for(var/y = 1, y <= WORLD_ICON_SIZE, y++)
			var/p = I.GetPixel(x, y)

			if(p == null)
				var/n = I.GetPixel(x, y + 1)
				var/s = I.GetPixel(x, y - 1)
				var/e = I.GetPixel(x + 1, y)
				var/w = I.GetPixel(x - 1, y)

				if(n == "#000000" || s == "#000000" || e == "#000000" || w == "#000000")
					I.DrawBox(bc1, x, y)
				else
					var/ne = I.GetPixel(x + 1, y + 1)
					var/se = I.GetPixel(x + 1, y - 1)
					var/nw = I.GetPixel(x - 1, y + 1)
					var/sw = I.GetPixel(x - 1, y - 1)

					if(ne == "#000000" || se == "#000000" || nw == "#000000" || sw == "#000000")
						I.DrawBox(bc2, x, y)

	I.MapColors(0.5,0,0,0,0.5,0,0,0,0.5)//we'll darken that color a bit
	return I

/obj/effect/rune/proc/idle_pulse()
	//This masterpiece of a color matrix stack produces a nice animation no matter which color was the blood used for the rune.
	animate(src, color = list(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0), time = 10, loop = -1)//1
	animate(color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 2)//2
	animate(color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 2)//3
	animate(color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 1.5)//4
	animate(color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 1.5)//5
	animate(color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1)//6
	animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)//7
	animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)//8
	animate(color = list(2,0.67,0.27,0,0.27,2,0.67,0,0.67,0.27,2,0,0,0,0,1,0,0,0,0), time = 5)//9
	animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)//8
	animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)//7
	animate(color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1)//6
	animate(color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 1)//5
	animate(color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 1)//4
	animate(color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 1)//3
	animate(color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 1)//2


/obj/effect/rune/proc/one_pulse()
	animate(src, color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(2,0.67,0.27,0,0.27,2,0.67,0,0.67,0.27,2,0,0,0,0,1,0,0,0,0), time = 2)
	animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 0.75)
	animate(color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 0.75)
	animate(color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 0.5)
	animate(color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 0.5)
	animate(color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 0.25)
	animate(color = list(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0), time = 1)

	spawn(10)
		if(animated)
			idle_pulse()
		else
			animate(src)

/obj/effect/rune/examine(mob/user, infix)
	. = ..()

	if(iscultist(user) || isghost(user))
		. += "This is \a [cultname] rune."

/obj/effect/rune/attackby(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/book/tome) && iscultist(user))
		user.visible_message(SPAN_NOTICE("\The [user] rubs \the [src] with \the [I], and \the [src] is absorbed by it."), "You retrace your steps, carefully undoing the lines of \the [src].")
		qdel(src)
		return
	else if(istype(I, /obj/item/nullrod))
		user.visible_message(SPAN_NOTICE("[user] hits \the [src] with \the [I], and it disappears, fizzling."), SPAN_NOTICE("You disrupt the vile magic with the deadening field of \the [I]."), "You hear a fizzle.")
		qdel(src)
		return

/obj/effect/rune/attack_hand(mob/living/user)
	if(!iscultist(user))
		to_chat(user, "You can't mouth the arcane scratchings without fumbling over them.")
		return
	if(user.is_muzzled() || user.silent)
		to_chat(user, "You are unable to speak the words of the rune.")
		return
	if(GLOB.cult.powerless)
		to_chat(user, "You read the words, but nothing happens.")
		return fizzle(user)
	cast(user)

/obj/effect/rune/attack_ai(mob/living/user) // Cult borgs!
	if(Adjacent(user))
		attack_hand(user)

/obj/effect/rune/attack_generic(mob/living/user) // Cult constructs/metroids/whatnot!
	attack_hand(user)

/obj/effect/rune/proc/cast(mob/living/user)
	fizzle(user)

/obj/effect/rune/proc/get_cultists()
	. = list()
	for(var/mob/living/M in range(1, src))
		if(iscultist(M))
			. += M

/obj/effect/rune/proc/fizzle(mob/living/user)
	visible_message(SPAN_WARNING("The markings pulse with a small burst of light, then fall dark."), "You hear a fizzle.")

//Makes the speech a proc so all verbal components can be easily manipulated as a whole, or individually easily
/obj/effect/rune/proc/speak_incantation(mob/living/user, incantation)
	var/datum/language/L = all_languages[LANGUAGE_CULT]
	if(incantation && (L in user.languages))
		user.say(incantation, L)

/* Tier 1 runes below */

/obj/effect/rune/convert
	cultname = "convert"
	var/spamcheck = FALSE

/obj/effect/rune/convert/proc/antag_check(mob/living/target, list/mob/living/cultists)
	if(!target || !target.mind)
		return FALSE

	if(iscultist(target))
		return FALSE

	if(!cultists.len)
		return FALSE

	if(GLOB.wizards && (target.mind in GLOB.wizards.current_antagonists))
		to_chat(target, SPAN_DANGER("<b>You feel your newfound belief enter your mind as your previous power aggressively channels itself to your new partners' heads. Seems like your initiation cost them their lives.</b>"))
		for(var/mob/living/M in cultists)
			to_chat(M, SPAN_DANGER("<b>You feel a mighty mental force break into your mind as it clashes with your faith, the discord of their struggle tearing your mind apart and frying your brain. Trying to persist is no use. Seems like this conversion was your greatest and final one.</b>"))
			if(!ishuman(M))
				M.gib()
				continue
			var/mob/living/carbon/human/H = M
			H.apply_damage(666, BURN, BP_HEAD, 0, 0, used_weapon = "fourth degree burns with no apparent cause")
			H.death()
		return TRUE

	var/datum/antagonist/antag
	for(var/antag_type in GLOB.all_antag_types_)
		antag = GLOB.all_antag_types_[antag_type]
		if(antag.is_antagonist(target.mind))
			to_chat(target, SPAN_DANGER("<b>As your newfound belief takes over your mind, you distantly notice your previous values fade away entirely...</b>"))
			antag.remove_antagonist(target.mind, TRUE, FALSE)

	return TRUE

/obj/effect/rune/convert/cast(mob/living/user)
	if(spamcheck)
		return

	var/mob/living/carbon/target = null
	for(var/mob/living/carbon/M in get_turf(src))
		if(!iscultist(M) && !M.is_ic_dead())
			target = M
			break

	if(!target)
		return fizzle(user)

	speak_incantation(user, "Mah[pick("'","`")]weyh pleggh at e'ntrath!")
	target.visible_message(SPAN_WARNING("The markings below [target] glow a bloody red."))

	var/list/mob/living/cultists = get_cultists()
	if((GLOB.changelings && (target.mind in GLOB.changelings.current_antagonists)) || isalien(target) || istype(target, /mob/living/carbon/human/diona) || istype(target, /mob/living/carbon/human/xenos) || HAS_TRAIT(target, TRAIT_HOLY))
		to_chat(target, SPAN("changeling", "You feel a slight buzz in your head as a foreign mental force makes futile attempts at invading your mind."))
		for(var/mob/living/M in cultists)
			to_chat(M, SPAN_DANGER("You feel a strong mental force blocking your belief from entering their mind.<br>Seems like you won't be able to convert \the [target]..."))
		return

	to_chat(target, SPAN_OCCULT("Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root."))
	if(cultists.len < 2)
		if(!GLOB.cult.can_become_antag(target.mind, 1))
			to_chat(target, SPAN_DANGER("Are you going insane?"))
		else
			to_chat(target, SPAN_OCCULT("Do you want to join the cult of Nar'Sie? You can choose to ignore the offer... <a href='?src=\ref[src];join=1'>Join the cult</a>."))

	if(GLOB.wizards && (target.mind in GLOB.wizards.current_antagonists))
		to_chat(target, SPAN_DANGER("<b>Yet you still sense your true powers angrily lurking inside you. Seems like your initiation will cost these adherents a great deal...</b>"))
		for(var/mob/living/M in cultists)
			to_chat(M, SPAN_DANGER("<b>You feel a strong mental force coming from \the [target]'s mind.<br>Seems like their conversion can only be done at the cost of your lives. If you're unwilling to make that sacrifice, you better stop now.</b>"))

	spamcheck = TRUE
	spawn(30)
		spamcheck = FALSE
		if(!iscultist(target) && target.loc == get_turf(src) && GLOB.cult.can_become_antag(target.mind, TRUE) && cultists.len >= 2)
			if(antag_check(target, cultists))
				GLOB.cult.add_antagonist(target.mind, ignore_role = TRUE, do_not_equip = TRUE)
		else // They hesitated, resisted, or can't join, and they are still on the rune - damage them
			if(target.stat == CONSCIOUS)
				target.take_overall_damage(10, 0)
				switch(target.getFireLoss())
					if(0 to 25)
						to_chat(target, SPAN_DANGER("Your blood boils as you force yourself to resist the corruption invading every corner of your mind."))
					if(25 to 45)
						to_chat(target, SPAN_DANGER("Your blood boils and your body burns as the corruption further forces itself into your body and mind."))
						target.take_overall_damage(3, 5)
					if(45 to 75)
						to_chat(target, SPAN_DANGER("You begin to hallucinate images of a dark and incomprehensible being and your entire body feels like its engulfed in flame as your mental defenses crumble."))
						target.take_overall_damage(5, 10)
					if(75 to 100)
						to_chat(target, SPAN_OCCULT("Your mind turns to ash as the burning flames engulf your very soul and images of an unspeakable horror begin to bombard the last remnants of mental resistance."))
						target.take_overall_damage(10, 20)

/obj/effect/rune/convert/Topic(href, href_list)
	var/list/mob/living/cultists = get_cultists()
	if(href_list["join"] && cultists.len)
		if(usr.loc == loc && !iscultist(usr) && antag_check(usr, cultists))
			GLOB.cult.add_antagonist(usr.mind, ignore_role = TRUE, do_not_equip = TRUE)

/obj/effect/rune/teleport
	cultname = "teleport"
	var/destination

/obj/effect/rune/teleport/New()
	..()
	var/area/A = get_area(src)
	destination = A.name
	GLOB.cult.teleport_runes += src

/obj/effect/rune/teleport/Destroy()
	GLOB.cult.teleport_runes -= src
	var/turf/T = get_turf(src)
	for(var/atom/movable/A in contents)
		A.forceMove(T)
	return ..()

/obj/effect/rune/teleport/examine(mob/user, infix)
	. = ..()

	if(iscultist(user))
		. += "It's name is [destination]."

/obj/effect/rune/teleport/cast(mob/living/user)
	if(user.loc == src)
		showOptions(user)
	else if(user.loc == get_turf(src))
		speak_incantation(user, "Sas[pick("'","`")]so c'arta forbici!")
		if(do_after(user, 30))
			user.visible_message(SPAN_WARNING("\The [user] disappears in a flash of red light!"),
			                     SPAN_WARNING("You feel your body get dragged into the dimension of Nar-Sie!"),
			                     "You hear a sickening crunch.")
			user.forceMove(src)
			showOptions(user)
			var/warning = 0
			while(user.loc == src)
				user.take_organ_damage(0, 2)
				if(user.getFireLoss() > 50)
					to_chat(user, SPAN_DANGER("Your body can't handle the heat anymore!"))
					leaveRune(user)
					return
				if(warning == 0)
					to_chat(user, SPAN_WARNING("You feel the immense heat of the realm of Nar-Sie..."))
					++warning
				if(warning == 1 && user.getFireLoss() > 15)
					to_chat(user, SPAN_WARNING("Your burns are getting worse. You should return to your realm soon..."))
					++warning
				if(warning == 2 && user.getFireLoss() > 35)
					to_chat(user, SPAN_WARNING("The heat! It burns!"))
					++warning
				sleep(10)
	else
		var/input = input(user, "Choose a new rune name.", "Destination", "") as text|null
		if(!input)
			return
		destination = sanitize(input)

/obj/effect/rune/teleport/Topic(href, href_list)
	if(usr.loc != src)
		return
	if(href_list["target"])
		var/obj/effect/rune/teleport/targ = locate(href_list["target"])
		if(istype(targ)) // Checks for null, too
			usr.forceMove(targ)
			targ.showOptions(usr)
	else if(href_list["leave"])
		leaveRune(usr)

/obj/effect/rune/teleport/proc/showOptions(mob/living/user)
	var/list/t = list()
	for(var/obj/effect/rune/teleport/T in GLOB.cult.teleport_runes)
		if(T == src)
			continue
		t += "<a href='?src=\ref[src];target=\ref[T]'>[T.destination]</a>"
	to_chat(user, "Teleport runes: [english_list(t, nothing_text = "no other runes exist")]... or <a href='?src=\ref[src];leave=1'>return from this rune</a>.")

/obj/effect/rune/teleport/proc/leaveRune(mob/living/user)
	if(user.loc != src)
		return
	user.forceMove(get_turf(src))
	user.visible_message(SPAN_WARNING("\The [user] appears in a flash of red light!"),
	                     SPAN_WARNING("You feel your body get thrown out of the dimension of Nar-Sie!"),
	                     "You hear a pop.")

/obj/effect/rune/tome
	cultname = "summon tome"

/obj/effect/rune/tome/cast(mob/living/user)
	new /obj/item/book/tome(get_turf(src))
	speak_incantation(user, "N[pick("'","`")]ath reth sh'yro eth d'raggathnor!")
	visible_message(SPAN_NOTICE("\The [src] disappears with a flash of red light, and in its place now a book lies."), "You hear a pop.")
	qdel(src)

/obj/effect/rune/wall
	cultname = "wall"

	var/obj/effect/cultwall/wall = null

/obj/effect/rune/wall/Destroy()
	QDEL_NULL(wall)
	return ..()

/obj/effect/rune/wall/cast(mob/living/user)
	var/t
	if(wall)
		if(wall.health >= wall.max_health)
			to_chat(user, SPAN_NOTICE("The wall doesn't need mending."))
			return
		t = wall.max_health - wall.health
		wall.health += t
	else
		wall = new /obj/effect/cultwall(get_turf(src), bcolor)
		wall.rune = src
		t = wall.health
	user.pay_for_rune(t / 50)
	speak_incantation(user, "Khari[pick("'","`")]d! Eske'te tannin!")
	to_chat(user, SPAN_WARNING("Your blood flows into the rune, and you feel that the very space over the rune thickens."))

/obj/effect/cultwall
	name = "red mist"
	desc = "A strange red mist emanating from a rune below it."
	icon = 'icons/effects/effects.dmi'//TODO: better icon
	icon_state = "smoke"
	color = "#ff0000"
	anchored = TRUE
	density = TRUE
	unacidable = TRUE
	var/obj/effect/rune/wall/rune
	var/health
	var/max_health = 200

/obj/effect/cultwall/New(loc, bcolor)
	..()
	health = max_health
	if(bcolor)
		color = bcolor

/obj/effect/cultwall/Destroy()
	if(rune)
		rune.wall = null
		rune = null
	return ..()

/obj/effect/cultwall/examine(mob/user, infix)
	. = ..()

	if(iscultist(user))
		if(health == max_health)
			. += "It is fully intact."
		else if(health > max_health * 0.5)
			. += "It is damaged."
		else
			. += "It is about to dissipate."

/obj/effect/cultwall/attack_hand(mob/living/user)
	if(iscultist(user))
		user.visible_message(SPAN_NOTICE("\The [user] touches \the [src], and it fades."),
		                     SPAN_NOTICE("You touch \the [src], whispering the old ritual, making it disappear."))
		qdel(src)
	else
		to_chat(user, SPAN_NOTICE("You touch \the [src]. It feels wet and becomes harder the further you push your arm."))

/obj/effect/cultwall/attackby(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/nullrod))
		user.visible_message(SPAN_NOTICE("\The [user] touches \the [src] with \the [I], and it disappears."),
		                     SPAN_NOTICE("You disrupt the vile magic with the deadening field of \the [I]."))
		qdel(src)
	else if(I.force)
		user.visible_message(SPAN_NOTICE("\The [user] hits \the [src] with \the [I]."),
		                     SPAN_NOTICE("You hit \the [src] with \the [I]."))
		take_damage(I.force)
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		user.do_attack_animation(src)

/obj/effect/cultwall/bullet_act(obj/item/projectile/Proj)
	if(!(Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		return
	take_damage(Proj.damage)
	..()

/obj/effect/cultwall/proc/take_damage(amount)
	health -= amount
	if(health <= 0)
		visible_message(SPAN_WARNING("\The [src] dissipates."))
		qdel(src)

/obj/effect/rune/ajorney
	cultname = "astral journey"

/obj/effect/rune/ajorney/cast(mob/living/user)
	var/tmpkey = user.key
	if(user.loc != get_turf(src))
		return
	speak_incantation(user, "Fwe[pick("'","`")]sh mah erl nyag r'ya!")
	user.visible_message(SPAN_WARNING("\The [user]'s eyes glow blue as \he freezes in place, absolutely motionless."),
	                     SPAN_WARNING("The shadow that is your spirit separates itself from your body. You are now in the realm beyond. While this is a great sight, being here strains your mind and body. Hurry..."),
	                                  "You hear only complete silence for a moment.")
	announce_ghost_joinleave(user.ghostize(TRUE, FALSE), TRUE, "You feel that they had to use some [pick("dark", "black", "blood", "forgotten", "forbidden")] magic to [pick("invade", "disturb", "disrupt", "infest", "taint", "spoil", "blight")] this place!")
	var/mob/observer/ghost/soul
	for(var/mob/observer/ghost/O in GLOB.ghost_mob_list)
		if(O.key == tmpkey)
			soul = O
			break
	while(user)
		if(user.is_ooc_dead())
			return
		if(user.key)
			return
		else if(user.loc != get_turf(src) && soul)
			soul.reenter_corpse()
		else
			user.take_organ_damage(0, 1)
		sleep(20)
	fizzle(user)

/obj/effect/rune/defile
	cultname = "defile"

/obj/effect/rune/defile/cast(mob/living/user)
	if(!is_station_turf(get_turf(src)))
		to_chat(user, SPAN_DANGER("This place is too powerless for any defiling!"))
		return
	speak_incantation(user, "Ia! Ia! Zasan therium viortia!")
	for(var/turf/T in range(1, src))
		if(T.holy)
			T.holy = FALSE
		else
			T.cultify()

	var/area/A = get_area(src)
	if(A && !isspace(A))
		A.holy = FALSE

	visible_message(SPAN_WARNING("\The [src] embeds into the floor and walls around it, changing them!"), "You hear liquid flow.")
	qdel(src)

/* Tier 2 runes */


/obj/effect/rune/armor
	cultname = "summon robes"
	strokes = 3

/obj/effect/rune/armor/cast(mob/living/user)
	speak_incantation(user, "N'ath reth sh'yro eth d[pick("'","`")]raggathnor!")
	visible_message(SPAN_WARNING("\The [src] disappears with a flash of red light, and a set of armor appears on \the [user]."), SPAN_WARNING("You are blinded by the flash of red light. After you're able to see again, you see that you are now wearing a set of armor."))

	var/obj/O = user.get_equipped_item(slot_head) // This will most likely kill you if you are wearing a spacesuit, and it's 100% intended
	if(O && !istype(O, /obj/item/clothing/head/culthood))
		user.drop(O)
	O = user.get_equipped_item(slot_wear_suit)
	if(O && !istype(O, /obj/item/clothing/suit/cultrobes))
		user.drop(O)
	O = user.get_equipped_item(slot_shoes)
	if(O && !istype(O, /obj/item/clothing/shoes/cult))
		user.drop(O)

	user.equip_to_slot_or_del(new /obj/item/clothing/head/culthood/alt(user), slot_head)
	user.equip_to_slot_or_del(new /obj/item/clothing/suit/cultrobes/alt(user), slot_wear_suit)
	user.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult(user), slot_shoes)

	O = user.get_equipped_item(slot_back)
	if(istype(O, /obj/item/storage) && !istype(O, /obj/item/storage/backpack/cultpack)) // We don't want to make the vox drop their nitrogen tank, though
		user.drop(O)
		var/obj/item/storage/backpack/cultpack/C = new /obj/item/storage/backpack/cultpack(user)
		user.equip_to_slot_or_del(C, slot_back)
		if(C)
			for(var/obj/item/I in O)
				I.forceMove(C)
	else if(!O)
		var/obj/item/storage/backpack/cultpack/C = new /obj/item/storage/backpack/cultpack(user)
		user.equip_to_slot_or_del(C, slot_back)

	user.update_icons()

	qdel(src)

/obj/effect/rune/offering
	cultname = "offering"
	strokes = 3
	var/mob/living/victim

/obj/effect/rune/offering/cast(mob/living/user)
	var/list/mob/living/cultists = get_cultists()
	if(victim)
		to_chat(user, SPAN_WARNING("You are already sacrificing \the [victim] on this rune."))
		return
	if(cultists.len < 3)
		to_chat(user, SPAN_WARNING("You need three cultists around this rune to make it work."))
		return fizzle(user)
	var/turf/T = get_turf(src)
	for(var/mob/living/M in T)
		if(!M.is_ic_dead() && !iscultist(M))
			victim = M
			break
	if(!victim)
		return fizzle(user)

	for(var/mob/living/M in cultists)
		M.say("Barhah hra zar[pick("'","`")]garis!")

	while(victim && victim.loc == T && !victim.is_ic_dead())
		var/list/mob/living/casters = get_cultists()
		if(casters.len < 3)
			break
		//T.turf_animation('icons/effects/effects.dmi', "rune_sac")
		victim.fire_stacks = max(2, victim.fire_stacks)
		victim.IgniteMob()
		victim.take_organ_damage(2 + casters.len, 2 + casters.len) // This is to speed up the process and also damage mobs that don't take damage from being on fire, e.g. borgs
		if(ishuman(victim))
			var/mob/living/carbon/human/H = victim
			if(H.is_asystole())
				H.adjustBrainLoss(2 + casters.len)
		sleep(40)
	if(victim && victim.loc == T && victim.is_ic_dead())
		GLOB.cult.add_cultiness(CULTINESS_PER_SACRIFICE)
		var/obj/item/device/soulstone/full/F = new(get_turf(src))
		for(var/mob/M in cultists | get_cultists())
			to_chat(M, SPAN_WARNING("The Geometer of Blood accepts this offering."))
		visible_message(SPAN_NOTICE("\The [F] appears over \the [src]."))
		GLOB.cult.sacrificed += victim.mind
		if(victim.mind == GLOB.cult.sacrifice_target)
			for(var/datum/mind/H in GLOB.cult.current_antagonists)
				if(H.current)
					to_chat(H.current, SPAN_OCCULT("Your objective is now complete."))
		//TODO: other rewards?
		/* old sac code - left there in case someone wants to salvage it
		var/worth = 0
		if(istype(H,/mob/living/carbon/human))
			var/mob/living/carbon/human/lamb = H
			if(lamb.species.rarity_value > 3)
				worth = 1

		if(H.mind == cult.sacrifice_target)

		to_chat(usr, "<span class='warning'>The Geometer of Blood accepts this sacrifice, your objective is now complete.</span>")

		to_chat(usr, "<span class='warning'>The Geometer of Blood accepts this [worth ? "exotic " : ""]sacrifice.</span>")

		to_chat(usr, "<span class='warning'>The Geometer of blood accepts this sacrifice.</span>")
		to_chat(usr, "<span class='warning'>However, this soul was not enough to gain His favor.</span>")

		to_chat(usr, "<span class='warning'>The Geometer of blood accepts this sacrifice.</span>")
		to_chat(usr, "<span class='warning'>However, a mere dead body is not enough to satisfy Him.</span>")
		*/
		to_chat(victim, SPAN_OCCULT("The Geometer of Blood claims your body."))
		victim.dust()
	if(victim)
		victim.ExtinguishMob() // Technically allows them to put the fire out by sacrificing them and stopping immediately, but I don't think it'd have much effect
		victim = null


/obj/effect/rune/drain
	cultname = "blood drain"
	strokes = 3

/obj/effect/rune/drain/cast(mob/living/user)
	var/mob/living/carbon/human/victim
	for(var/mob/living/carbon/human/M in get_turf(src))
		if(iscultist(M))
			continue
		victim = M
	if(!victim)
		return fizzle(user)
	if(!victim.vessel.has_reagent(/datum/reagent/blood, 20))
		to_chat(user, SPAN_WARNING("This body has no blood in it."))
		return fizzle(user)
	victim.vessel.remove_reagent(/datum/reagent/blood, 20)
	admin_attack_log(user, victim, "Used a blood drain rune.", "Was victim of a blood drain rune.", "used a blood drain rune on")
	speak_incantation(user, "Yu[pick("'","`")]gular faras desdae. Havas mithum javara. Umathar uf'kal thenar!")
	user.visible_message(SPAN_WARNING("Blood flows from \the [src] into \the [user]!"),
	                     SPAN_OCCULT("The blood starts flowing from \the [src] into your frail mortal body. [capitalize(english_list(heal_user(user), nothing_text = "you feel no different"))]."),
	                     "You hear liquid flow.")
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)

/obj/effect/rune/drain/proc/heal_user(mob/living/carbon/human/user)
	if(!istype(user))
		return list("you feel no different")
	var/list/statuses = list()
	var/charges = 20
	var/use
	use = min(charges, user.species.blood_volume - user.vessel.total_volume)
	if(use > 0)
		user.vessel.add_reagent(/datum/reagent/blood, use)
		charges -= use
		statuses += "you regain lost blood"
		if(!charges)
			return statuses
	if(user.getBruteLoss() || user.getFireLoss())
		var/healbrute = user.getBruteLoss()
		var/healburn = user.getFireLoss()
		if(healbrute < healburn)
			healbrute = min(healbrute, charges / 2)
			charges -= healbrute
			healburn = min(healburn, charges)
			charges -= healburn
		else
			healburn = min(healburn, charges / 2)
			charges -= healburn
			healbrute = min(healbrute, charges)
			charges -= healbrute
		user.heal_organ_damage(healbrute, healburn)
		statuses += "your wounds mend"
		if(!charges)
			return statuses
	if(user.getToxLoss())
		use = min(user.getToxLoss(), charges)
		user.adjustToxLoss(-use)
		charges -= use
		statuses += "your body stings less"
		if(!charges)
			return statuses
	if(charges >= 15)
		for(var/obj/item/organ/external/E in user.organs)
			if(E && (E.status & ORGAN_BROKEN))
				E.mend_fracture()
				statuses += "bones in your [E.name] snap into place"
				charges -= 15
				if(charges < 15)
					break
	if(!charges)
		return statuses
	var/list/obj/item/organ/damaged = list()
	for(var/obj/item/organ/I in user.internal_organs)
		if(I.damage)
			damaged += I
	if(damaged.len)
		statuses += "you feel pain inside for a moment that passes quickly"
		while(charges && damaged.len)
			var/obj/item/organ/fix = pick(damaged)
			fix.damage = max(0, fix.damage - min(charges, 1))
			charges = max(charges - 1, 0)
			if(fix.damage == 0)
				damaged -= fix
	/* this is going to need rebalancing
	if(charges)
		user.ingested.add_reagent(/datum/reagent/hell_water, charges)
		statuses += "you feel empowered"
	*/
	return statuses

/datum/reagent/hell_water
	name = "Hell water"
	reagent_state = LIQUID
	color = "#0050a177"
	metabolism = REM * 0.1

/datum/reagent/hell_water/affect_ingest(mob/living/carbon/M, alien, removed)
	if(iscultist(M))
		M.AdjustParalysis(-1)
		M.AdjustStunned(-1)
		M.AdjustWeakened(-1)
		M.add_chemical_effect(CE_PAINKILLER, 40)
		M.add_up_to_chemical_effect(CE_SPEEDBOOST, 1)
		M.adjustOxyLoss(-10 * removed)
		M.heal_organ_damage(5 * removed, 5 * removed)
		M.adjustToxLoss(-5 * removed)
	else
		M.fire_stacks = max(2, M.fire_stacks)
		M.IgniteMob()

/obj/effect/rune/emp
	cultname = "emp"
	strokes = 4

/obj/effect/rune/emp/cast(mob/living/user)
	var/list/mob/living/cultists = get_cultists()
	if(cultists.len < 2)
		to_chat(user, SPAN_WARNING("You need two cultists around this rune to make it work."))
		return fizzle(user)
	empulse(get_turf(src), 4, 2, 1)
	speak_incantation(user, "Ta'gh fara[pick("'","`")]qha fel d'amar det!")
	qdel(src)

/obj/effect/rune/massdefile //Defile but with a huge range. Bring a buddy for this, you're hitting the floor.
	cultname = "mass defile"

/obj/effect/rune/massdefile/cast(mob/living/user)
	var/list/mob/living/cultists = get_cultists()
	if(!is_station_turf(get_turf(src)))
		to_chat(user, SPAN_DANGER("This place is too powerless for any defiling!"))
		return
	if(cultists.len < 3)
		to_chat(user, SPAN_WARNING("You need three cultists around this rune to make it work."))
		return fizzle(user)
	else
		for(var/mob/living/M in cultists)
			M.say("Ia! Ia! Zasan therium viortia! Razan gilamrua kioha!")
		for(var/turf/T in range(5, src))
			if(T.holy)
				T.holy = FALSE
			else
				T.cultify()

	var/area/A = get_area(src)
	if(A && !isspace(A))
		A.holy = FALSE

	visible_message(SPAN_WARNING("\The [src] embeds into the floor and walls around it, changing them!"), "You hear liquid flow.")
	qdel(src)

/* Tier 3 runes */

/obj/effect/rune/weapon
	cultname = "summon weapon"
	strokes = 4

/obj/effect/rune/weapon/cast(mob/living/user)
	if(!istype(user.get_equipped_item(slot_head), /obj/item/clothing/head/culthood) || !istype(user.get_equipped_item(slot_wear_suit), /obj/item/clothing/suit/cultrobes) || !istype(user.get_equipped_item(slot_shoes), /obj/item/clothing/shoes/cult))
		to_chat(user, SPAN_WARNING("You need to be wearing your robes to use this rune."))
		return fizzle(user)
	var/turf/T = get_turf(src)
	if(T.icon_state != "cult" && T.icon_state != "cult-narsie")
		to_chat(user, SPAN_WARNING("This rune needs to be placed on defiled ground."))
		return fizzle(user)
	speak_incantation(user, "N'ath reth sh'yro eth d[pick("'","`")]raggathnor!")
	user.pick_or_drop(new /obj/item/melee/cultblade(user), loc)
	qdel(src)

/obj/effect/rune/shell
	cultname = "summon shell"
	strokes = 4

/obj/effect/rune/shell/cast(mob/living/user)
	var/turf/T = get_turf(src)
	if(T.icon_state != "cult" && T.icon_state != "cult-narsie")
		to_chat(user, SPAN_WARNING("This rune needs to be placed on defiled ground."))
		return fizzle(user)

	var/obj/item/stack/material/steel/target
	for(var/obj/item/stack/material/steel/S in get_turf(src))
		if(S.get_amount() >= 10)
			target = S
			break

	if(!target)
		to_chat(user, "<span class='warning'>You need ten sheets of metal to fold them into a construct shell.</span>")
		return fizzle(user)

	speak_incantation(user, "Da A[pick("'","`")]ig Osk!")
	target.use(10)
	var/obj/O = new /obj/structure/constructshell/cult(get_turf(src))
	visible_message(SPAN_WARNING("The metal bends into \the [O], and \the [src] imbues into it."), "You hear a metallic sound.")
	qdel(src)

/obj/effect/rune/confuse
	cultname = "confuse"
	strokes = 4

/obj/effect/rune/confuse/cast(mob/living/user)
	var/list/mob/living/cultists = get_cultists()
	if(cultists.len < 3)
		to_chat(user, SPAN_WARNING("You need three cultists around this rune to make it work."))
		return fizzle(user)
	speak_incantation(user, "Fuu ma[pick("'","`")]jin!")
	visible_message(SPAN_DANGER("\The [src] explodes in a bright flash."))
	var/list/mob/affected = list()
	for(var/mob/living/M in viewers(src))
		if(iscultist(M))
			continue
		var/obj/item/nullrod/N = locate() in M
		if(N)
			continue
		affected |= M
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			C.eye_blurry += 50
			C.Weaken(3)
			C.Stun(5)
		else if(issilicon(M))
			M.Weaken(10)

	admin_attacker_log_many_victims(user, affected, "Used a confuse rune.", "Was victim of a confuse rune.", "used a confuse rune on")
	qdel(src)

/obj/effect/rune/revive
	cultname = "revive"
	strokes = 4

/obj/effect/rune/revive/cast(mob/living/user)
	var/mob/living/carbon/human/target
	var/obj/item/device/soulstone/source
	for(var/mob/living/carbon/human/M in get_turf(src))
		if(M.is_ic_dead())
			if(iscultist(M))
				if(M.key)
					target = M
					break
	if(!target)
		return fizzle(user)
	for(var/obj/item/device/soulstone/S in get_turf(src))
		if(S.full && !S.shade.key)
			source = S
			break
	if(!source)
		return fizzle(user)
	target.rejuvenate()
	source.set_full(0)
	speak_incantation(user, "Pasnar val'keriam usinar. Savrae ines amutan. Yam'toth remium il'tarat!")
	target.visible_message(SPAN_WARNING("\The [target]'s eyes glow with a faint red as \he stands up, slowly starting to breathe again."),
	                       SPAN_WARNING("Life... I'm alive again..."),
	                       "You hear liquid flow.")

/obj/effect/rune/blood_boil
	cultname = "blood boil"
	strokes = 4
	var/is_used = FALSE
	var/uses = 5

/obj/effect/rune/blood_boil/cast(mob/living/user)
	var/list/mob/living/cultists = get_cultists()
	if(cultists.len < 3)
		return fizzle()
	if(is_used)
		return fizzle()

	for(var/mob/living/M in cultists)
		M.say("Dedo ol[pick("'","`")]btoh!")
	is_used = TRUE
	var/list/mob/living/previous = list()
	var/list/mob/living/current = list()
	while(cultists.len >= 3)
		cultists = get_cultists()
		for(var/mob/living/carbon/M in viewers(src))
			if(iscultist(M))
				continue
			current |= M
			var/obj/item/nullrod/N = locate() in M
			if(N)
				continue
			M.take_overall_damage(5, 5)
			if(!(M in previous))
				if(M.should_have_organ(BP_HEART))
					to_chat(M, SPAN_DANGER("Your blood boils!"))
				else
					to_chat(M, SPAN_DANGER("You feel searing heat inside!"))
		previous = current.Copy()
		current.Cut()
		uses -= 1
		if(uses <= 0)
			visible_message(SPAN_WARNING("\The [src] suddenly dissipates."))
			to_chat(user, SPAN_DANGER("Seems like all of \the [src]'s power has been used up."))
			qdel(src)
			return
		sleep(40)
	is_used = FALSE

/* Tier NarNar runes */

/obj/effect/rune/tearreality
	cultname = "tear reality"
	var/the_end_comes = 0
	var/the_time_has_come = 300
	var/obj/singularity/narsie/HECOMES = null
	strokes = 9

/obj/effect/rune/tearreality/cast(mob/living/user)
	if(!GLOB.cult.allow_narsie)
		return
	if(!is_station_turf(get_turf(src)))
		to_chat(user, SPAN_OCCULT("Our Deity does not have enough influence on this place to be summoned here!"))
		return
	if(the_end_comes)
		to_chat(user, SPAN_OCCULT("You are already summoning! Be patient!"))
		return
	var/list/mob/living/cultists = get_cultists()
	if(cultists.len < 5)
		return fizzle()
	for(var/mob/living/M in cultists)
		M.say("Tok-lyr rqa'nap g[pick("'","`")]lt-ulotf!")
		to_chat(M, SPAN_OCCULT("You are starting to tear the reality to bring Him back... stay around the rune!"))
	log_and_message_admins_many(cultists, "started summoning Nar-sie.")

	var/area/A = get_area(src)
	SSannounce.play_station_announce(/datum/announce/wormholes, "High levels of bluespace interference detected at \the [A]. Suspected wormhole forming. Investigate it immediately.")
	while(cultists.len > 4 || the_end_comes)
		cultists = get_cultists()
		if(cultists.len > 8)
			++the_end_comes
		if(cultists.len > 4)
			++the_end_comes
		else
			--the_end_comes
		if(the_end_comes >= the_time_has_come)
			break
		for(var/mob/living/M in cultists)
			if(prob(5))
				M.say(pick("Hakkrutju gopoenjim.", "Nherasai pivroiashan.", "Firjji prhiv mazenhor.", "Tanah eh wakantahe.", "Obliyae na oraie.", "Miyf hon vnor'c.", "Wakabai hij fen juswix."))

		for(var/turf/T in range(min(the_end_comes, 15)))
			if(prob(the_end_comes / 3))
				T.cultify()
		sleep(10)

	if(the_end_comes >= the_time_has_come)
		HECOMES = new /obj/singularity/narsie(get_turf(src))
	else
		SSannounce.play_station_announce(/datum/announce/wormholes_end)
		qdel(src)

/obj/effect/rune/tearreality/attack_hand(mob/living/user)
	..()
	if(HECOMES && !iscultist(user))
		var/input = input(user, "Are you SURE you want to sacrifice yourself?", "DO NOT DO THIS") in list("Yes", "No")
		if(input != "Yes")
			return
		speak_incantation(user, "Uhrast ka'hfa heldsagen ver[pick("'","`")]lot!")
		to_chat(user, SPAN_WARNING("In the last moment of your humble life, you feel an immense pain as fabric of reality mends... with your blood."))
		for(var/mob/M in GLOB.living_mob_list_)
			if(iscultist(M))
				to_chat(M, "You see a vision of \the [user] keeling over dead, their blood glowing blue as it escapes their body and dissipates into thin air; you hear an otherwordly scream and feel that a great disaster has just been averted.")
			else
				to_chat(M, "You see a vision of [name] keeling over dead, their blood glowing blue as it escapes their body and dissipates into thin air; you hear an otherwordly scream and feel very weak for a moment.")
		log_and_message_admins("mended reality with the greatest sacrifice", user)
		user.dust()
		GLOB.cult.powerless = TRUE
		qdel(HECOMES)
		qdel(src)
		return

/obj/effect/rune/tearreality/attackby()
	if(the_end_comes)
		return
	..()

/* Imbue runes */

/obj/effect/rune/imbue
	cultname = "otherwordly abomination that shouldn't exist and that you should report to your local god as soon as you see it, along with the instructions for making this"
	var/papertype

/obj/effect/rune/imbue/cast(mob/living/user)
	var/obj/item/paper/target
	var/tainted = FALSE
	for(var/obj/item/paper/P in get_turf(src))
		if(P.is_clean())
			target = P
			break
		else
			tainted = TRUE
	if(!target)
		if(tainted)
			to_chat(user, SPAN_WARNING("The blank is tainted. It is unsuitable."))
		return fizzle(user)
	speak_incantation(user, "H'drak v[pick("'","`")]loso, mir'kanas verbot!")
	visible_message(SPAN_WARNING("The rune forms into an arcane image on the paper."))
	new papertype(get_turf(src))
	qdel(target)
	qdel(src)

/obj/effect/rune/imbue/emp
	cultname = "destroy technology imbue"
	papertype = /obj/item/paper/talisman/emp

/obj/effect/rune/imbue/stun
	cultname = "consciousness freeze imbue"
	papertype = /obj/item/paper/talisman/stun
