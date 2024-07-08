/*
Consuming extracts:
	Can eat food items.
	After consuming enough, produces special cookies.
*/
/obj/item/metroidcross/consuming
	name = "consuming extract"
	desc = "It hungers... for <i>more</i>." //My metroidcross has finally decided to eat... my buffet!
	icon_state = "consuming"
	effect = "consuming"
	var/nutriment_eaten = 0
	var/nutriment_required = 10
	var/cooldown = 600 //1 minute.
	var/last_produced = 0
	var/cookies = 3 //Number of cookies to spawn
	var/cookietype = /obj/item/metroid_cookie

/obj/item/metroidcross/consuming/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/reagent_containers/food))
		if(last_produced + cooldown > world.time)
			to_chat(user, SPAN_WARNING("[src] is still digesting after its last meal!"))
			return
		var/list/nutriments = new /list()
		for(var/datum/reagent/nutriment/N in O.reagents.reagent_list)
			if(istype(N, /datum/reagent/nutriment))
				nutriments += N

		if(isemptylist(nutriments))
			to_chat(user, SPAN_WARNING("[src] burbles unhappily at the offering."))
			return

		for(var/datum/reagent/nutriment/N in nutriments)
			nutriment_eaten += N.volume

		to_chat(user, SPAN_NOTICE("[src] opens up and swallows [O] whole!"))
		qdel(O)
		playsound(src, 'sound/items/eatfood.ogg', 20, TRUE)
		if(nutriment_eaten >= nutriment_required)
			nutriment_eaten = 0
			user.visible_message(SPAN_NOTICE("[src] swells up and produces a small pile of cookies!"))
			playsound(src, 'sound/effects/splat.ogg', 40, TRUE)
			last_produced = world.time
			for(var/i in 1 to cookies)
				var/obj/item/S = spawncookie()
				S.pixel_x += rand(-5, 5)
				S.pixel_y += rand(-5, 5)
		return
	..()

/obj/item/metroidcross/consuming/proc/spawncookie()
	return new cookietype(get_turf(src))

/obj/item/metroid_cookie //While this technically acts like food, it's so removed from it that I made it its' own type.
	name = "error cookie"
	desc = "A weird metroid cookie. You shouldn't see this."
	icon = 'icons/obj/xenobiology/metroidcookies.dmi'
	var/taste = "error"
	var/nutrition = 5
	icon_state = "base"
	force = 0
	w_class = ITEM_SIZE_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 6
	can_get_wet = FALSE
	can_be_wrung_out = FALSE

/obj/item/metroid_cookie/proc/do_effect(mob/living/M, mob/user)
	return

/obj/item/metroid_cookie/attack(mob/living/M, mob/user)
	var/fed = FALSE
	if(M == user)
		M.visible_message(SPAN_NOTICE("[user] eats [src]!"), SPAN_NOTICE("You eat [src]."))
		fed = TRUE
	else
		M.visible_message(SPAN_DANGER("[user] tries to force [M] to eat [src]!"), SPAN_DANGER("[user] tries to force you to eat [src]!"))
		if(do_after(user, 20, target = M))
			fed = TRUE
			M.visible_message(SPAN_DANGER("[user] forces [M] to eat [src]!"), SPAN_WARNING("[user] forces you to eat [src]."))
	if(fed)
		playsound(get_turf(M), 'sound/items/eatfood.ogg', 20, TRUE)
		if(nutrition)
			M.reagents.add_reagent(/datum/reagent/nutriment,nutrition)
		do_effect(M, user)
		qdel(src)
		return
	..()

/obj/item/metroidcross/consuming/green
	colour = "green"
	effect_desc = "Creates a metroid cookie."
	cookietype = /obj/item/metroid_cookie/green

/obj/item/metroid_cookie/green
	name = "metroid cookie"
	desc = "A grey-ish transparent cookie. Nutritious, probably."
	icon_state = "grey"
	taste = "goo"
	nutrition = 15

/obj/item/metroidcross/consuming/orange
	colour = "orange"
	effect_desc = "Creates a metroid cookie that heats the target up and grants cold immunity for a short time."
	cookietype = /obj/item/metroid_cookie/orange

/obj/item/metroid_cookie/orange
	name = "fiery cookie"
	desc = "An orange cookie with a fiery pattern. Feels warm."
	icon_state = "orange"
	taste = "cinnamon and burning"

/obj/item/metroid_cookie/orange/do_effect(mob/living/M, mob/user)
	M.add_modifier(/datum/modifier/status_effect/firecookie)

/obj/item/metroidcross/consuming/purple
	colour = "purple"
	effect_desc = "Creates a metroid cookie that heals the target from every type of damage."
	cookietype = /obj/item/metroid_cookie/purple

/obj/item/metroid_cookie/purple
	name = "health cookie"
	desc = "A purple cookie with a cross pattern. Soothing."
	icon_state = "purple"
	taste = "fruit jam and cough medicine"

/obj/item/metroid_cookie/purple/do_effect(mob/living/M, mob/user)
	M.adjustBruteLoss(-5)
	M.adjustFireLoss(-5)
	M.adjustToxLoss(-5) //To heal metroidpeople.
	M.adjustOxyLoss(-5)
	M.adjustCloneLoss(-5)
	M.heal_organ_damage(5,5)

/obj/item/metroidcross/consuming/blue
	colour = "blue"
	effect_desc = "Creates a metroid cookie that wets the floor around you and makes you immune to water based slipping for a short time."
	cookietype = /obj/item/metroid_cookie/blue

/obj/item/metroid_cookie/blue
	name = "water cookie"
	desc = "A transparent blue cookie. Constantly dripping wet."
	icon_state = "blue"
	taste = "water"

/obj/item/metroid_cookie/blue/do_effect(mob/living/M, mob/user)
	M.add_modifier(/datum/modifier/status_effect/watercookie)

/obj/item/metroidcross/consuming/metal
	colour = "metal"
	effect_desc = "Creates a metroid cookie that increases the target's resistance to brute damage."
	cookietype = /obj/item/metroid_cookie/metal

/obj/item/metroid_cookie/metal
	name = "metallic cookie"
	desc = "A shiny grey cookie. Hard to the touch."
	icon_state = "metal"
	taste = /datum/reagent/copper

/obj/item/metroid_cookie/metal/do_effect(mob/living/M, mob/user)
	M.add_modifier(/datum/modifier/status_effect/metalcookie)

/obj/item/metroidcross/consuming/yellow
	colour = "yellow"
	effect_desc = "Creates a metroid cookie that makes the target immune to electricity for a short time."
	cookietype = /obj/item/metroid_cookie/yellow

/obj/item/metroid_cookie/yellow
	name = "sparking cookie"
	desc = "A yellow cookie with a lightning pattern. Has a rubbery texture."
	icon_state = "yellow"
	taste = "lemon cake and rubber gloves"

/obj/item/metroid_cookie/yellow/do_effect(mob/living/M, mob/user)
	M.add_modifier(/datum/modifier/status_effect/sparkcookie)

/obj/item/metroidcross/consuming/darkpurple
	colour = "dark purple"
	effect_desc = "Creates a metroid cookie that reverses how the target's body treats toxins."
	cookietype = /obj/item/metroid_cookie/darkpurple

/obj/item/metroid_cookie/darkpurple
	name = "toxic cookie"
	desc = "A dark purple cookie, stinking of plasma."
	icon_state = "darkpurple"
	taste = "metroid jelly and toxins"

/obj/item/metroid_cookie/darkpurple/do_effect(mob/living/M, mob/user)
	M.add_modifier(/datum/modifier/status_effect/toxincookie)

/obj/item/metroidcross/consuming/darkblue
	colour = "dark blue"
	effect_desc = "Creates a metroid cookie that chills the target and extinguishes them."
	cookietype = /obj/item/metroid_cookie/darkblue

/obj/item/metroid_cookie/darkblue
	name = "frosty cookie"
	desc = "A dark blue cookie with a snowflake pattern. Feels cold."
	icon_state = "darkblue"
	taste = "mint and bitter cold"

/obj/item/metroid_cookie/darkblue/do_effect(mob/living/M, mob/user)
	M.bodytemperature-=110
	M.ExtinguishMob()

/obj/item/metroidcross/consuming/silver
	colour = "silver"
	effect_desc = "Creates a metroid cookie that help you to grow up a muscles."
	cookietype = /obj/item/metroid_cookie/silver

/obj/item/metroid_cookie/silver
	name = "waybread cookie"
	desc = "A warm, crispy cookie, sparkling silver in the light. Smells wonderful."
	icon_state = "silver"
	taste = "masterful elven baking"
	nutrition = 0 //We don't want normal nutriment

/obj/item/metroid_cookie/silver/do_effect(mob/living/M, mob/user)
	M.reagents.add_reagent(/datum/reagent/nutriment/protein,10)

/obj/item/metroidcross/consuming/bluespace
	colour = "bluespace"
	effect_desc = "Creates a metroid cookie that teleports the target to a random place in the area."
	cookietype = /obj/item/metroid_cookie/bluespace

/obj/item/metroid_cookie/bluespace
	name = "space cookie"
	desc = "A white cookie with green icing. Surprisingly hard to hold."
	icon_state = "bluespace"
	taste = "sugar and starlight"

/obj/item/metroid_cookie/bluespace/do_effect(mob/living/M, mob/user)
	var/turf/target = pick(get_area_turfs(get_area(get_turf(M)),list(/proc/not_turf_contains_dense_objects)))

	if(target)
		var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
		sparks.set_up(5, 0, loc)
		sparks.start()
		playsound(src,'sound/effects/phasein.ogg', 50, TRUE)
		do_teleport(M, target, 0)
		playsound(get_turf(M), GET_SFX(SFX_SPARK_MEDIUM), 50, TRUE)

/obj/item/metroidcross/consuming/sepia
	colour = "sepia"
	effect_desc = "Creates a metroid cookie that makes the target do things slightly faster."
	cookietype = /obj/item/metroid_cookie/sepia

/obj/item/metroid_cookie/sepia
	name = "time cookie"
	desc = "A light brown cookie with a clock pattern. Takes some time to chew."
	icon_state = "sepia"
	taste = "brown sugar and a metronome"

/obj/item/metroid_cookie/sepia/do_effect(mob/living/M, mob/user)
	M.add_modifier(/datum/modifier/status_effect/timecookie)

/obj/item/metroidcross/consuming/cerulean
	colour = "cerulean"
	effect_desc = "Creates a metroid cookie that has a chance to make another once you eat it."
	cookietype = /obj/item/metroid_cookie/cerulean
	cookies = 2 //You're gonna get more.

/obj/item/metroid_cookie/cerulean
	name = "duplicookie"
	desc = "A cerulean cookie with strange proportions. It feels like it could break apart easily."
	icon_state = "cerulean"
	taste = "a sugar cookie"

/obj/item/metroid_cookie/cerulean/do_effect(mob/living/M, mob/user)
	if(prob(50))
		to_chat(M, SPAN_NOTICE("A piece of [src] breaks off while you chew, and falls to the ground."))
		var/obj/item/metroid_cookie/cerulean/C = new(get_turf(M))
		C.taste = taste + " and a sugar cookie"

/obj/item/metroidcross/consuming/pyrite
	colour = "pyrite"
	effect_desc = "Creates a metroid cookie that randomly colors the target."
	cookietype = /obj/item/metroid_cookie/pyrite

/obj/item/metroid_cookie/pyrite
	name = "color cookie"
	desc = "A yellow cookie with rainbow-colored icing. Reflects the light strangely."
	icon_state = "pyrite"
	taste = "vanilla and " //Randomly selected color dye.
	var/colour = "#FFFFFF"

/obj/item/metroid_cookie/pyrite/Initialize(mapload)
	. = ..()
	var/tastemessage = "paint remover"
	switch(rand(1,7))
		if(1)
			tastemessage = "red dye"
			colour = "#FF0000"
		if(2)
			tastemessage = "orange dye"
			colour = "#FFA500"
		if(3)
			tastemessage = "yellow dye"
			colour = "#FFFF00"
		if(4)
			tastemessage = "green dye"
			colour = "#00FF00"
		if(5)
			tastemessage = "blue dye"
			colour = "#0000FF"
		if(6)
			tastemessage = "indigo dye"
			colour = "#4B0082"
		if(7)
			tastemessage = "violet dye"
			colour = "#FF00FF"
	taste += tastemessage

/obj/item/metroid_cookie/pyrite/do_effect(mob/living/M, mob/user)
	M.color = colour

/obj/item/metroidcross/consuming/red
	colour = "red"
	effect_desc = "Creates a metroid cookie that creates a spatter of blood on the floor, while also restoring some of the target's blood."
	cookietype = /obj/item/metroid_cookie/red

/obj/item/metroid_cookie/red
	name = "blood cookie"
	desc = "A red cookie, oozing a thick red fluid. Vampires might enjoy it."
	icon_state = "red"
	taste = "red velvet and iron"

/obj/item/metroid_cookie/red/do_effect(mob/living/M, mob/user)
	new /obj/effect/decal/cleanable/blood(get_turf(M))
	playsound(get_turf(M), 'sound/effects/splat.ogg', 10, TRUE)
	if(ishuman(M))
		var/mob/living/carbon/human/C = M
		C.regenerate_blood(25)

/obj/item/metroidcross/consuming/grey
	colour = "grey"
	effect_desc = "Creates a metroid cookie that is absolutely disgusting, makes the target vomit, however all reagent in their body are also removed."
	cookietype = /obj/item/metroid_cookie/grey

/obj/item/metroid_cookie/grey
	name = "gross cookie"
	desc = "A disgusting green cookie, seeping with pus. You kind of feel ill just looking at it."
	icon_state = "green"
	taste = "the contents of your stomach"

/obj/item/metroid_cookie/green/do_effect(mob/living/M, mob/user)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.vomit(25)
	M.reagents.clear_reagents()

/obj/item/metroidcross/consuming/pink
	colour = "pink"
	effect_desc = "Creates a metroid cookie that makes the target want to spread the love."
	cookietype = /obj/item/metroid_cookie/pink

/obj/item/metroid_cookie/pink
	name = "love cookie"
	desc = "A pink cookie with an icing heart. D'aww."
	icon_state = "pink"
	taste = "love and hugs"

/obj/item/metroid_cookie/pink/do_effect(mob/living/M, mob/user)
	M.add_modifier(/datum/modifier/status_effect/lovecookie)

/obj/item/metroidcross/consuming/gold
	colour = "gold"
	effect_desc = "Creates a metroid cookie that has a gold coin inside."
	cookietype = /obj/item/metroid_cookie/gold

/obj/item/metroid_cookie/gold
	name = "gilded cookie"
	desc = "A buttery golden cookie, closer to a bread than anything. May good fortune find you."
	icon_state = "gold"
	taste = "sweet cornbread and wealth"

/obj/item/metroid_cookie/gold/do_effect(mob/living/L, mob/user)
	var/mob/living/carbon/human/M = L
	M.drop_active_hand()
	var/newcoin = /obj/item/material/coin/gold
	var/obj/item/material/coin/C = new newcoin(get_turf(M))
	playsound(get_turf(C), 'sound/items/coinflip.ogg', 50, TRUE)
	M.put_in_any_hand_if_possible(C)

/obj/item/metroidcross/consuming/oil
	colour = "oil"
	effect_desc = "Creates a metroid cookie that slows anyone next to the user."
	cookietype = /obj/item/metroid_cookie/oil

/obj/item/metroid_cookie/oil
	name = "tar cookie"
	desc = "An oily black cookie, which sticks to your hands. Smells like chocolate."
	icon_state = "oil"
	taste = "rich molten chocolate and tar"

/obj/item/metroid_cookie/oil/do_effect(mob/living/M, mob/user)
	M.add_modifier(/datum/modifier/status_effect/tarcookie)

/obj/item/metroidcross/consuming/black
	colour = "black"
	effect_desc = "Creates a metroid cookie that makes the target look like a spooky skeleton for a little bit."
	cookietype = /obj/item/metroid_cookie/black

/obj/item/metroid_cookie/black
	name = "spooky cookie"
	desc = "A pitch black cookie with an icing ghost on the front. Spooky!"
	icon_state = "black"
	taste = "ghosts and stuff"

/obj/item/metroid_cookie/black/do_effect(mob/living/M, mob/user)
	M.add_modifier(/datum/modifier/status_effect/spookcookie)

/obj/item/metroidcross/consuming/lightpink
	colour = "light pink"
	effect_desc = "Creates a metroid cookie that makes the target, and anyone next to the target, pacifistic for a small amount of time."
	cookietype = /obj/item/metroid_cookie/lightpink

/obj/item/metroid_cookie/lightpink
	name = "peace cookie"
	desc = "A light pink cookie with a peace symbol in the icing. Lovely!"
	icon_state = "lightpink"
	taste = "strawberry icing and P.L.U.R" //Literal candy raver.

/obj/item/metroid_cookie/lightpink/do_effect(mob/living/M, mob/user)
	M.add_modifier(/datum/modifier/status_effect/peacecookie)

/obj/item/metroidcross/consuming/adamantine
	colour = "adamantine"
	effect_desc = "Creates a metroid cookie that increases the target's resistance to burn damage."
	cookietype = /obj/item/metroid_cookie/adamantine

/obj/item/metroid_cookie/adamantine
	name = "crystal cookie"
	desc = "A translucent rock candy in the shape of a cookie. Surprisingly chewy."
	icon_state = "adamantine"
	taste = "crystalline sugar and metal"

/obj/item/metroid_cookie/adamantine/do_effect(mob/living/M, mob/user)
	M.add_modifier(/datum/modifier/status_effect/adamantinecookie)

/obj/item/metroidcross/consuming/rainbow
	colour = "rainbow"
	effect_desc = "Creates a metroid cookie that has the effect of a random cookie."

/obj/item/metroidcross/consuming/rainbow/spawncookie()
	var/cookie_type = pick(subtypesof(/obj/item/metroid_cookie))
	var/obj/item/metroid_cookie/S = new cookie_type(get_turf(src))
	S.name = "rainbow cookie"
	S.desc = "A beautiful rainbow cookie, constantly shifting colors in the light."
	S.icon_state = "rainbow"
	return S
