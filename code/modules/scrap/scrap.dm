GLOBAL_LIST_EMPTY(scrap_base_cache)

/obj/structure/scrap
	name = "scrap pile"
	desc = "Pile of industrial debris. It could use a shovel and pair of hands in gloves. "

	icon_state = "small"
	icon = 'icons/obj/scrap/base.dmi'

	appearance_flags = DEFAULT_APPEARANCE_FLAGS | TILE_BOUND
	anchored = TRUE
	opacity = 0
	density = FALSE

	var/loot_generated = 0
	var/icontype = "general"
	var/obj/item/storage/internal/loot
	var/loot_min = 3
	var/loot_max = 5
	var/list/loot_list = list(
		/obj/item/stack/rods,
		/obj/item/stack/material/plastic,
		/obj/item/stack/material/glass,
		/obj/item/stack/material/steel,
		/obj/item/stack/material/plasteel,
		/obj/item/stack/material/wood,
		/obj/item/material/shard,
	)

	var/dig_amount = 7
	var/parts_icon = 'icons/obj/scrap/trash.dmi'
	var/base_min = 5	//min and max number of random pieces of base icon
	var/base_max = 8
	var/base_spread = 12 //limits on pixel offsets of base pieces
	var/big_item_chance = 0
	var/obj/big_item
	var/list/ways = list("pokes around", "digs through", "rummages through", "goes through","picks through")

/obj/structure/scrap/Initialize()
	. = ..()
	rebuild_icon(TRUE)

/obj/effect/scrapshot
	name = "This thins shoots scrap everywhere with a delay"
	desc = "no data"
	invisibility = INVISIBILITY_SYSTEM
	anchored = TRUE
	density = FALSE

/obj/effect/scrapshot/Initialize(mapload, severity = 1)
	..()
	switch(severity)
		if(1)
			for(var/i in 1 to 12)
				var/projtype = pick(/obj/item/stack/rods, /obj/item/material/shard)
				var/obj/item/projectile = new projtype(loc)
				projectile.throw_at(locate(loc.x + rand(40) - 20, loc.y + rand(40) - 20, loc.z), 81, pick(1,3,80,80))
		if(2)
			for(var/i in 1 to 4)
				var/projtype = pick(subtypesof(/obj/item/trash))
				var/obj/item/projectile = new projtype(loc)
				projectile.throw_at(locate(loc.x + rand(10) - 5, loc.y + rand(10) - 5, loc.z), 3, 1)
	return INITIALIZE_HINT_QDEL

/obj/structure/scrap/attack_hand(mob/user)
	if(hurt_hand(user))
		return

	try_make_loot()
	loot.open(user)
	return ..()

/obj/structure/scrap/ex_act(severity)
	set waitfor = FALSE
	if (prob(25))
		new /obj/effect/effect/smoke(loc)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			new /obj/effect/scrapshot(loc, 1)
			dig_amount = 0
		if(EXPLODE_HEAVY)
			new /obj/effect/scrapshot(loc, 2)
			dig_amount = dig_amount / 3
		if(EXPLODE_LIGHT)
			dig_amount = dig_amount / 2
	if(dig_amount < 4)
		qdel_self()
	else
		rebuild_icon(TRUE)

/obj/structure/scrap/attackby(obj/item/W, mob/user)
	var/dig_duration = 0
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	if(istype(W, /obj/item/shovel))
		dig_duration = 3 SECONDS
	if(istype(W,/obj/item/stack/rods))
		dig_duration = 5 SECONDS

	if(dig_duration)
		user.do_attack_animation(src)
		if(!do_after(user, dig_duration, src) || QDELETED(src))
			return

		visible_message(SPAN_NOTICE("\The [user] [pick(ways)] \the [src]."))
		shuffle_loot()
		dig_out_lump(get_turf(user), FALSE)

/obj/structure/scrap/proc/dig_out_lump(newloc = loc, hard_dig = FALSE)
	dig_amount--
	if(dig_amount <= 0)
		visible_message(SPAN_NOTICE("\The [src] is cleared out!"))
		if(!hard_dig && big_item)
			big_item.forceMove(get_turf(src))
			big_item = null
		qdel_self()
		return FALSE
	//else
	//	new /obj/item/weapon/scrap_lump(newloc)
	//	return TRUE

/obj/structure/scrap/proc/rebuild_icon(rebuild_base = FALSE)
	if(rebuild_base)
		var/ID = rand(40)
		if(!GLOB.scrap_base_cache["[icontype][icon_state][ID]"])
			var/num = rand(base_min,base_max)
			var/image/base_icon = image(icon, icon_state = icon_state)
			for(var/i=1 to num)
				var/image/I = image(parts_icon,pick(icon_states(parts_icon)))
				I.color = pick("#996633", "#663300", "#666666", "")
				base_icon.AddOverlays(randomize_image(I))
			GLOB.scrap_base_cache["[icontype][icon_state][ID]"] = base_icon
		AddOverlays(GLOB.scrap_base_cache["[icontype][icon_state][ID]"])

	if(loot_generated)
		underlays.Cut()
		for(var/obj/O in loot.contents)
			var/image/I = image(O.icon,O.icon_state)
			I.color = O.color
			underlays |= randomize_image(I)
	if(big_item)
		var/image/I = image(big_item.icon,big_item.icon_state)
		I.color = big_item.color
		underlays |= I

/obj/structure/scrap/proc/randomize_image(image/I)
	I.pixel_x = rand(-base_spread,base_spread)
	I.pixel_y = rand(-base_spread,base_spread)
	var/matrix/M = matrix()
	M.Turn(pick(0,90.180,270))
	I.transform = M
	return I

/obj/structure/scrap/proc/hurt_hand(mob/user)
	if(!ishuman(user))
		return FALSE

	var/mob/living/carbon/human/victim = user
	var/obj/item/organ/external/BP = victim?.get_organ(pick(BP_L_HAND, BP_R_HAND))
	var/obj/item/clothing/gloves/G = victim?.gloves
	if(!BP?.can_feel_pain() || (victim.species.species_flags & SPECIES_FLAG_NO_MINOR_CUT) || (G?.item_flags & ITEM_FLAG_THICKMATERIAL))
		return FALSE

	else if(prob(50))
		to_chat(user, SPAN_DANGER("Ouch! You cut yourself while picking through \the [src]."))
		BP.take_external_damage(5, null, DAM_SHARP | DAM_EDGE, "Sharp debris")
		victim.reagents.add_reagent(/datum/reagent/toxin, pick(prob(50); 0, prob(50); 5, prob(10); 10, prob(1); 25))
		if(victim.species.species_flags & SPECIES_FLAG_NO_PAIN)
			return FALSE // So we still take damage, but actually dig through.
		return TRUE
	return FALSE

/obj/structure/scrap/proc/make_big_loot()
	//if(prob(big_item_chance))
	//	var/random_type = PATH_OR_RANDOM_PATH(/obj/random/structures/structure_pack)
	//	big_item = new random_type(src)
	///	if(big_item)
	//		big_item.forceMove(src)
	//		if(prob(66))
	//			big_item.make_old()

/obj/structure/scrap/proc/try_make_loot()
	if(loot_generated)
		return

	loot_generated = TRUE
	if(!big_item)
		make_big_loot()
	var/amt = rand(loot_min, loot_max)
	for(var/x = 1 to amt)
		var/loot_path = pick(loot_list)
		if(ispath(loot_path, /obj/item/stack))
			new loot_path(src, amount_in_stack(loot_path))
		else
			new loot_path(src)
	for(var/obj/item/I in contents)
		if(prob(66))
			I.make_old()
	loot = new (src)
	loot.storage_slots = 7
	shuffle_loot()

/obj/structure/scrap/proc/amount_in_stack(path)
	var/amount = rand(20, 40)
	if (ispath(path, /obj/item/stack/rods))
		amount = rand(3, 8)
	else if (ispath(path, /obj/item/stack/material/plastic))
		amount = rand(5, 10)
	else if (ispath(path, /obj/item/stack/material/steel))
		amount = rand(8, 12)
	else if (ispath(path,/obj/item/stack/material/glass))
		amount = rand(5, 10)
	else if (ispath(path, /obj/item/stack/material/plasteel))
		amount = rand(1, 3)
	else if (ispath(path, /obj/item/stack/material/wood))
		amount = rand(3, 8)
	return amount

/obj/structure/scrap/proc/shuffle_loot()
	try_make_loot()
	loot.close_all()
	for(var/A in loot)
		loot.remove_from_storage(A, src)

	if(contents.len)
		contents = shuffle(contents)
		var/num = rand(1, loot_min)
		for(var/obj/item/O in contents)
			if(O == loot || O == big_item)
				continue

			if(num == 0)
				break

			O.forceMove(loot)
			num--
	rebuild_icon()

/obj/structure/scrap/Destroy()
	QDEL_NULL_LIST(loot)
	if(big_item)
		QDEL_NULL(big_item)

	return ..()

/obj/structure/scrap/large
	name = "large scrap pile"
	opacity = 1
	density = TRUE
	icon_state = "big"
	loot_min = 10
	loot_max = 20
	dig_amount = 15
	base_min = 9
	base_max = 14
	base_spread = 16

/obj/structure/scrap/medical
	icontype = "medical"
	name = "medical refuse pile"
	desc = "Pile of medical refuse. They sure don't cut expenses on these. "
	parts_icon = 'icons/obj/scrap/medical_trash.dmi'
	loot_list = list(
		/obj/random/medical,
		/obj/random/medical/lite,
		/obj/random/medical/lite,
		/obj/random/firstaid,
		/obj/item/stack/rods,
		/obj/item/material/shard,
		/obj/random/maintenance/clean,
		/obj/random/maintenance,
		/obj/random/maintenance,
		/obj/random/maintenance,
		/obj/random/junk,
	)

/obj/structure/scrap/vehicle
	icontype = "vehicle"
	name = "industrial debris pile"
	desc = "Pile of used machinery. You could use tools from this to build something."
	parts_icon = 'icons/obj/scrap/vehicle.dmi'
	loot_list = list(
		/obj/random/tech_supply,
		/obj/random/tech_supply,
		/obj/random/tech_supply,
		/obj/random/maintenance/clean,
		/obj/random/maintenance/clean,
		/obj/item/stack/rods,
		/obj/item/stack/material/steel,
		/obj/item/material/shard,
		/obj/random/maintenance/clean,
		/obj/random/maintenance,
		/obj/random/maintenance,
		/obj/random/maintenance,
		/obj/random/junk,
	)

/obj/structure/scrap/food
	icontype = "food"
	name = "food trash pile"
	desc = "Pile of thrown away food. Someone sure have lots of spare food while children on Mars are starving."
	parts_icon = 'icons/obj/scrap/food_trash.dmi'
	loot_list = list(
		/obj/random/snack,
		/obj/random/snack,
		/obj/random/snack,
		/obj/random/snack,
		/obj/random/snack,
		/obj/item/material/shard,
		/obj/item/stack/rods,
		/obj/random/maintenance/clean,
		/obj/random/maintenance,
		/obj/random/maintenance,
		/obj/random/maintenance,
		/obj/random/junk,
	)

/obj/structure/scrap/guns
	icontype = "guns"
	name = "gun refuse pile"
	desc = "Pile of military supply refuse. Who thought it was a clever idea to throw that out?"
	parts_icon = 'icons/obj/scrap/guns_trash.dmi'
	loot_list = list(
		/obj/random/projectile,
		/obj/random/ammo,
		/obj/random/powercell,
		/obj/random/energy,
		/obj/random/toy,
		/obj/item/toy/crossbow,
		/obj/item/material/shard,
		/obj/random/material,
		/obj/item/stack/rods,
		/obj/random/maintenance/clean,
		/obj/random/maintenance,
		/obj/random/maintenance,
		/obj/random/maintenance,
		/obj/random/junk,
	)

/obj/structure/scrap/cloth
	icontype = "cloth"
	name = "cloth pile"
	desc = "Pile of second hand clothing for charity."
	parts_icon = 'icons/obj/scrap/cloth.dmi'
	loot_list = list(
		/obj/random/clothing/suit,
		/obj/random/maintenance/clean,
		/obj/random/maintenance,
		/obj/random/maintenance,
		/obj/random/maintenance,
		/obj/random/junk,
	)

/obj/structure/scrap/cloth_safe
	icontype = "cloth"
	name = "cloth pile"
	desc = "Pile of second hand clothing for charity."
	parts_icon = 'icons/obj/scrap/cloth.dmi'
	loot_list = list(
		/obj/random/clothing/suit,
		/obj/random/maintenance/clean,
		/obj/random/maintenance,
		/obj/random/maintenance,
		/obj/random/maintenance,
		/obj/random/junk,
	)

/obj/structure/scrap/syndie
	icontype = "syndie"
	name = "strange pile"
	desc = "Pile of left magbots, broken teleports and phoron tanks, jetpacks, random stations blueprints, soap, burned rcds, and meat with orange fur?"
	parts_icon = 'icons/obj/scrap/syndie.dmi'
	loot_min = 2
	loot_max = 4
	loot_list = list(
		/obj/random/contraband,
		/obj/random/contraband,
		/obj/random/contraband,
		/obj/item/reagent_containers/food/meat,
		/obj/item/reagent_containers/food/meat/corgi,
		/obj/item/organ/internal/cerebrum/brain,
		/obj/random/maintenance/clean,
		/obj/random/maintenance,
		/obj/random/maintenance,
		/obj/random/maintenance,
		/obj/random/junk,
	)

/obj/structure/scrap/poor
	icontype = "poor"
	name = "mixed rubbish"
	desc = "Pile of mixed rubbish. Useless and rotten, mostly."
	parts_icon = 'icons/obj/scrap/all_mixed.dmi'
	loot_list = list(
		/obj/random/loot,
		/obj/random/loot,
		/obj/random/maintenance/clean,
		/obj/random/junk,
		/obj/random/tool,
		/obj/item/material/shard,
		/obj/item/stack/rods,
		/obj/random/maintenance/clean,
		/obj/random/maintenance,
		/obj/random/maintenance,
		/obj/random/maintenance,
		/obj/random/junk,
	)

/obj/structure/scrap/poor/large
	name = "large mixed rubbish"
	opacity = 1
	density = TRUE
	icon_state = "big"
	loot_min = 10
	loot_max = 20
	dig_amount = 15
	base_min = 9
	base_max = 14
	big_item_chance = 40

/obj/structure/scrap/vehicle/large
	name = "large industrial debris pile"
	opacity = 1
	density = TRUE
	icon_state = "big"
	loot_min = 10
	loot_max = 20
	dig_amount = 15
	base_min = 9
	base_max = 14
	base_spread = 16
	big_item_chance = 33

/obj/structure/scrap/food/large
	name = "large food trash pile"
	opacity = 1
	density = TRUE
	icon_state = "big"
	loot_min = 10
	loot_max = 20
	dig_amount = 15
	base_min = 9
	base_max = 14
	base_spread = 16
	big_item_chance = 33

/obj/structure/scrap/medical/large
	name = "large medical refuse pile"
	opacity = 1
	density = TRUE
	icon_state = "big"
	loot_min = 10
	loot_max = 20
	dig_amount = 15
	base_min = 9
	base_max = 14
	base_spread = 16
	big_item_chance = 33

/obj/structure/scrap/guns/large
	name = "large gun refuse pile"
	opacity = 1
	density = TRUE
	icon_state = "big"
	loot_min = 10
	loot_max = 15
	dig_amount = 15
	base_min = 9
	base_max = 14
	base_spread = 16
	big_item_chance = 33

/obj/structure/scrap/science/large
	name = "large scientific trash pile"
	opacity = 1
	density = TRUE
	icon_state = "big"
	loot_min = 10
	loot_max = 20
	dig_amount = 15
	base_min = 9
	base_max = 14
	base_spread = 16
	big_item_chance = 33

/obj/structure/scrap/cloth/large
	name = "large cloth pile"
	opacity = 1
	density = TRUE
	icon_state = "big"
	loot_min = 8
	loot_max = 14
	dig_amount = 15
	base_min = 9
	base_max = 14
	base_spread = 16
	big_item_chance = 33

/obj/structure/scrap/syndie/large
	name = "large strange pile"
	opacity = 1
	density = TRUE
	icon_state = "big"
	loot_min = 4
	loot_max = 12
	dig_amount = 15
	base_min = 9
	base_max = 14
	base_spread = 16
	big_item_chance = 33

/obj/structure/scrap/poor/structure
	name = "large mixed rubbish"
	opacity = 1
	density = TRUE
	icon_state = "med"
	loot_min = 3
	loot_max = 6
	dig_amount = 3
	base_min = 3
	base_max = 6
	big_item_chance = 100

/obj/structure/scrap/poor/structure/rebuild_icon() //make big trash icon for this
	..()
	if(!loot_generated)
		underlays += image(icon, icon_state = "underlay_big")

/obj/structure/scrap/poor/structure/make_big_loot()
	..()
	if(big_item)
		visible_message("<span class='notice'>\The [src] reveals [big_item] underneath the trash!</span>")
