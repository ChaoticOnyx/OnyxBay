
/obj/item/plant_pot
	name = "plant pot"
	desc = "A pot. For plants."
	icon = 'icons/obj/flora/plant_pots.dmi'
	icon_state = "pot"
	base_icon_state = "pot"
	center_of_mass = "x=16;y=13"
	w_class = ITEM_SIZE_NORMAL
	var/obj/item/reagent_containers/food/pottable_plant/my_plant = null
	var/obj/item/my_secret = null

	var/base_name = "plant pot"
	var/base_desc = "A pot. For plants."
	var/startplant = null

/obj/item/plant_pot/Initialize()
	. = ..()
	if(startplant)
		my_plant = new startplant(src)
		update_info()

/obj/item/plant_pot/Destroy()
	QDEL_NULL(my_plant)
	QDEL_NULL(my_secret)
	return ..()

/obj/item/plant_pot/on_update_icon()
	ClearOverlays()
	if(my_plant)
		AddOverlays(my_plant)
		AddOverlays(OVERLAY(icon, base_icon_state + "-overlay"))

/obj/item/plant_pot/attack_hand(mob/user)
	if(istype(loc, /obj/item/storage))
		return ..()

	if(loc == user && user.get_inactive_hand() != src)
		return ..()

	if(!my_plant && !my_secret)
		return ..()

	if(user.a_intent == I_GRAB || user.get_inactive_hand() == src)
		uproot(user)
		return

	user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
	switch(user.a_intent)
		if(I_HELP)
			user.visible_message(SPAN("notice", "[user] pets \the [src]!"))
		if(I_DISARM)
			user.visible_message("[user] pokes \the [src]!")
		if(I_HURT)
			user.visible_message(SPAN("warning", "[user] slaps \the [src]!"))

/obj/item/plant_pot/MouseDrop(mob/user)
	if(!CanMouseDrop(src, usr))
		return

	if(user == usr && (user.contents.Find(src) || in_range(src, user)))
		if(!ishuman(user) || user.get_active_hand())
			return

		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/temp = H.organs_by_name[BP_R_HAND]
		if(H.hand)
			temp = H.organs_by_name[BP_L_HAND]
		if(temp && !temp.is_usable())
			to_chat(user, SPAN("warning", "You try to pick up \the [src] with your [temp.name], but cannot!"))
			return
		if(user.pick_or_drop(src, loc))
			to_chat(user, SPAN("notice", "You pick up \the [src]."))
	return

/obj/item/plant_pot/proc/uproot(mob/user)
	if(!ishuman(user) || user.get_active_hand())
		return

	if(my_plant)
		user.pick_or_drop(my_plant, get_turf(src))
		to_chat(user, SPAN("notice", "You uproot \the [my_plant] from \the [src]."))
		update_info()
	else if(my_secret)
		user.pick_or_drop(my_secret, get_turf(src))
		to_chat(user, SPAN("notice", "You take \the [my_secret] from \the [src]."))
		update_info()

/obj/item/plant_pot/proc/plant_thing(obj/item/I, mob/user)
	if(istype(I, /obj/item/reagent_containers/food/pottable_plant))
		if(my_plant)
			return
		if(user)
			if(!user.drop(I, src))
				return
			to_chat(user, "You plant \the [I] into \the [src]!")
		else
			I.forceMove(src)

		my_plant = I
		update_info()
		return

	if(I.w_class == ITEM_TINY)
		if(my_secret)
			if(user)
				to_chat(user, "There's already something in \the [src]!")
			return

		if(user)
			if(!user.drop(I, src))
				return
			to_chat(user, "You hide \the [I] in \the [src]!")
		else
			I.forceMove(src)

		my_secret = I
		update_info()
		return

	return ..()

/obj/item/plant_pot/proc/update_info()
	if(!my_plant)
		name = base_name
		desc = base_desc
	else
		name = "potted " + my_plant.base_name
		desc = my_plant.base_desc
		if(my_secret)
			desc += " It looks like there's something hidden inside."
	update_icon()


// Yes, these are snackies
/obj/item/reagent_containers/food/pottable_plant
	name = "pottable small plant"
	desc = "A tiny plant that can be usually found residing in a pot. Adorable!"
	icon = 'icons/obj/flora/plant_pots.dmi'
	filling_color = "#367C3D"
	center_of_mass = "x=16;y=17"
	nutriment_amt = 5
	nutriment_desc = list("greens" = 5)
	bitesize = 1
	var/base_name = "small plant"

/obj/item/flora/pottedplant_small/sapling
	name = "potted sapling"
	desc = "Tree sampling, living in a tiny pot. It will grow into a big tree some day."
	icon_state = "plant-01"

/obj/item/flora/pottedplant_small/fern
	name = "small potted fern"
	desc = "This is an ordinary looking fern. It has one big leaf."
	icon_state = "plant-02"

/obj/item/flora/pottedplant_small/tree
	name = "miniature potted tree"
	desc = "This is a tiny tree. It has hard bark and some tiny leaves."
	icon_state = "plant-03"

/obj/item/flora/pottedplant_small/bamboo
	name = "potted bamboo"
	desc = "This is a tiny bamboo shoot. The top looks like it's been cut short."
	icon_state = "plant-04"

/obj/item/flora/pottedplant_small/smallbush
	name = "small potted bush"
	desc = "This is a small bush. The two big leaves stick upwards in an odd fashion."
	icon_state = "plant-05"

/obj/item/flora/pottedplant_small/thinbush
	name = "thin potted bush"
	desc = "This is a thin bush. It appears to be flowering."
	icon_state = "plant-06"

/obj/item/flora/pottedplant_small/mysterious
	name = "reedy potted bulb"
	desc = "A reedy plant mostly used for decoration in Skrell homes, admired for its luxuriant stalks. Touching its one bulb causes it to shrink."
	icon_state = "plant-07"

/obj/item/flora/pottedplant_small/unusual
	name = "unusual potted plant"
	desc = "A fleshy cave dwelling plant with one small flower nodule. Its bulbous end emits a soft blue light."
	icon_state = "plant-08"

/obj/item/flora/pottedplant_small/unusual/Initialize()
	. = ..()
	set_light(l_range = 2, l_power = 2, l_color = "#007fff")

/obj/item/flora/pottedplant_small/smallcactus
	name = "miniature potted cactus"
	desc = "A scrubby cactus adapted to the Moghes deserts."
	icon_state = "plant-09"

/obj/item/flora/pottedplant_small/tall
	name = "small potted plant"
	desc = "A hardy succulent adapted to the Moghes deserts. Tiny pores line its surface."
	icon_state = "plant-10"

/obj/item/flora/pottedplant_small/smelly
	name = "smelly potted plant"
	desc = "That's a big flower. It reeks of rotten eggs."
	icon_state = "plant-11"

/obj/item/flora/pottedplant_small/bouquet
	name = "tiny potted bouquet"
	desc = "A pitiful pot of just three tiny flowers."
	icon_state = "plant-12"

/obj/item/flora/pottedplant_small/shoot
	name = "small potted shoot"
	desc = "This is a tiny shoot. It still needs time to grow."
	icon_state = "plant-13"

/obj/item/flora/pottedplant_small/orchid
	name = "sweet potted orchid"
	desc = "An orchid plant, as beautiful as it is delicate. Sweet smelling flower is supported by spindly stems."
	icon_state = "plant-14"

/obj/item/flora/pottedplant_small/crystal
	name = "crystalline potted plant"
	desc = "A ropey, aquatic plant. Odd crystal formations grow on the end."
	icon_state = "plant-15"

/obj/item/flora/pottedplant_small/subterranean
	name = "subterranean potted plant-fungus"
	desc = "A bioluminescent subterranean half-plant half-fungus hybrid, its bulbous ends glow faintly. Said to come from Sedantis I."
	icon_state = "plant-16"

/obj/item/flora/pottedplant_small/subterranean/Initialize()
	. = ..()
	set_light(l_range = 1, l_power = 0.5, l_color = "#ff6633")

/obj/item/flora/pottedplant_small/stoutbush
	name = "stout potted bush"
	desc = "This is a miniature stout bush. Its leaves point up and outwards."
	icon_state = "plant-17"

/obj/item/flora/pottedplant_small/drooping
	name = "drooping potted plant"
	desc = "This is a tiny plant. It has just one drooping leaf, making it look like it's wilted."
	icon_state = "plant-18"

/obj/item/flora/pottedplant_small/tropical
	name = "tropical potted plant"
	desc = "This is some kind of tropical plant. It is very young, and hasn't begun to flower yet."
	icon_state = "plant-19"

/obj/item/flora/pottedplant_small/flower
	name = "potted flower"
	desc = "A small potted flower. It appears to be healthy and growing strong."
	icon_state = "plant-20"

/obj/item/flora/pottedplant_small/bulrush
	name = "small potted grass"
	desc = "A bulrush, wetland grass-like plant. This one is tiny, and does not have any flowers."
	icon_state = "plant-21"

/obj/item/flora/pottedplant_small/rose
	name = "thorny potted rose"
	desc = "A flowering rose. It has sharp thorns on its stems."
	icon_state = "plant-22"

/obj/item/flora/pottedplant_small/whitetulip
	name = "potted tulip"
	desc = "A potted plant, with one large white flower bud."
	icon_state = "plant-23"

/obj/item/flora/pottedplant_small/woodyshrub
	name = "woody potted shrub"
	desc = "A woody shrub."
	icon_state = "plant-24"

/obj/item/flora/pottedplant_small/woodyshrubdying
	name = "dying woody potted shrub"
	desc = "A woody shrub. Seems to be in need of watering."
	icon_state = "plant-25"

/obj/item/flora/pottedplant_small/woodyshrubbloom
	name = "blooming woody potted shrub"
	desc = "A woody shrub. This one seems to be in bloom."
	icon_state = "plant-26"

/obj/item/flora/pottedplant_small/bluefern
	name = "blueish potted fern"
	desc = "A miniature fern, with one big dark blue leaf."
	icon_state = "plant-27"
