/obj/item/material/sword/blazing
	name = "blazing blade"
	damtype = "fire"
	icon_state = "fireblade"
	item_state = "fireblade"
	default_material = MATERIAL_CULT
	var/charges = 0
	var/mob/living/deity/linked_deity

/obj/item/material/sword/blazing/Initialize()
	. = ..()
	charges = rand(20, 30)

/obj/item/material/sword/blazing/apply_hit_effect(mob/living/target, mob/living/user, hit_zone)
	. = ..()

	charges = min(0, charges--)

	if(charges == 0)
		visible_message(SPAN_WARNING("\the [src] disintegrates into a pile of ash!"))
		new /obj/effect/decal/cleanable/ash(get_turf(src))
		qdel_self()
	else
		visible_message(SPAN_WARNING("\the [src] begins to fade, its power dimming!"))

/obj/item/material/knife/ritual/shadow
	name = "black death"
	desc = "An obsidian dagger. The singed remains of a green cloth are wrapped around the 'handle.'"
	var/charge = 5
	default_material = MATERIAL_CULT

/obj/item/material/knife/ritual/shadow/apply_hit_effect(mob/living/target, mob/living/user, hit_zone)
	. = ..()

	if(charge && target.getBruteLoss() > 10)
		target.reagents.add_reagent(/datum/reagent/acid/polyacid, 5)
		new /obj/effect/temporary(get_turf(target), 3, 'icons/effects/effects.dmi', "fire_goon")
		charge--
	else
		user.adjustFireLoss(5)
		if(prob(50))
			to_chat(user, SPAN_WARNING("\The [src] appears to be out of power!"))
		new /obj/effect/temporary(get_turf(user),3, 'icons/effects/effects.dmi', "fire_goon")

/obj/item/gun/energy/staff/beacon
	name = "holy beacon"
	desc = "There's a miniature sun. Or maybe that's just some fancy LEDs."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "starstaff"
	max_shots = 10
	projectile_type = /obj/item/projectile/energy/flash

/obj/item/clothing/ring/aura_ring
	var/obj/aura/granted_aura

/obj/item/clothing/ring/aura_ring/equipped(mob/living/L, slot)
	. = ..()

	if(granted_aura && slot == slot_gloves)
		L.add_aura(granted_aura)

/obj/item/clothing/ring/aura_ring/dropped(mob/living/L)
	. = ..()

	if(granted_aura)
		L.remove_aura(granted_aura)

/obj/item/clothing/ring/aura_ring/Destroy()
	QDEL_NULL(granted_aura)
	return ..()

/obj/aura/starborn
	name = "starborn's gift"
	icon = 'icons/effects/effects.dmi'
	icon_state = "white_electricity_constant"
	color = "#33cc33"
	layer = MOB_LAYER

/obj/aura/starborn/bullet_act(obj/item/projectile/P, def_zone)
	if(P.damage_type == "BURN")
		user.visible_message(SPAN_WARNING("\The [P] seems to only make \the [user] stronger."))
		user.adjustBruteLoss(-P.damage)
		return AURA_FALSE

	return EMPTY_BITFIELD

/obj/aura/starborn/attackby(obj/item/I, mob/living/user)
	if(I.damtype == "BURN")
		user.visible_message(SPAN_WARNING("\The [I] seems to only feed into \the [user]'s flames."))
		user.adjustBruteLoss(-I.force)
		return AURA_FALSE

	return EMPTY_BITFIELD

/obj/aura/blueforge_aura
	name = "Blueforge Aura"
	//icon = 'icons/mob/human_races/species/eyes.dmi'
	//icon_state = "eyes_blueforged_s"
	layer = MOB_LAYER

/obj/aura/blueforge_aura/life_tick()
	user.adjustToxLoss(-10)
	return EMPTY_BITFIELD

/obj/aura/blueforge_aura/bullet_act(obj/item/projectile/P, def_zone)
	if(P.damage_type == "BURN")
		P.damage *= 2

	else if (P.agony || P.stun)
		return AURA_FALSE

	return EMPTY_BITFIELD

/obj/aura/shadowling_aura
	name = "Shadowling Aura"
	var/added_mutation = FALSE

/obj/aura/shadowling_aura/New(mob/living/target)
	. = ..()
	if(!(MUTATION_SPACERES in target.mutations))
		target.mutations.Add(MUTATION_SPACERES)
		added_mutation = TRUE

/obj/aura/shadowling_aura/Destroy()
	if(added_mutation)
		added_mutation = FALSE
		user.mutations.Remove(MUTATION_SPACERES)
	return ..()

/obj/aura/shadowling_aura/bullet_act(obj/item/projectile/P, def_zone)
	if(P.check_armour == "laser" || P.damage_type == "BURN")
		P.damage *= 2

	return EMPTY_BITFIELD

/obj/item/clothing/ring/aura_ring/talisman_of_starborn
	name = "Talisman of the Starborn"
	desc = "This ring seems to shine with more light than is put on it."
	icon_state = "starring"

/obj/item/clothing/ring/aura_ring/talisman_of_starborn/Initialize()
	. = ..()
	granted_aura = new /obj/aura/starborn()

/obj/item/clothing/ring/aura_ring/talisman_of_blueforged
	name = "Talisman of the Blueforged"
	desc = "The gem on this ring is quite peculiar..."
	icon_state = "bluering"

/obj/item/clothing/ring/aura_ring/talisman_of_blueforged/Initialize()
	. = ..()
	granted_aura = new /obj/aura/blueforge_aura()

/obj/item/clothing/ring/aura_ring/talisman_of_shadowling
	name = "Talisman of the Shadowling"
	desc = "If you weren't looking at this, you probably wouldn't have noticed it."
	icon_state = "shadowring"

/obj/item/clothing/ring/aura_ring/talisman_of_shadowling/Initialize()
	. = ..()
	granted_aura = new /obj/aura/shadowling_aura()

/obj/item/clothing/suit/armor/sunsuit
	name = "knight's armor"
	desc = "Now, you can be the knight in shining armor you've always wanted to be. With complementary sun insignia."
	icon_state = "star_champion"
	armor = list(melee = 35, bullet = 30, laser = 25, energy = 45, bomb = 25, bio = 10)
	body_parts_covered = UPPER_TORSO | LOWER_TORSO | ARMS | HANDS | LEGS

/obj/item/clothing/head/helmet/sunhelm
	name = "knight's helm"
	desc = "It's a shiny metal helmet. It looks ripped straight out of the Dark Ages, actually."
	icon_state = "star_champion"
	flags_inv = HIDEEARS | BLOCKHAIR
	armor = list(melee = 35, bullet = 30, laser = 25, energy = 45, bomb = 25, bio = 10)

/obj/item/clothing/suit/armor/sunrobe
	name = "oracle's robe"
	desc = "The robes of a priest. One that praises the sun, apparently. Well, it certainly reflects light well."
	icon_state = "star_oracle"
	armor = list(melee = 35, bullet = 30, laser = 25, energy = 45, bomb = 25, bio = 10)
	body_parts_covered = UPPER_TORSO | LOWER_TORSO

/obj/item/clothing/suit/armor/sunrobe/Initialize()
	. = ..()
	set_light(0.3, 0.1, 4, 2)

/obj/item/clothing/suit/space/shadowsuit
	name = "traitor's cloak"
	desc = "There is absolutely nothing visible through the fabric. The shadows stick to your skin when you touch it."
	item_flags = ITEM_FLAG_THICKMATERIAL | ITEM_FLAG_AIRTIGHT
	icon_state = "star_traitor"

/obj/item/clothing/head/helmet/space/shadowhood
	name = "traitor's hood"
	desc = "No light can pierce this hood. It's unsettling."
	icon_state = "star_traitor"
	flags_inv = HIDEEARS | BLOCKHAIR
