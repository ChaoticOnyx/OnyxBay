
/obj/item/plant_pot
	name = "plant pot"
	desc = "A small pot. For small plants."
	icon = 'icons/obj/flora/plant_pots.dmi'
	icon_state = "pot"
	base_icon_state = "pot"
	center_of_mass = "x=16;y=13"
	w_class = ITEM_SIZE_SMALL
	var/obj/item/reagent_containers/food/pottable_plant/my_plant = null
	var/obj/item/my_secret = null

	var/base_name = "plant pot"
	var/base_desc = "A small pot. For small plants."
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
	icon_state = base_icon_state
	if(my_plant)
		var/image/PI = image(my_plant.icon, my_plant.icon_state)
		PI.color = my_plant.color
		AddOverlays(PI)
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
		to_chat(user, SPAN("notice", "You uproot \the [my_plant] from \the [base_name]."))
		my_plant = null
		update_info()
	else if(my_secret)
		user.pick_or_drop(my_secret, get_turf(src))
		to_chat(user, SPAN("notice", "You take \the [my_secret] from \the [base_name]."))
		my_secret = null
		update_info()

/obj/item/plant_pot/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/reagent_containers/food/pottable_plant))
		if(my_plant)
			to_chat(user, SPAN("notice", "There's no space for another plant!"))
			return
		if(user)
			if(!user.drop(I, src))
				return
			to_chat(user, SPAN("notice", "You plant \the [I] into \the [src]!"))
		else
			I.forceMove(src)

		my_plant = I
		update_info()
		return

	if(I.w_class <= ITEM_SIZE_SMALL)
		if(my_secret)
			if(user)
				to_chat(user, SPAN("notice", "There's already something hidden in \the [src]!"))
			return

		if(user)
			if(!user.drop(I, src))
				return
			to_chat(user, SPAN("notice", "You hide \the [I] in \the [src]!"))
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
		if(my_secret)
			desc += " It seems there's something hidden inside."
	else
		name = "potted " + my_plant.base_name
		desc = my_plant.desc
	update_icon()


/obj/item/plant_pot/random
	name = "random potted plant"
	icon_state = "random"
	startplant = null

/obj/item/plant_pot/random/Initialize()
	. = ..()
	startplant = pick(subtypesof(/obj/item/reagent_containers/food/pottable_plant))
	my_plant = new startplant(src)
	update_info()

// Yes, these are snackies
/obj/item/reagent_containers/food/pottable_plant
	name = "pottable small plant"
	desc = "A tiny plant that can be usually found residing in a pot. Adorable!"
	icon = 'icons/obj/flora/plant_pots.dmi'
	w_class = ITEM_SIZE_SMALL
	filling_color = "#367C3D"
	center_of_mass = "x=16;y=17"
	nutriment_amt = 5
	nutriment_desc = list("greens" = 5)
	bitesize = 1
	var/base_name = "small plant"

/obj/item/reagent_containers/food/pottable_plant/sapling
	name = "pottable sapling"
	desc = "Tree sampling, fitting perfectly in a tiny pot. It will grow into a big tree some day."
	icon_state = "plant-01"
	base_name = "sapling"

/obj/item/plant_pot/sapling
	icon_state = "01"
	startplant = /obj/item/reagent_containers/food/pottable_plant/sapling

/obj/item/reagent_containers/food/pottable_plant/fern
	name = "small pottable fern"
	desc = "This is an ordinary looking fern. It has one big leaf."
	icon_state = "plant-02"
	base_name = "small fern"

/obj/item/plant_pot/fern
	icon_state = "02"
	startplant = /obj/item/reagent_containers/food/pottable_plant/fern

/obj/item/reagent_containers/food/pottable_plant/tree
	name = "miniature pottable tree"
	desc = "This is a tiny tree. It has hard bark and some tiny leaves."
	icon_state = "plant-03"
	base_name = "miniature tree"

/obj/item/plant_pot/tree
	icon_state = "03"
	startplant = /obj/item/reagent_containers/food/pottable_plant/tree

/obj/item/reagent_containers/food/pottable_plant/bamboo
	name = "pottable bamboo shoot"
	desc = "This is a tiny bamboo shoot. The top looks like it's been cut short."
	icon_state = "plant-04"
	base_name = "bamboo shoot"

/obj/item/plant_pot/bamboo
	icon_state = "04"
	startplant = /obj/item/reagent_containers/food/pottable_plant/bamboo

/obj/item/reagent_containers/food/pottable_plant/smallbush
	name = "small pottable bush"
	desc = "This is a small bush. The two big leaves stick upwards in an odd fashion."
	icon_state = "plant-05"
	base_name = "small bush"

/obj/item/plant_pot/smallbush
	icon_state = "05"
	startplant = /obj/item/reagent_containers/food/pottable_plant/smallbush

/obj/item/reagent_containers/food/pottable_plant/thinbush
	name = "thin pottable bush"
	desc = "This is a thin bush. It appears to be flowering."
	icon_state = "plant-06"
	base_name = "thin bush"

/obj/item/plant_pot/thinbush
	icon_state = "06"
	startplant = /obj/item/reagent_containers/food/pottable_plant/thinbush

/obj/item/reagent_containers/food/pottable_plant/mysterious
	name = "reedy pottable bulb"
	desc = "A reedy plant mostly used for decoration in Skrell homes, admired for its luxuriant stalks. Touching its one bulb causes it to shrink."
	icon_state = "plant-07"
	base_name = "reedy bulb"

/obj/item/plant_pot/mysterious
	icon_state = "07"
	startplant = /obj/item/reagent_containers/food/pottable_plant/mysterious

/obj/item/reagent_containers/food/pottable_plant/unusual
	name = "unusual pottable plant"
	desc = "A fleshy cave dwelling plant with one small flower nodule. Its bulbous end emits a soft blue light."
	icon_state = "plant-08"
	base_name = "unusual plant"

/obj/item/plant_pot/unusual
	icon_state = "08"
	startplant = /obj/item/reagent_containers/food/pottable_plant/unusual

/obj/item/reagent_containers/food/pottable_plant/smallcactus
	name = "miniature pottable cactus"
	desc = "A scrubby cactus adapted to the Moghes deserts."
	icon_state = "plant-09"
	base_name = "miniature cactus"

/obj/item/plant_pot/smallcactus
	icon_state = "09"
	startplant = /obj/item/reagent_containers/food/pottable_plant/smallcactus

/obj/item/reagent_containers/food/pottable_plant/tall
	name = "small pottable plant"
	desc = "A hardy succulent adapted to the Moghes deserts. Tiny pores line its surface."
	icon_state = "plant-10"
	base_name = "small plant"

/obj/item/plant_pot/tall
	icon_state = "10"
	startplant = /obj/item/reagent_containers/food/pottable_plant/tall

/obj/item/reagent_containers/food/pottable_plant/smelly
	name = "smelly pottable plant"
	desc = "That's a big flower. It reeks of rotten eggs."
	icon_state = "plant-11"
	base_name = "smelly plant"

/obj/item/plant_pot/smelly
	icon_state = "11"
	startplant = /obj/item/reagent_containers/food/pottable_plant/smelly

/obj/item/reagent_containers/food/pottable_plant/bouquet
	name = "tiny pottable bouquet"
	desc = "A pitiful pot of just three tiny flowers."
	icon_state = "plant-12"
	base_name = "tiny bouquet"

/obj/item/plant_pot/bouquet
	icon_state = "12"
	startplant = /obj/item/reagent_containers/food/pottable_plant/bouquet

/obj/item/reagent_containers/food/pottable_plant/shoot
	name = "small pottable shoot"
	desc = "This is a tiny shoot. It still needs time to grow."
	icon_state = "plant-13"
	base_name = "small shoot"

/obj/item/plant_pot/shoot
	icon_state = "13"
	startplant = /obj/item/reagent_containers/food/pottable_plant/shoot

/obj/item/reagent_containers/food/pottable_plant/orchid
	name = "sweet pottable orchid"
	desc = "An orchid plant, as beautiful as it is delicate. Sweet smelling flower is supported by spindly stems."
	icon_state = "plant-14"
	base_name = "sweet orchid"

/obj/item/plant_pot/orchid
	icon_state = "14"
	startplant = /obj/item/reagent_containers/food/pottable_plant/orchid

/obj/item/reagent_containers/food/pottable_plant/crystal
	name = "crystalline pottable plant"
	desc = "A ropey, aquatic plant. Odd crystal formations grow on the end."
	icon_state = "plant-15"
	base_name = "crystalline plant"

/obj/item/plant_pot/crystal
	icon_state = "15"
	startplant = /obj/item/reagent_containers/food/pottable_plant/crystal

/obj/item/reagent_containers/food/pottable_plant/subterranean
	name = "subterranean pottable plant-fungus"
	desc = "A bioluminescent subterranean half-plant half-fungus hybrid, its bulbous ends glow faintly. Said to come from Sedantis I."
	icon_state = "plant-16"
	base_name = "subterranean plant-fungus"

/obj/item/plant_pot/subterranean
	icon_state = "16"
	startplant = /obj/item/reagent_containers/food/pottable_plant/subterranean

/obj/item/reagent_containers/food/pottable_plant/stoutbush
	name = "stout pottable bush"
	desc = "This is a miniature stout bush. Its leaves point up and outwards."
	icon_state = "plant-17"
	base_name = "stout bush"

/obj/item/plant_pot/stoutbush
	icon_state = "17"
	startplant = /obj/item/reagent_containers/food/pottable_plant/stoutbush

/obj/item/reagent_containers/food/pottable_plant/drooping
	name = "drooping pottable plant"
	desc = "This is a tiny plant. It has just one drooping leaf, making it look like it's wilted."
	icon_state = "plant-18"
	base_name = "drooping plant"

/obj/item/plant_pot/drooping
	icon_state = "18"
	startplant = /obj/item/reagent_containers/food/pottable_plant/drooping

/obj/item/reagent_containers/food/pottable_plant/tropical
	name = "tropical pottable plant"
	desc = "This is some kind of tropical plant. It is very young, and hasn't begun to flower yet."
	icon_state = "plant-19"
	base_name = "tropical plant"

/obj/item/plant_pot/tropical
	icon_state = "19"
	startplant = /obj/item/reagent_containers/food/pottable_plant/tropical

/obj/item/reagent_containers/food/pottable_plant/flower
	name = "pottable flower"
	desc = "A small potted flower. It appears to be healthy and growing strong."
	icon_state = "plant-20"
	base_name = "flower"

/obj/item/plant_pot/flower
	icon_state = "20"
	startplant = /obj/item/reagent_containers/food/pottable_plant/flower

/obj/item/reagent_containers/food/pottable_plant/bulrush
	name = "small pottable grass"
	desc = "A bulrush, wetland grass-like plant. This one is tiny, and does not have any flowers."
	icon_state = "plant-21"
	base_name = "small grass"

/obj/item/plant_pot/bulrush
	icon_state = "21"
	startplant = /obj/item/reagent_containers/food/pottable_plant/bulrush

/obj/item/reagent_containers/food/pottable_plant/rose
	name = "thorny pottable rose"
	desc = "A flowering rose. It has sharp thorns on its stems."
	icon_state = "plant-22"
	base_name = "thorny rose"

/obj/item/plant_pot/rose
	icon_state = "22"
	startplant = /obj/item/reagent_containers/food/pottable_plant/rose

/obj/item/reagent_containers/food/pottable_plant/whitetulip
	name = "pottable tulip"
	desc = "A potted plant, with one large white flower bud."
	icon_state = "plant-23"
	base_name = "tulip"

/obj/item/plant_pot/whitetulip
	icon_state = "23"
	startplant = /obj/item/reagent_containers/food/pottable_plant/whitetulip

/obj/item/reagent_containers/food/pottable_plant/woodyshrub
	name = "woody pottable shrub"
	desc = "A woody shrub."
	icon_state = "plant-24"
	base_name = "woody shrub"

/obj/item/plant_pot/woodyshrub
	icon_state = "24"
	startplant = /obj/item/reagent_containers/food/pottable_plant/woodyshrub

/obj/item/reagent_containers/food/pottable_plant/woodyshrubdying
	name = "dying woody pottable shrub"
	desc = "A woody shrub. Seems to be in need of watering."
	icon_state = "plant-25"
	base_name = "dying woody shrub"

/obj/item/plant_pot/woodyshrubdying
	icon_state = "25"
	startplant = /obj/item/reagent_containers/food/pottable_plant/woodyshrubdying

/obj/item/reagent_containers/food/pottable_plant/woodyshrubbloom
	name = "blooming woody pottable shrub"
	desc = "A woody shrub. This one seems to be in bloom."
	icon_state = "plant-26"
	base_name = "blooming woody shrub"

/obj/item/plant_pot/woodyshrubbloom
	icon_state = "26"
	startplant = /obj/item/reagent_containers/food/pottable_plant/woodyshrubbloom

/obj/item/reagent_containers/food/pottable_plant/bluefern
	name = "blueish pottable fern"
	desc = "A miniature fern, with one big dark blue leaf."
	icon_state = "plant-27"
	base_name = "blueish fern"

/obj/item/plant_pot/bluefern
	icon_state = "27"
	startplant = /obj/item/reagent_containers/food/pottable_plant/bluefern

// Gacha
/obj/item/pottable_plant_gacha
	name = "Mysterious Potty pack"
	desc = "Find the potted plant of your dreams! You'll most probably find the one you want in the 27th pack you open."
	icon = 'icons/obj/flora/plant_pots.dmi'
	icon_state = "gacha"
	w_class = ITEM_SIZE_SMALL

/obj/item/pottable_plant_gacha/attack_self(mob/user)
	var/prize_type = pick(subtypesof(/obj/item/reagent_containers/food/pottable_plant))
	var/obj/item/reagent_containers/food/pottable_plant/prize = new prize_type(get_turf(src))
	to_chat(user, SPAN("notice", "You unwrap \the [src]... There's \an [prize] inside!"))
	playsound(user.loc, 'sound/items/shpshpsh.ogg', 50, 1)
	qdel(src)
	user.pick_or_drop(prize)
