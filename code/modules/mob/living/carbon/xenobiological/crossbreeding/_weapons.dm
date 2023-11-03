//Rainbow knife - Burning Rainbow
/obj/item/material/hatchet/tacknife/rainbowknife
	name = "rainbow knife"
	desc = "A strange, transparent knife which constantly shifts color. It hums slightly when moved."
	icon = 'icons/obj/xenobiology/metroidcrossing.dmi'
	icon_state = "rainbowknife"
	item_state = "rainbowknife"

/obj/item/material/hatchet/tacknife/rainbowknife/resolve_attackby(atom/A, mob/user, click_params)
	damtype = pick(BRUTE, BURN, TOX, OXY, CLONE)
	switch(damtype)
		if(BRUTE)
			hitsound = 'sound/weapons/bladeslice.ogg'
			attack_verb = list("slashed", "sliced", "cut")
		if(BURN)
			hitsound = 'sound/weapons/sear.ogg'
			attack_verb = list("burns", "singes", "heats")
		if(TOX)
			hitsound = 'sound/effects/pierce.ogg'
			attack_verb = list("poisons", "doses", "toxifies")
		if(OXY)
			hitsound = 'sound/effects/space_wind.ogg'
			attack_verb = list("suffocates", "winds", "vacuums")
		if(CLONE)
			hitsound = 'sound/effects/geiger/geiger_very_high_1.ogg'
			attack_verb = list("irradiates", "mutates", "maligns")
	return ..()

//Adamantine shield - Chilling Adamantine
/obj/item/shield/adamantineshield
	name = "adamantine shield"
	desc = "A gigantic shield made of solid adamantium."
	icon = 'icons/obj/xenobiology/metroidcrossing.dmi'
	icon_state = "adamshield"
	w_class = ITEM_SIZE_HUGE
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 0, BOMB = 30, BIO = 0, FIRE = 80, ACID = 70)
	slot_flags = SLOT_BACK
	mod_weight = 2.0
	mod_reach = 1.5
	mod_handy = 1.5
	mod_shield = 2.0
	block_tier = BLOCK_TIER_PROJECTILE
	force = 15.0
	throw_range = 1 //How far do you think you're gonna throw a solid crystalline shield...?
	throw_speed = 2
	attack_verb = list("bashes", "pounds", "slams")

/obj/item/shield/adamantineshield/Initialize(mapload)
	. = ..()
