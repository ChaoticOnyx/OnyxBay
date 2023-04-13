
/obj/item/metroidpotion/enhancer/max
	name = "extract maximizer"
	desc = "An extremely potent chemical mix that will maximize a metroid extract's uses."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potpurple"

/obj/item/metroidpotion/extract_cloner
	name = "extract cloner"
	desc = "A potent chemical mix that will give a copy of metroid extract."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potcaeruleum"

/obj/item/metroidpotion/extract_cloner/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(istype(target, /obj/item/metroid_extract))
		new target.type(target.loc)
		qdel(src)

//Revival potion - Charged Green
/obj/item/metroidpotion/metroid_reviver
	name = "metroid revival potion"
	desc = "Infused with plasma and compressed gel, this brings dead metroids back to life."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potsilver"

/obj/item/metroidpotion/metroid_reviver/attack(mob/living/carbon/metroid/revive_target, mob/user)
	if(!ismetroid(revive_target))
		to_chat(user, SPAN_WARNING("The potion only works on metroids!"))
		return ..()
	if(revive_target.stat != DEAD)
		to_chat(user, SPAN_WARNING("The metroid is still alive!"))
		return
	if(revive_target.maxHealth <= 0)
		to_chat(user, SPAN_WARNING("The metroid is too unstable to return!"))
	revive_target.revive()
	revive_target.set_stat(CONSCIOUS)
	revive_target.visible_message(SPAN_NOTICE("[revive_target] is filled with renewed vigor and blinks awake!"))
	revive_target.maxHealth -= 10 //Revival isn't healthy.
	revive_target.health -= 10
	revive_target.regenerate_icons()
	qdel(src)

//Stabilizer potion - Charged Blue
/obj/item/metroidpotion/metroid/chargedstabilizer
	name = "metroid omnistabilizer"
	desc = "An extremely potent chemical mix that will stop a metroid from mutating completely."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potcyan"

/obj/item/metroidpotion/metroid/chargedstabilizer/attack(mob/living/carbon/metroid/stabilize_target, mob/user)
	if(!ismetroid(stabilize_target))
		to_chat(user, SPAN_WARNING("The stabilizer only works on metroids!"))
		return ..()
	if(stabilize_target.stat != DEAD)
		to_chat(user, SPAN_WARNING("The metroid is dead!"))
		return
	if(stabilize_target.mutation_chance == 0)
		to_chat(user, SPAN_WARNING("The metroid already has no chance of mutating!"))
		return

	to_chat(user, SPAN_NOTICE("You feed the metroid the omnistabilizer. It will not mutate this cycle!"))
	stabilize_target.mutation_chance = 0
	qdel(src)

//Pressure potion - Charged Dark Blue
/obj/item/metroidpotion/spaceproof
	name = "metroid pressurization potion"
	desc = "A potent chemical sealant that will render any article of clothing airtight. Has two uses."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potblue"
	var/uses = 2

/obj/item/metroidpotion/spaceproof/afterattack(obj/item/clothing/C, mob/user, proximity)
	. = ..()
	if(!uses)
		qdel(src)
		return
	if(!proximity)
		return
	if(!istype(C))
		to_chat(user, SPAN_WARNING("The potion can only be used on clothing!"))
		return
	if(istype(C, /obj/item/clothing/suit/space))
		to_chat(user, SPAN_WARNING("The [C] is already pressure-resistant!"))
		return ..()
	if(C.min_cold_protection_temperature == SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE && C.item_flags & ITEM_FLAG_STOPPRESSUREDAMAGE)
		to_chat(user, SPAN_WARNING("The [C] is already pressure-resistant!"))
		return ..()
	to_chat(user, SPAN_NOTICE("You slather the blue gunk over the [C], making it airtight."))
	C.name = "pressure-resistant [C.name]"
	C.color = "#000080"
	C.min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	C.cold_protection = C.body_parts_covered
	C.item_flags |= ITEM_FLAG_STOPPRESSUREDAMAGE
	uses--
	if(!uses)
		qdel(src)

//Love potion - Charged Pink
/obj/item/metroidpotion/lovepotion
	name = "love potion"
	desc = "A pink chemical mix thought to inspire feelings of love."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potpink"

/obj/item/metroidpotion/lovepotion/attack(mob/living/love_target, mob/user)
	if(!isliving(love_target) || love_target.stat == DEAD)
		to_chat(user, SPAN_WARNING("The love potion only works on living things, sicko!"))
		return ..()
	if(user == love_target)
		to_chat(user, SPAN_WARNING("You can't drink the love potion. What are you, a narcissist?"))
		return ..()
	if("\ref[user.name]" in love_target.faction)
		to_chat(user, SPAN_WARNING("[love_target] is already lovestruck!"))
		return ..()

	love_target.visible_message(SPAN_DANGER("[user] starts to feed [love_target] a love potion!"),
		SPAN_DANGER("[user] starts to feed you a love potion!"))

	if(!do_after(user, 50, target = love_target))
		return
	to_chat(user, SPAN_NOTICE("You feed [love_target] the love potion!"))
	to_chat(love_target, SPAN_NOTICE("You develop feelings for [user], and anyone [user] like [user]."))
	love_target.faction |= "\ref[user.name]"
	user.faction |= "\ref[user.name]"
	qdel(src)

//Peace potion - Charged Light Pink
/obj/item/metroidpotion/peacepotion
	name = "pacification potion"
	desc = "A light pink solution of chemicals, smelling like liquid peace. And mercury salts."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potlightpink"

/obj/item/metroidpotion/peacepotion/attack(mob/living/peace_target, mob/user)
	if(!isliving(peace_target) || peace_target.stat == DEAD)
		to_chat(user, SPAN_WARNING("[src] only works on the living."))
		return ..()
	if(peace_target != user)
		peace_target.visible_message(SPAN_DANGER("[user] starts to feed [peace_target] [src]!"),
			SPAN_DANGER("[user] starts to feed you [src]!"))
	else
		peace_target.visible_message(SPAN_DANGER("[user] starts to drink [src]!"),
			SPAN_DANGER("You start to drink [src]!"))

	if(!do_after(user, 100, target = peace_target))
		return
	if(peace_target != user)
		to_chat(user, SPAN_NOTICE("You feed [peace_target] [src]!"))
	else
		to_chat(user, SPAN_WARNING("You drink [src]!"))
	peace_target.add_modifier(TRAIT_PACIFISM, 600)
	qdel(src)
