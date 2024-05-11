//*****************
//**Cham Jumpsuit**
//*****************
/obj/item/proc/check_job(obj/item/card/id/W, mob/user, element)
	var/datum/job/job = job_master.GetJob(W.rank)
	var/decl/hierarchy/outfit/outfit = job.get_outfit(user, job)
	switch (element)
		if(slot_w_uniform_str)
			outfit.uniform ? disguise(outfit.uniform, user) : to_chat(user, "No standard uniform for [W.assignment]")
		if(slot_wear_suit_str)
			outfit.suit ? disguise(outfit.suit, user) : to_chat(user, "No standard suit for [W.assignment]")
		if(slot_gloves_str)
			outfit.gloves ? disguise(outfit.gloves, user) : to_chat(user, "No standard gloves for [W.assignment]")
		if(slot_shoes_str)
			outfit.shoes ? disguise(outfit.shoes, user) : to_chat(user, "No standard shoes for [W.assignment]")
		if(slot_wear_mask_str)
			outfit.mask ? disguise(outfit.mask, user) : to_chat(user, "No standard mask for [W.assignment]")
		if(slot_head_str)
			outfit.head ? disguise(outfit.head, user) : to_chat(user, "No standard hat for [W.assignment]")
		if(slot_glasses_str)
			outfit.glasses ? disguise(outfit.glasses, user) : to_chat(user, "No standard glasses for [W.assignment]")
	user.regenerate_icons()

/obj/item/proc/disguise(newtype, mob/user)
	if(!user || user.incapacitated())
		return
	//this is necessary, unfortunately, as initial() does not play well with list vars
	var/obj/item/copy = new newtype(null) //so that it is GCed once we exit

	desc = copy.desc
	name = copy.name
	icon_state = copy.icon_state
	item_state = copy.item_state
	body_parts_covered = copy.body_parts_covered
	flags_inv = copy.flags_inv

	if(copy.item_icons)
		item_icons = copy.item_icons.Copy()
	if(copy.item_state_slots)
		item_state_slots = copy.item_state_slots.Copy()

	return copy //for inheritance

/proc/generate_chameleon_choices(basetype, blacklist = list(), blacklist_cat = list())
	. = list()

	for(var/blacklisted_category in blacklist_cat)
		blacklist |= typesof(blacklisted_category)

	var/i = 1 //in case there is a collision with both name AND icon_state
	for(var/typepath in typesof(basetype) - blacklist)
		var/obj/O = typepath
		if(initial(O.icon) && initial(O.icon_state))
			var/name = initial(O.name)
			if(name in .)
				name += " ([initial(O.icon_state)])"
			if(name in .)
				name += " \[[i++]\]"
			.[name] = typepath

/obj/item/clothing/under/chameleon/attackby(obj/item/card/id/W, mob/user)
	if(!istype(W, /obj/item/card/id))
		return
	check_job(W, user, slot_w_uniform_str)

/obj/item/clothing/under/chameleon
//starts off as black
	name = "black jumpsuit"
	icon_state = "black"
	item_state = "bl_suit"
	worn_state = "black"
	desc = "It's a plain jumpsuit. It seems to have a small dial on the wrist."
	origin_tech = list(TECH_ILLEGAL = 3)
	var/global/list/clothing_choices

/obj/item/clothing/under/chameleon/New()
	..()
	if(!clothing_choices)
		var/blocked = list( //Prevent infinite loops and bad jumpsuits.
			type,
			/obj/item/clothing/under/rank,
			/obj/item/clothing/under/pj,
			/obj/item/clothing/under/stripper,
			/obj/item/clothing/under/swimsuit,
			/obj/item/clothing/under/wedding
		)
		var/blocked_cat = list(
			/obj/item/clothing/under/monkey,
			/obj/item/clothing/under/gimmick,
			/obj/item/clothing/under/vox
		)
		clothing_choices = generate_chameleon_choices(/obj/item/clothing/under, blocked, blocked_cat)

/obj/item/clothing/under/chameleon/emp_act(severity)
	name = "psychedelic"
	desc = "Groovy!"
	icon_state = "psyche"
	item_state_slots[slot_w_uniform_str] = "psyche"
	update_icon()
	update_clothing_icon()

/obj/item/clothing/under/chameleon/verb/change(picked in clothing_choices)
	set name = "Change Jumpsuit Appearance"
	set category = "Chameleon Items"
	set src in usr
	if(!ispath(clothing_choices[picked]))
		return

	disguise(clothing_choices[picked], usr)
	update_clothing_icon()	//so our overlays update.

//*****************
//**Chameleon Hat**
//*****************
/obj/item/clothing/head/chameleon/attackby(obj/item/card/id/W, mob/user)
	if(!istype(W, /obj/item/card/id))
		return
	check_job(W, user, slot_head_str)

/obj/item/clothing/head/chameleon
	name = "grey cap"
	icon_state = "greysoft"
	desc = "It looks like a plain hat, but upon closer inspection, there's an advanced holographic array installed inside. It seems to have a small dial inside."
	origin_tech = list(TECH_ILLEGAL = 3)
	body_parts_covered = NO_BODYPARTS
	var/global/list/clothing_choices

/obj/item/clothing/head/chameleon/New()
	..()
	if(!clothing_choices)
		var/blocked = list( // Prevent infinite loops and bad hats.
			type,
			/obj/item/clothing/head/goatcapehood,
			/obj/item/clothing/head/hoodiehood,
			/obj/item/clothing/head/winterhood,
			/obj/item/clothing/head/collectable,
			/obj/item/clothing/head/helmet/space/skrell,
			/obj/item/clothing/head/helmet/space/vox
		)
		var/blocked_cat = list(
			/obj/item/clothing/head/lightrig,
			/obj/item/clothing/head/helmet/space/rig
		)
		clothing_choices = generate_chameleon_choices(/obj/item/clothing/head, blocked, blocked_cat)

/obj/item/clothing/head/chameleon/emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
	SetName(initial(name))
	desc = initial(desc)
	icon_state = initial(icon_state)
	update_icon()
	update_clothing_icon()

/obj/item/clothing/head/chameleon/verb/change(picked in clothing_choices)
	set name = "Change Hat/Helmet Appearance"
	set category = "Chameleon Items"
	set src in usr

	if(!ispath(clothing_choices[picked]))
		return

	disguise(clothing_choices[picked], usr)
	update_clothing_icon()	//so our overlays update.

//******************
//**Chameleon Suit**
//******************
/obj/item/clothing/suit/chameleon/attackby(obj/item/card/id/W, mob/user)
	if(!istype(W, /obj/item/card/id))
		return
	check_job(W, user, slot_wear_suit_str)

/obj/item/clothing/suit/chameleon
	name = "armor"
	icon_state = "armor"
	item_state = "armor"
	desc = "It appears to be a vest of standard armor, except this is embedded with a hidden holographic cloaker, allowing it to change it's appearance, but offering no protection.. It seems to have a small dial inside."
	origin_tech = list(TECH_ILLEGAL = 3)
	var/global/list/clothing_choices

/obj/item/clothing/suit/chameleon/New()
	..()
	if(!clothing_choices)
		var/blocked = list( // Prevent infinite loops and bad hats.
			type,
			/obj/item/clothing/suit/armor,
			/obj/item/clothing/suit/armor/tdome,
			/obj/item/clothing/suit/greatcoat,
			/obj/item/clothing/suit/unathi,
			/obj/item/clothing/suit/tajaran,
			/obj/item/clothing/suit/poncho,
			/obj/item/clothing/suit/poncho/roles,
			/obj/item/clothing/suit/security,
			/obj/item/clothing/suit/stripper,
			/obj/item/clothing/suit/storage,
			/obj/item/clothing/suit/storage/hooded,
			/obj/item/clothing/suit/storage/toggle,
			/obj/item/clothing/suit/storage/toggle/forensics,
			/obj/item/clothing/suit/storage/vest,
			/obj/item/clothing/suit/space/skrell,
			/obj/item/clothing/suit/space/vox,
		)
		var/blocked_cat = list(
			/obj/item/clothing/suit/space/rig,
			/obj/item/clothing/suit/lightrig
		)
		clothing_choices = generate_chameleon_choices(/obj/item/clothing/suit, blocked, blocked_cat)

/obj/item/clothing/suit/chameleon/emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
	SetName(initial(name))
	desc = initial(desc)
	icon_state = initial(icon_state)
	update_icon()
	update_clothing_icon()

/obj/item/clothing/suit/chameleon/verb/change(picked in clothing_choices)
	set name = "Change Oversuit Appearance"
	set category = "Chameleon Items"
	set src in usr

	if(!ispath(clothing_choices[picked]))
		return

	disguise(clothing_choices[picked], usr)
	update_clothing_icon()	//so our overlays update.

//*******************
//**Chameleon Shoes**
//*******************
/obj/item/clothing/shoes/chameleon/attackby(obj/item/card/id/W, mob/user)
	if(!istype(W, /obj/item/card/id))
		return
	check_job(W, user, slot_shoes_str)

/obj/item/clothing/shoes/chameleon
	name = "black shoes"
	icon_state = "black"
	item_state = "black"
	desc = "They're comfy black shoes, with clever cloaking technology built in. It seems to have a small dial on the back of each shoe."
	origin_tech = list(TECH_ILLEGAL = 3)
	var/global/list/clothing_choices

/obj/item/clothing/shoes/chameleon/New()
	..()
	if(!clothing_choices)
		var/blocked = list( // Prevent infinite loops and bad hats.
			type,
			/obj/item/clothing/shoes/syndigaloshes,
			/obj/item/clothing/shoes/cyborg,
			/obj/item/clothing/shoes/black/bluespace_tech
		)
		var/blocked_cat = list(
			/obj/item/clothing/shoes/lightrig,
			/obj/item/clothing/shoes/magboots/rig
		)
		clothing_choices = generate_chameleon_choices(/obj/item/clothing/shoes, blocked, blocked_cat)

/obj/item/clothing/shoes/chameleon/emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
	SetName(initial(name))
	desc = initial(desc)
	icon_state = initial(icon_state)
	item_state = initial(item_state)
	update_icon()
	update_clothing_icon()

/obj/item/clothing/shoes/chameleon/verb/change(picked in clothing_choices)
	set name = "Change Footwear Appearance"
	set category = "Chameleon Items"
	set src in usr

	if(!ispath(clothing_choices[picked]))
		return

	disguise(clothing_choices[picked], usr)
	update_clothing_icon()	//so our overlays update.

//**********************
//**Chameleon Backpack**
//**********************
/obj/item/storage/backpack/chameleon
	name = "backpack"
	icon_state = "backpack"
	item_state = "backpack"
	inspect_state = FALSE // TODO: Ughhh make it work or something, chameleon clothes are pain in the ass tbh
	desc = "A backpack outfitted with cloaking tech. It seems to have a small dial inside, kept away from the storage."
	origin_tech = list(TECH_ILLEGAL = 3)
	var/global/list/clothing_choices

/obj/item/storage/backpack/chameleon/New()
	..()
	if(!clothing_choices)
		var/blocked = list( // Prevent infinite loops and bad hats.
			type,
			/obj/item/storage/backpack/chameleon/sydie_kit,
			/obj/item/storage/backpack/satchel/grey/withwallet,
			/obj/item/storage/backpack/santabag,
			/obj/item/storage/backpack/holding/bluespace_tech
		)
		var/blocked_cat = list(
			/obj/item/storage/backpack/dufflebag/syndie_kit,
			/obj/item/storage/backpack/satchel/syndie_kit
		)
		clothing_choices = generate_chameleon_choices(/obj/item/storage/backpack, blocked, blocked_cat)

/obj/item/storage/backpack/chameleon/emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
	SetName(initial(name))
	desc = initial(desc)
	icon_state = initial(icon_state)
	item_state = initial(item_state)
	update_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_back()

/obj/item/storage/backpack/chameleon/verb/change(picked in clothing_choices)
	set name = "Change Backpack Appearance"
	set category = "Chameleon Items"
	set src in usr

	if(!ispath(clothing_choices[picked]))
		return

	disguise(clothing_choices[picked], usr)

	//so our overlays update.
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_back()

//********************
//**Chameleon Gloves**
//********************
/obj/item/clothing/gloves/chameleon/attackby(obj/item/card/id/W, mob/user)
	if(isWirecutter(W) || istype(W, /obj/item/scalpel) || isCoil(W))
		to_chat(user, SPAN("notice", "That won't work.")) // Making it obvious
		return
	if(!istype(W, /obj/item/card/id))
		return
	check_job(W, user, slot_gloves_str)

/obj/item/clothing/gloves/chameleon
	name = "black gloves"
	icon_state = "black"
	item_state = "bgloves"
	desc = "It looks like a pair of gloves, but it seems to have a small dial inside."
	origin_tech = list(TECH_ILLEGAL = 3)
	var/global/list/clothing_choices

/obj/item/clothing/gloves/chameleon/New()
	..()
	if(!clothing_choices)
		var/blocked = list( // Prevent infinite loops and bad hats.
			type,
			/obj/item/clothing/gloves/chameleon/robust,
			/obj/item/clothing/gloves/color/white/bluespace_tech,
			/obj/item/clothing/gloves/color/white/modified,
			/obj/item/clothing/gloves/color/modified,
			/obj/item/clothing/gloves/duty/modified,
			/obj/item/clothing/gloves/latex/modified,
			/obj/item/clothing/gloves/latex/nitrile/modified,
			/obj/item/clothing/gloves/rainbow/modified,
			/obj/item/clothing/gloves/thick/botany/modified,
			/obj/item/clothing/gloves/vox,
			/obj/item/clothing/gloves/stun
		)
		var/blocked_cat = list(
			/obj/item/clothing/gloves/lightrig,
			/obj/item/clothing/gloves/rig
		)
		clothing_choices = generate_chameleon_choices(/obj/item/clothing/gloves, blocked, blocked_cat)

/obj/item/clothing/gloves/chameleon/emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
	SetName(initial(name))
	desc = initial(desc)
	icon_state = initial(icon_state)
	item_state = initial(item_state)
	update_icon()
	update_clothing_icon()

/obj/item/clothing/gloves/chameleon/verb/change(picked in clothing_choices)
	set name = "Change Gloves Appearance"
	set category = "Chameleon Items"
	set src in usr

	if(!ispath(clothing_choices[picked]))
		return

	disguise(clothing_choices[picked], usr)
	update_clothing_icon()	//so our overlays update.

/obj/item/clothing/gloves/chameleon/robust
	desc = "It looks like a pair of extra robust gloves. It seems to have a small dial inside."
	unarmed_damage_override = 10
	origin_tech = list(TECH_ILLEGAL = 5)

/obj/item/clothing/gloves/chameleon/robust/examine(mob/user, infix)
	. = ..()
	. += "These look extra robust."

//******************
//**Chameleon Mask**
//******************
/obj/item/clothing/mask/chameleon/attackby(obj/item/card/id/W, mob/user)
	if(!istype(W, /obj/item/card/id))
		return
	check_job(W, user, slot_wear_mask_str)

/obj/item/clothing/mask/chameleon
	name = "gas mask"
	icon_state = "fullgas"
	item_state = "gas_mask"
	desc = "It looks like a plain gask mask, but on closer inspection, it seems to have a small dial inside."
	origin_tech = list(TECH_ILLEGAL = 3)
	var/global/list/clothing_choices
	rad_resist_type = /datum/rad_resist/mask_chameleon

/datum/rad_resist/mask_chameleon
	alpha_particle_resist = 23 MEGA ELECTRONVOLT
	beta_particle_resist = 6.6 MEGA ELECTRONVOLT
	hawking_resist = 1 ELECTRONVOLT

/obj/item/clothing/mask/chameleon/New()
	..()
	if(!clothing_choices)
		var/blocked = list( // Prevent infinite loops and bad hats.
			type,
			/obj/item/clothing/mask/animal_mask,
			/obj/item/clothing/mask/gas/vox,
			/obj/item/clothing/mask/gas/poltergeist,
			/obj/item/clothing/mask/smokable,
			/obj/item/clothing/mask/smokable/cigarette/syndi_cigs,
			/obj/item/clothing/mask/smokable/ecig
		)
		var/blocked_cat = list(
			/obj/item/clothing/mask/chameleon
		)
		clothing_choices = generate_chameleon_choices(/obj/item/clothing/mask, blocked, blocked_cat)

/obj/item/clothing/mask/chameleon/emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
	SetName(initial(name))
	desc = initial(desc)
	icon_state = initial(icon_state)
	item_state = initial(item_state)
	update_icon()
	update_clothing_icon()

/obj/item/clothing/mask/chameleon/verb/change(picked in clothing_choices)
	set name = "Change Mask Appearance"
	set category = "Chameleon Items"
	set src in usr

	if(!ispath(clothing_choices[picked]))
		return

	disguise(clothing_choices[picked], usr)
	update_clothing_icon()	//so our overlays update.

//*********************
//**Chameleon Glasses**
//*********************
/obj/item/clothing/glasses/chameleon/attackby(obj/item/card/id/W, mob/user)
	if(!istype(W, /obj/item/card/id))
		return
	check_job(W, user, slot_glasses_str)

/obj/item/clothing/glasses/chameleon
	name = "Optical Meson Scanner"
	icon_state = "meson"
	item_state = "glasses"
	desc = "It looks like a plain set of mesons, but on closer inspection, it seems to have a small dial inside."
	origin_tech = list(TECH_ILLEGAL = 3)
	var/list/global/clothing_choices

/obj/item/clothing/glasses/chameleon/New()
	..()
	if(!clothing_choices)
		var/blocked = list( // Prevent infinite loops and bad hats.
			type,
			/obj/item/clothing/mask/animal_mask,
			/obj/item/clothing/mask/gas/vox,
			/obj/item/clothing/mask/gas/poltergeist,
			/obj/item/clothing/mask/smokable,
			/obj/item/clothing/mask/smokable/cigarette/syndi_cigs,
			/obj/item/clothing/mask/smokable/ecig
		)
		var/blocked_cat = list(
			/obj/item/clothing/glasses/hud
		)
		clothing_choices = generate_chameleon_choices(/obj/item/clothing/glasses, blocked, blocked_cat)

/obj/item/clothing/glasses/chameleon/emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
	SetName(initial(name))
	desc = initial(desc)
	icon_state = initial(icon_state)
	item_state = initial(item_state)
	update_icon()
	update_clothing_icon()

/obj/item/clothing/glasses/chameleon/verb/change(picked in clothing_choices)
	set name = "Change Glasses Appearance"
	set category = "Chameleon Items"
	set src in usr

	if(!ispath(clothing_choices[picked]))
		return

	disguise(clothing_choices[picked], usr)
	update_clothing_icon()	//so our overlays update.

//*****************
//**Chameleon Gun**
//*****************
/obj/item/gun/energy/chameleon
	name = "revolver"
	desc = "A hologram projector in the shape of a gun. There is a dial on the side to change the gun's disguise."
	icon_state = "revolver"
	w_class = ITEM_SIZE_SMALL
	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2, TECH_ILLEGAL = 3)
	matter = list()

	fire_sound = 'sound/effects/weapons/gun/fire_generic_pistol.ogg'
	projectile_type = /obj/item/projectile/chameleon
	charge_meter = 0
	charge_cost = 20 //uses next to no power, since it's just holograms
	max_shots = 50
	has_safety = FALSE
	var/obj/item/projectile/copy_projectile
	var/global/list/gun_choices

/obj/item/gun/energy/chameleon/New()
	..()

	if(!gun_choices)
		gun_choices = list()
		for(var/gun_type in typesof(/obj/item/gun/) - src.type)
			var/obj/item/gun/G = gun_type
			src.gun_choices[initial(G.name)] = gun_type
	return

/obj/item/gun/energy/chameleon/consume_next_projectile()
	var/obj/item/projectile/P = ..()
	if(P && ispath(copy_projectile))
		P.SetName(initial(copy_projectile.name))
		P.icon = initial(copy_projectile.icon)
		P.icon_state = initial(copy_projectile.icon_state)
		P.pass_flags = initial(copy_projectile.pass_flags)
		P.hitscan = initial(copy_projectile.hitscan)
		P.muzzle_type = initial(copy_projectile.muzzle_type)
		P.tracer_type = initial(copy_projectile.tracer_type)
		P.impact_type = initial(copy_projectile.impact_type)
	return P

/obj/item/gun/energy/chameleon/emp_act(severity)
	SetName(initial(name))
	desc = initial(desc)
	icon_state = initial(icon_state)
	update_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_r_hand()
		M.update_inv_l_hand()

/obj/item/gun/energy/chameleon/disguise(newtype)
	var/obj/item/gun/copy = ..()
	if(!copy)
		return

	flags_inv = copy.flags_inv
	fire_sound = copy.fire_sound
	fire_sound_text = copy.fire_sound_text

	var/obj/item/gun/energy/E = copy
	if(istype(E))
		copy_projectile = E.projectile_type
		//charge_meter = E.charge_meter //does not work very well with icon_state changes, ATM
	else
		copy_projectile = null
		//charge_meter = 0

/obj/item/gun/energy/chameleon/verb/change(picked in gun_choices)
	set name = "Change Gun Appearance"
	set category = "Chameleon Items"
	set src in usr

	if(!ispath(gun_choices[picked]))
		return

	disguise(gun_choices[picked], usr)

	//so our overlays update.
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_r_hand()
		M.update_inv_l_hand()
