//re-sorted 13/09/2020 02:47

/*
CIGARETTE PACKETS ARE IN FANCY.DM
CIGARETTES AND STUFF ARE IN 'SMOKABLES' FOLDER
*/

//For anything that can light stuff on fire
/obj/item/flame
	var/lit = 0

/obj/item/flame/get_temperature_as_from_ignitor()
	if(lit)
		return 1000
	return 0

///////////
//MATCHES//
///////////
/obj/item/flame/match
	name = "match"
	desc = "A simple match stick, used for lighting fine smokables."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "match_unlit"
	var/burnt = 0
	var/smoketime = 5
	w_class = ITEM_SIZE_TINY
	origin_tech = list(TECH_MATERIAL = 1)
	slot_flags = SLOT_EARS
	attack_verb = list("burnt", "singed")

/obj/item/flame/match/Process()
	if(isliving(loc))
		var/mob/living/M = loc
		M.IgniteMob()
	var/turf/location = get_turf(src)
	smoketime--
	if(smoketime < 1)
		burn_out()
		return
	if(location)
		location.hotspot_expose(700, 5)
		return

/obj/item/flame/match/dropped(mob/user as mob)
	//If dropped, put ourselves out
	//not before lighting up the turf we land on, though.
	if(lit)
		spawn(0)
			var/turf/location = src.loc
			if(istype(location))
				location.hotspot_expose(700, 5)
			burn_out()
	return ..()

/obj/item/flame/match/proc/burn_out()
	lit = 0
	burnt = 1
	damtype = "brute"
	icon_state = "match_burnt"
	item_state = "cigoff"
	name = "burnt match"
	desc = "A match. This one has seen better days."
	set_light(0)
	STOP_PROCESSING(SSobj, src)

/////////
//ZIPPO//
/////////
/obj/item/flame/lighter
	name = "cheap lighter"
	desc = "A cheap-as-free lighter."
	icon = 'icons/obj/zippos.dmi'
	icon_state = "lighter-white"
	item_state = "lighter"
	w_class = ITEM_SIZE_TINY
	throwforce = 4
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	attack_verb = list("burnt", "singed")
	var/max_fuel = 5
	var/flame_overlay = "cheapoverlay"
	var/spam_flag = 0
	var/requires_hold = TRUE

/obj/item/flame/lighter/Initialize()
	. = ..()
	create_reagents(max_fuel)
	reagents.add_reagent(/datum/reagent/fuel, max_fuel)
	update_icon()

/obj/item/flame/lighter/proc/light(mob/user)
	lit = 1
	update_icon()
	light_effects(user)
	set_light(0.2, 0.5, 2, 3.5, "#e38f46")
	START_PROCESSING(SSobj, src)

/obj/item/flame/lighter/proc/light_effects(mob/living/carbon/user)
	if(prob(95))
		user.visible_message(SPAN("notice", "After a few attempts, [user] manages to light the [src]."))
	else
		to_chat(user, SPAN("warning", "You burn yourself while lighting the lighter."))
		if(user.l_hand == src)
			user.apply_damage(2, BURN,BP_L_HAND)
		else
			user.apply_damage(2, BURN,BP_R_HAND)
		user.visible_message(SPAN("notice", "After a few attempts, [user] manages to light the [src], they however burn their finger in the process."))
	playsound(src.loc, SFX_USE_LIGHTER, 100, 1, -4)

/obj/item/flame/lighter/proc/shutoff(mob/user, silent = FALSE)
	lit = 0
	update_icon()
	if(!silent)
		if(user)
			shutoff_effects(user)
		else
			visible_message(SPAN("notice", "[src] goes out."))
	set_light(0)
	STOP_PROCESSING(SSobj, src)

/obj/item/flame/lighter/proc/shutoff_effects(mob/user)
	user.visible_message(SPAN("notice", "[user] quietly shuts off the [src]."))

/obj/item/flame/lighter/get_temperature_as_from_ignitor()
	if(lit)
		return 1500
	return 0

/obj/item/flame/lighter/attack_self(mob/living/user)
	if(spam_flag)
		return
	spam_flag = 1
	if(!lit)
		if(reagents.has_reagent(/datum/reagent/fuel))
			light(user)
		else
			to_chat(user, SPAN("warning", "[src] won't ignite - out of fuel."))
	else
		shutoff(user)
	add_fingerprint(user)
	spawn(5)
		spam_flag = 0

/obj/item/flame/lighter/update_icon()
	overlays.Cut()
	if(lit)
		icon_state = "[initial(icon_state)]on"
		item_state = "[initial(item_state)]on"
		overlays += image(icon, src, flame_overlay)
	else
		icon_state = "[initial(icon_state)]"
		item_state = initial(item_state)

/obj/item/flame/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!istype(M, /mob))
		return

	if(lit)
		M.IgniteMob()

		if(istype(M.wear_mask, /obj/item/clothing/mask/smokable/cigarette) && user.zone_sel.selecting == BP_MOUTH)
			var/obj/item/clothing/mask/smokable/cigarette/cig = M.wear_mask
			if(M == user)
				cig.attackby(src, user)
			else
				if(istype(src, /obj/item/flame/lighter/zippo))
					visible_message(SPAN("rose", "[user] whips the [name] out and holds it for [M]."))
				else
					visible_message(SPAN("notice", "[user] holds the [name] out for [M], and lights the [cig.name]."))
				cig.light(src, user)
			return

	..()

/obj/item/flame/lighter/Process()
	if(reagents.has_reagent(/datum/reagent/fuel))
		if(ismob(loc) && prob(10) && reagents.get_reagent_amount(/datum/reagent/fuel) < 1)
			to_chat(loc, SPAN("warning", "[src]'s flame flickers."))
			set_light(0)
			spawn(4)
				set_light(0.3, 0.5, 2, 2, "#e38f46")
		reagents.remove_reagent(/datum/reagent/fuel, 0.05)
	else
		shutoff()
		return

	var/turf/location = get_turf(src)
	if(location)
		location.hotspot_expose(700, 5)

/obj/item/flame/lighter/dropped()
	if(requires_hold)
		shutoff(silent = TRUE)


/obj/item/flame/lighter/random/Initialize()
	if(prob(99.5))
		icon_state = "lighter-[pick("red", "orange", "yellow", "green", "cyan", "blue", "purple", "white", "black")]"
	else
		icon_state = "lighter-gold"
		name = "expensive lighter"
		desc = "It may be made of gold, but it doesn't make it any less crappy."
		matter = list(MATERIAL_GOLD = 250)
	//item_state = icon_state // TODO: Draw item states for all the above, huh
	. = ..()


/obj/item/flame/lighter/zippo
	name = "\improper Zippo lighter"
	desc = "The zippo."
	icon_state = "zippo"
	item_state = "zippo"
	max_fuel = 10
	flame_overlay = "zippooverlay"
	requires_hold = FALSE

/obj/item/flame/lighter/zippo/light_effects(mob/user)
	user.visible_message(SPAN("rose", "Without even breaking stride, [user] flips open and lights [src] in one smooth movement."))
	playsound(src.loc, 'sound/items/zippo_open.ogg', 100, 1, -4)

/obj/item/flame/lighter/zippo/shutoff_effects(mob/user)
	user.visible_message(SPAN("rose", "You hear a quiet click, as [user] shuts off [src] without even looking at what they're doing."))
	playsound(src.loc, 'sound/items/zippo_close.ogg', 100, 1, -4)

/obj/item/flame/lighter/zippo/afterattack(obj/O, mob/user, proximity)
	if(!proximity)
		return
	if(istype(O, /obj/structure/reagent_dispensers/fueltank) && !lit)
		O.reagents.trans_to_obj(src, max_fuel)
		to_chat(user, SPAN("notice", "You refuel [src] from \the [O]."))
		playsound(src.loc, 'sound/effects/refill.ogg', 50, 1, -6)

/obj/item/flame/lighter/zippo/cap
	name = "\improper Captain's lighter"
	desc = "You know you are in charge when your lighter is made of gold."
	icon_state = "zippo-cap"
	max_fuel = 15
	matter = list(MATERIAL_GOLD = 250)

/obj/item/flame/lighter/zippo/us
	name = "\improper Democratic lighter"
	desc = "Fueled with pure democracy! And a hint of democratic gasoline."
	icon_state = "zippo-us"

/obj/item/flame/lighter/zippo/third
	name = "\improper Unethical lighter"
	desc = "This one would go well along with HoS's attire."
	icon_state = "zippo-third"

/obj/item/flame/lighter/zippo/sov
	name = "\improper Commie lighter"
	desc = "You may think this one is yours, but in fact it's ours!"
	icon_state = "zippo-sov"

/obj/item/flame/lighter/zippo/nt
	name = "\improper NanoTrasen lighter"
	desc = "Must be fueled with plasma or something."
	icon_state = "zippo-nt"

/obj/item/flame/lighter/zippo/red
	name = "red Zippo lighter"
	desc = "It's a red Zippo. And don't you even say it's red and white."
	icon_state = "zippo-red"

/obj/item/flame/lighter/zippo/black
	name = "black Zippo lighter"
	desc = "A black Zippo lighter. These matter too, ya know."
	icon_state = "zippo-black"

/obj/item/flame/lighter/zippo/grav
	name = "engraved Zippo lighter"
	desc = "Perhaps, simplicity has its own pros."
	icon_state = "zippo-grav"

/obj/item/flame/lighter/zippo/rainbow
	name = "rainbow Zippo lighter"
	desc = "As if putting oblong objects in your mouth wasn't enough."
	icon_state = "zippo-rainbow"

/obj/item/flame/lighter/zippo/pt
	name = "\improper T&P lighter"
	desc = "They say its flame smells like maple syrup. More like burnt hair, if you ask me."
	icon_state = "zippo-pt"

/obj/item/flame/lighter/zippo/onyx
	name = "\improper Chaotic lighter"
	desc = "Its flame is bright red. Why, you ask? A miracle, that's why!"
	icon_state = "zippo-onyx"
	flame_overlay = "zippo-onyxoverlay"

/obj/item/flame/lighter/zippo/ablack
	name = "\improper Tyranny lighter"
	desc = "You asked for sweet tea. Life gave you robust coffee."
	icon_state = "zippo-ablack"

/obj/item/flame/lighter/zippo/agreen
	name = "\improper Apple lighter"
	desc = "Legend says, this apple cultivar used to grow on fern. Miraculously lawful, if that makes any sense."
	icon_state = "zippo-agreen"

/obj/item/flame/lighter/zippo/awhite
	name = "\improper Extinguisher lighter"
	desc = "Don't let your dreams stay dreams, even if you'll have to fight your way through with a fire extinguisher. Even if it's an extinguisher lighter."
	icon_state = "zippo-awhite"

/obj/item/flame/lighter/zippo/diona
	name = "\improper Diona lighter"
	desc = "It's definitely fueled with irony."
	icon_state = "zippo-diona"

/obj/item/flame/lighter/zippo/rasta
	name = "\improper Rasta lighter"
	desc = "One hell of a proper way to light your joints."
	icon_state = "zippo-rasta"

/obj/item/flame/lighter/zippo/chrome
	name = "chrome Zippo lighter"
	desc = "It's shiny, it's cool, it requires a shitload of care."
	icon_state = "zippo-chrome"

/obj/item/flame/lighter/zippo/nuke
	name = "\improper nuclear authentication lighter"
	desc = "You don't want to go and try to stick it into a nuclear bomb, do you?"
	icon_state = "zippo-nuke"

/obj/item/flame/lighter/zippo/eng
	name = "\improper Engineering lighter"
	desc = "Its owner must be trusted. Should be trusted. May be trusted. Probably. In fact, shouldn't be."
	icon_state = "zippo-eng"

/obj/item/flame/lighter/zippo/med
	name = "\improper Medical lighter"
	desc = "Doctors say, smoking kills. So you'd better do what doctors say, not what doctors do."
	icon_state = "zippo-med"

/obj/item/flame/lighter/zippo/sci
	name = "\improper Science lighter"
	desc = "THIS is how you set toxins on fire."
	icon_state = "zippo-sci"

/obj/item/flame/lighter/zippo/clown
	name = "\improper Clown lighter"
	desc = "Just look at it, this zippo looks like a tiny clown! Now go ahead and tear his head off!"
	icon_state = "zippo-clown"

/obj/item/flame/lighter/zippo/clown/light_effects(mob/user)
	user.visible_message(SPAN("rose", "With a gentle honk, [user] flips open and lights [src] in one smooth movement."))
	playsound(src.loc, 'sound/items/bikehorn.ogg', 50, 1, -4)

/obj/item/flame/lighter/zippo/clown/shutoff_effects(mob/user)
	user.visible_message(SPAN("rose", "You hear a quiet honk, as [user] shuts off [src] without even looking at what they're doing."))
	playsound(src.loc, 'sound/items/bikehorn.ogg', 50, 1, -4)

/obj/item/flame/lighter/zippo/pig
	name = "\improper Piggie lighter"
	desc = "Hands down the best thing you can ever spend your money on."
	icon_state = "zippo-pig"

/obj/item/flame/lighter/zippo/pig/light_effects(mob/user)
	user.visible_message(SPAN("rose", "With a provocative oink, [user] flips open and lights [src] in one smooth movement."))
	playsound(src.loc, pick('sound/effects/pig1.ogg', 'sound/effects/pig2.ogg', 'sound/effects/pig3.ogg'), 50, 1, -4)

/obj/item/flame/lighter/zippo/pig/shutoff_effects(mob/user)
	user.visible_message(SPAN("rose", "You hear a funny oink, as [user] shuts off [src] without even looking at what they're doing."))
	playsound(src.loc, pick('sound/effects/pig1.ogg', 'sound/effects/pig2.ogg', 'sound/effects/pig3.ogg'), 50, 1, -4)

/obj/item/flame/lighter/zippo/syndie
	name = "suspicious Zippo lighter"
	desc = "It must be searching for the Nuclear Auth Lighter."
	icon_state = "zippo-syndie"

/obj/item/flame/lighter/zippo/syndie/light_effects(mob/living/carbon/user)
	if(user.mind?.syndicate_awareness == SYNDICATE_SUSPICIOUSLY_AWARE)
		user.visible_message(SPAN("rose", "Without even breaking stride, [user] flips open and lights [src] in one smooth movement."))
	else
		to_chat(user, SPAN("warning", "You burn yourself badly while lighting [src]!"))
		if(user.l_hand == src)
			user.apply_damage(15, BURN, BP_L_HAND)
		else
			user.apply_damage(15, BURN, BP_R_HAND)
		user.visible_message(SPAN("notice", "After a few attempts, [user] manages to light the [src], they however badly burn their hand in the process."))
	playsound(src.loc, 'sound/items/zippo_open.ogg', 100, 1, -4)

/obj/item/flame/lighter/zippo/syndie/shutoff_effects(mob/living/carbon/user)
	if(user.mind && user.mind.syndicate_awareness == SYNDICATE_SUSPICIOUSLY_AWARE)
		user.visible_message(SPAN("rose", "You hear a quiet click, as [user] shuts off [src] without even looking at what they're doing."))
	else
		to_chat(user, SPAN("warning", "You badly pich your hand while shutting off [src]!"))
		if(user.l_hand == src)
			user.apply_damage(7.5, BRUTE, BP_L_HAND)
		else
			user.apply_damage(7.5, BURN, BP_R_HAND)
		user.visible_message(SPAN("notice", "You hear a nasty snap, as [user] shuts off [src], badly pinching their hand in the process."))
	playsound(src.loc, 'sound/items/zippo_close.ogg', 100, 1, -4)
