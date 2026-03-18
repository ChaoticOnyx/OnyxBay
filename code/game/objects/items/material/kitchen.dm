/obj/item/material/kitchen
	icon = 'icons/obj/kitchen.dmi'

/*
 * Utensils
 */
/obj/item/material/kitchen/utensil
	w_class = ITEM_SIZE_TINY
	mod_weight = 0.25
	mod_reach = 0.3
	mod_handy = 0.7
	thrown_force_divisor = 1
	origin_tech = list(TECH_MATERIAL = 1)
	attack_verb = list("attacked", "stabbed", "poked")
	sharp = 0
	edge = 0
	force_const = 3
	thrown_force_const = 3
	force_divisor = 0.05 // 3 when wielded with hardness 60 (steel)
	thrown_force_divisor = 0.25 // 5 when thrown with weight 20 (steel)
	material_amount = 1
	var/scoop_food = 1
	var/obj/item/reagent_containers/food/forked_chunk/forked_chunk = null

/obj/item/material/kitchen/utensil/Initialize()
	. = ..()
	if(prob(60))
		src.pixel_y = rand(0, 4)

/obj/item/material/kitchen/utensil/Destroy()
	QDEL_NULL(forked_chunk)
	return ..()

/obj/item/material/kitchen/utensil/on_update_icon()
	ClearOverlays()
	if(!forked_chunk)
		return
	var/image/I = image(icon, "loadedfood")
	I.color = forked_chunk.color
	I.appearance_flags |= RESET_COLOR
	AddOverlays(I)

/obj/item/material/kitchen/utensil/attack_self(mob/user)
	if(!forked_chunk)
		return
	to_chat(user, SPAN("notice", "You drop \the [forked_chunk] from \the [src]."))
	forked_chunk.forceMove(get_turf(src))
	forked_chunk = null
	update_icon()

/obj/item/material/kitchen/utensil/attack(mob/living/carbon/M, mob/living/carbon/user, def_zone)
	if(!istype(M))
		return ..()

	if(user.a_intent != I_HELP)
		if(is_pacifist(user))
			to_chat(user, SPAN("warning", "You can't you're pacifist!"))
			return

		if(user.zone_sel.selecting == BP_EYES)
			if(istype(user.l_hand,/obj/item/grab) || istype(user.r_hand,/obj/item/grab))
				return ..()
			if((MUTATION_CLUMSY in user.mutations) && prob(50))
				M = user
			return eyestab(M,user)
		else
			return ..()

	if(forked_chunk)
		. = forked_chunk.attack(M, user, def_zone)
		if(QDELETED(forked_chunk))
			forked_chunk = null
		update_icon()
		return
	else
		to_chat(user, SPAN("notice", "You don't have anything on \the [src].")) // if we have help intent and no food scooped up DON'T STAB OURSELVES WITH THE FORK
		return

/obj/item/material/kitchen/utensil/examine(mob/user, infix)
	. = ..()

	if(!forked_chunk)
		return

	if(get_dist(src, user) > 1)
		return

	. += " There is a [forked_chunk.name] on it."
	return

/obj/item/material/kitchen/utensil/fork
	name = "fork"
	desc = "It's a fork. Sure is pointy."
	icon_state = "fork"
	sharp = 1

/obj/item/material/kitchen/utensil/fork/plastic
	default_material = MATERIAL_PLASTIC

/obj/item/material/kitchen/utensil/spoon
	name = "spoon"
	desc = "It's a spoon. You can see your own upside-down face in it. Looks like an extremely inefficient weapon"
	icon_state = "spoon"
	attack_verb = list("attacked", "poked")
	hitsound = SFX_FIGHTING_SWING
	sharp = 0
	force_divisor = 0.1 //2 when wielded with weight 20 (steel)
	mod_weight = 0.3

/obj/item/material/kitchen/utensil/spoon/plastic
	default_material = MATERIAL_PLASTIC

/*
 * Knives
 */
/obj/item/material/kitchen/utensil/knife
	name = "table knife"
	desc = "A knife for eating with. Can cut through any food."
	icon_state = "tableknife"
	item_state = "knife"
	force_const = 3.0
	force_divisor = 0.05 // 3 when wielded with hardness 60 (steel)
	scoop_food = 0
	sharp = 1
	edge = 1

/obj/item/material/kitchen/utensil/knife/attack(mob/living/M, mob/living/user)
	if(is_pacifist(user))
		to_chat(user, SPAN("warning", "You can't you're pacifist!"))
		return

	if((MUTATION_CLUMSY in user.mutations) && prob(50))
		to_chat(user, SPAN("warning", "You accidentally cut yourself with \the [src]."))
		user.take_organ_damage(20)
		return
	return ..()

/obj/item/material/kitchen/utensil/knife/plastic
	default_material = MATERIAL_PLASTIC

// Identical to the tactical knife but nowhere near as stabby.
// Kind of like the toy esword compared to the real thing.
//Making the sprite clear that this is a small knife
/obj/item/material/kitchen/utensil/knife/boot
	name = "small knife"
	desc = "A small, easily concealed knife."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "pocketknife_open"
	item_state = "knife"
	applies_material_colour = 0
	unbreakable = 1
	force_const = 4.5
	mod_weight = 0.3
	mod_reach = 0.33
	mod_handy = 0.75

/obj/item/material/kitchen/utensil/knife/unathiknife
	name = "dueling knife"
	desc = "A length of leather-bound wood studded with razor-sharp teeth. How crude."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "unathiknife"
	item_state = "knife"
	attack_verb = list("ripped", "torn", "cut")
	applies_material_colour = 0
	unbreakable = 1
	force_const = 6.0
	mod_weight = 0.4
	mod_reach = 0.5
	mod_handy = 1.0

/*
 * Rolling Pins
 */

/obj/item/material/kitchen/rollingpin
	name = "rolling pin"
	desc = "Used to knock out the Bartender."
	icon_state = "rolling_pin"
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")
	default_material = MATERIAL_WOOD
	force_divisor = 0.7 // 10 when wielded with weight 15 (wood)
	thrown_force_divisor = 0.8 // 12 dmg (wood)
	hitsound = SFX_FIGHTING_SWING
	mod_weight = 1.2
	mod_reach = 0.85
	mod_handy = 0.9
	material_amount = 3

/obj/item/material/kitchen/rollingpin/attack(mob/living/M as mob, mob/living/user as mob)
	if(is_pacifist(user))
		to_chat(user, SPAN("warning", "You can't you're pacifist!"))
		return

	if((MUTATION_CLUMSY in user.mutations) && prob(50))
		to_chat(user, "<span class='warning'>\The [src] slips out of your hand and hits your head.</span>")
		user.drop(src, force = TRUE)
		user.take_organ_damage(10)
		user.Paralyse(2)
		return
	return ..()
