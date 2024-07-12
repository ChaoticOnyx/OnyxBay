
/obj/item/clothing/mask/smokable/cigarette
	name = "cigarette"
	desc = "A small paper cylinder filled with processed tobacco and various fillers."
	icon_state = "cigoff"
	throw_speed = 2
	item_state = "cigoff"
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS | SLOT_MASK
	attack_verb = list("burnt", "singed")
	type_butt = /obj/item/cigbutt
	chem_volume = 5
	smoketime = 120
	brand = "\improper Trans-Stellar Duty-free"
	hitsound = 'sound/items/pffsh.ogg'
	var/list/filling = list(/datum/reagent/tobacco = 3)
	var/ember_state = "cigember"
	var/dynamic_icon = TRUE

/obj/item/clothing/mask/smokable/cigarette/Initialize()
	. = ..()
	for(var/R in filling)
		reagents.add_reagent(R, filling[R])

/obj/item/clothing/mask/smokable/cigarette/on_update_icon()
	..()
	ClearOverlays()
	if(dynamic_icon)
		var/ratio = round(smoketime / initial(smoketime), 0.25) * 100
		icon_state = ever_lit ? "[initial(icon_state)][ratio]" : initial(icon_state)
		if(lit)
			AddOverlays(OVERLAY(icon, "[ember_state][ratio]", alpha, RESET_COLOR))
	else if(lit)
		AddOverlays(OVERLAY(icon, ember_state, alpha, RESET_COLOR))

/obj/item/clothing/mask/smokable/cigarette/die(nomessage = FALSE, nodestroy = FALSE)
	..()
	if(type_butt && !nodestroy)
		var/obj/item/butt = new type_butt(get_turf(src))
		transfer_fingerprints_to(butt)
		butt.color = color
		if(brand)
			butt.desc += " This one is \a [brand]."
		if(iscarbon(loc))
			var/mob/living/carbon/C = loc
			if(!nomessage)
				to_chat(C, SPAN_NOTICE("Your [name] goes out."))
			if(!C.stat && (src == C.wear_mask || C.is_item_in_hands(src)) && !C.handcuffed && isturf(C.loc))
				for(var/obj/item/material/ashtray/A in view(1, C))
					A.store(butt, C)
					break
			C.drop(src)
		qdel(src)
		. = butt

/obj/item/clothing/mask/smokable/cigarette/get_temperature_as_from_ignitor()
	if(lit)
		return 1000
	return 0

/obj/item/clothing/mask/smokable/cigarette/can_be_lit_with(obj/W)
	if(istype(W, /obj/item/gun) && !istype(W, /obj/item/gun/flamer) && !istype(W, /obj/item/gun/energy/plasmacutter))
		var/obj/item/gun/gun = W
		return gun.combustion && gun.loc == src.loc
	if(istype(W, /obj/machinery/kitchen/grill))
		var/obj/machinery/kitchen/grill/grill = W
		return !(grill.stat & (NOPOWER|BROKEN))
	if(istype(W, /obj/machinery/light))
		var/obj/machinery/light/mounted = W
		var/obj/item/light/bulb = mounted.lightbulb
		return bulb && istype(bulb, /obj/item/light/bulb) && bulb.status == 2 && !(mounted.stat & BROKEN)
	return ..()

/obj/item/clothing/mask/smokable/cigarette/generate_lighting_message(atom/tool, mob/holder)
	if(!holder || !tool)
		return ..()
	if(src.loc != holder)
		return ..()

	if(istype(tool, /obj/item/flame/lighter/zippo))
		return SPAN("rose", "With a flick of the wrist, [holder] lights \his [name] with \a [tool].")
	if(istype(tool, /obj/item/flame/lighter))
		return SPAN("notice", "[holder] manages to light \his [name] with \a [tool].")
	if(istype(tool, /obj/item/flame/candle))
		return SPAN("notice", "[holder] carefully lights \his [name] with \a [tool].")
	if(isitem(tool))
		var/obj/item/I = tool
		if(isWelder(I))
			return SPAN("notice", "[holder] casually lights \his [name] with \a [tool].")
	if(istype(tool, /obj/item/device/assembly/igniter))
		return SPAN("notice", "[holder] fiddles with \his [tool.name], and manages to light \a [name].")
	if(istype(tool, /obj/item/reagent_containers/rag))
		return SPAN("notice", "[holder] somehow manages to light \his [name] with \a [tool].")
	if(istype(tool, /obj/item/jackolantern))
		return SPAN("notice", "[holder] shoves \his [name] into \a [tool] to light it up.")
	if(istype(tool, /obj/item/melee/energy))
		return SPAN("warning", "[holder] swings \his [tool.name], and light \a [name] in the process.")
	if(istype(tool, /obj/item/gun))
		if(istype(tool, /obj/item/gun/flamer))
			return SPAN("warning", "[holder] fearlessly lights \his [name] with the twinkling flare of \the lit [tool].")
		else if(istype(tool, /obj/item/gun/energy/plasmacutter))
			return SPAN("notice", "[holder] touches \his [tool.name] with \a [name] to light it up.")
		else
			return SPAN("danger", "[holder] fired \his [tool.name] into the air, lighting \a [name] in the process!")
	if(istype(tool, /datum/spell/targeted/projectile/dumbfire/fireball))
		return SPAN("notice", "Roaring fireball lits \a [name] in the mouth of [holder]!")
	if(istype(tool, /obj/machinery/light))
		return SPAN("notice", "[holder] cleverly lights \his [name] by a red-hot incandescent spiral inside the broken lightbulb.")
	if(isliving(tool))
		return SPAN("notice", "[holder] coldly lights \his [name] with the burning body of [tool].")

	return ..()

/obj/item/clothing/mask/smokable/cigarette/attackby(obj/item/W, mob/user)
	if(isWirecutter(W))
		user.visible_message(SPAN("notice", "[user] cut the tip of \his [name] with [W]."), "You cut the tip of your [name]")
		smoketime -= 10
		if(smoketime <= 0)
			die()
		else
			die(nodestroy = TRUE)
		return

	if(istype(W, /obj/item/gun) && !istype(W, /obj/item/gun/energy/plasmacutter) && !istype(W, /obj/item/gun/flamer))
		if(!lit && can_be_lit_with(W))
			var/obj/item/gun/gun = W
			if(gun.special_check(user))
				var/obj/P = gun.consume_next_projectile()
				if(P)
					gun.play_fire_sound(user, P)
					gun.handle_post_fire(user, src, TRUE)

					var/oops_chance = 25 // %
					if(isliving(user))
						var/mob/living/L = user
						for(var/datum/modifier/trait/inaccurate/M in L.modifiers)
							oops_chance = max(0, oops_chance - 2 * M.accuracy)
					if(ishuman(user))
						var/mob/living/carbon/human/H = user
						oops_chance = max(0, oops_chance - 10 * H.skills["weapons"])

					var/fuck_up_chance = ceil(oops_chance / 8)
					var/roll = rand(99) + 1
					if(roll < fuck_up_chance)
						if(gun.process_projectile(P, user, user, BP_HEAD))
							user.visible_message(SPAN("danger", "[user] shot \himself in the face with \the [gun].")) // Oops
						return
					else if(roll < oops_chance && istype(gun, /obj/item/gun/projectile) && isliving(user))
						var/mob/living/L = user
						to_chat(user, SPAN("warning", "You burned your face a little."))
						L.apply_damage(5, BURN, BP_HEAD, used_weapon = gun)
					light(W, user)
				else
					gun.handle_click_empty(user)
					return
			else
				return
		else
			..()
	else
		..()

/obj/item/clothing/mask/smokable/cigarette/attack(mob/living/M, mob/user, def_zone)
	if(lit && M == user && istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/blocked = H.check_mouth_coverage()
		if(blocked)
			to_chat(H, SPAN("warning", "\The [blocked] is in the way!"))
			return 1
		user.visible_message("[user] takes a [pick("drag","puff","pull")] on \his [name].", \
							 "You take a [pick("drag","puff","pull")] on your [name].")
		smoke(12, TRUE)
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		return 1
	if(!lit && istype(M) && M.on_fire)
		user.do_attack_animation(M)
		light(M, user)
		return 1
	return ..()

/obj/item/clothing/mask/smokable/cigarette/afterattack(obj/item/W, mob/user, proximity)
	if(istype(W, /obj/item/gun) && !istype(W, /obj/item/gun/energy/plasmacutter) && !istype(W, /obj/item/gun/flamer))
		return

	..()

	if(istype(W, /obj/item/reagent_containers/vessel)) // you can dip cigarettes into vessels
		var/obj/item/reagent_containers/vessel/glass = W
		if(!glass.is_open_container())
			to_chat(user, SPAN("notice", "You need to open \the [glass] first."))
			return
		var/transfered = glass.reagents.trans_to_obj(src, chem_volume)
		if(transfered)	//if reagents were transfered, show the message
			to_chat(user, SPAN("notice", "You dip \the [src] into \the [glass]."))
		else			//if not, either the beaker was empty, or the cigarette was full
			if(!glass.reagents.total_volume)
				to_chat(user, SPAN("notice", "[glass] is empty."))
				return
			else
				to_chat(user, SPAN("notice", "[src] is full."))
		die(nomessage = FALSE, nodestroy = TRUE)

/obj/item/clothing/mask/smokable/cigarette/attack_self(mob/user)
	if(lit == 1)
		user.visible_message(SPAN("notice", "[user] calmly drops and treads on the lit [src], putting it out instantly."))
		if(dynamic_icon)
			die(nomessage = TRUE, nodestroy = TRUE)
			if(loc == user)
				SetTransform(rotation = round(rand(0, 360), 45))
				pixel_x = rand(-10, 10)
				pixel_y = rand(-10, 10)
				user.drop(src) // un-equip it so the overlays can update
		else
			die(nomessage = TRUE, nodestroy = FALSE)
	return ..()

/obj/item/clothing/mask/smokable/cigarette/attack_hand(mob/user)
	if(ishuman(user) && dynamic_icon)
		ClearTransform()
		pixel_x = initial(pixel_x)
		pixel_y = initial(pixel_y)
	return ..()

/obj/item/clothing/mask/smokable/cigarette/apply_hit_effect(mob/living/target, mob/living/user, hit_zone)
	. = ..()
	if(lit)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.a_intent == I_HELP)
				return
		die()

/obj/item/clothing/mask/smokable/cigarette/get_icon_state(slot)
	return item_state

/obj/item/clothing/mask/smokable/cigarette/get_mob_overlay(mob/user_mob, slot)
	. = ..()
	var/image/ret

	if(slot == slot_l_hand_str || slot == slot_r_hand_str)
		ret = .[1]
	else
		ret = .

	if(lit == 1)
		var/image/ember = overlay_image(ret.icon, "cigember", flags = RESET_COLOR)
		ember.layer = ABOVE_LIGHTING_LAYER
		ember.plane = EFFECTS_ABOVE_LIGHTING_PLANE
		ret.AddOverlays(ember)
	return ret


/obj/item/cigbutt
	name = "cigarette butt"
	desc = "A manky old cigarette butt."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cigbutt"
	randpixel = 10
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS
	throwforce = 0

/obj/item/cigbutt/Initialize()
	. = ..()
	SetTransform(rotation = round(rand(0, 360), 45))

////////////////
// CIGARETTES //
////////////////
/obj/item/clothing/mask/smokable/cigarette/menthol
	name = "menthol cigarette"
	desc = "A cigarette with a little minty kick. Well, minty in theory."
	icon_state = "cigmentol"
	brand = "\improper Temperamento Menthol"
	color = "#ddffe8"
	type_butt = /obj/item/cigbutt/menthol
	filling = list(/datum/reagent/tobacco = 1, /datum/reagent/menthol = 1)

/obj/item/cigbutt/menthol
	icon_state = "cigbuttmentol"

/obj/item/clothing/mask/smokable/cigarette/luckystars
	brand = "\improper Lucky Star"

/obj/item/clothing/mask/smokable/cigarette/jerichos
	name = "rugged cigarette"
	brand = "\improper Jericho"
	icon_state = "cigjer"
	color = "#dcdcdc"
	filter_trans = 0.6
	type_butt = /obj/item/cigbutt/jerichos
	filling = list(/datum/reagent/tobacco/bad = 3.5)

/obj/item/cigbutt/jerichos
	icon_state = "cigbuttjer"

/obj/item/clothing/mask/smokable/cigarette/carcinomas
	name = "dark cigarette"
	brand = "\improper Carcinoma Angel"
	color = "#869286"

/obj/item/clothing/mask/smokable/cigarette/professionals
	name = "thin cigarette"
	brand = "\improper Professional"
	icon_state = "cigpro"
	type_butt = /obj/item/cigbutt/professionals
	filling = list(/datum/reagent/tobacco/bad = 3)

/obj/item/cigbutt/professionals
	icon_state = "cigbuttpro"

/obj/item/clothing/mask/smokable/cigarette/killthroat
	brand = "\improper Acme Co. cigarette"

/obj/item/clothing/mask/smokable/cigarette/dromedaryco
	brand = "\improper Dromedary Co. cigarette"

////////////////
// CIGARILLOS //
////////////////
/obj/item/clothing/mask/smokable/cigarette/trident
	name = "wood tip cigar"
	brand = "\improper Trident cigar"
	desc = "A narrow cigar with a wooden tip."
	icon_state = "cigarello"
	item_state = "cigaroff"
	ember_state = "cigarello-on"
	smoketime = 480
	chem_volume = 10
	filter_trans = 0.25
	type_butt = /obj/item/cigbutt/woodbutt
	filling = list(/datum/reagent/tobacco/fine = 6)
	dynamic_icon = FALSE

/obj/item/cigbutt/woodbutt
	name = "wooden tip"
	desc = "A wooden mouthpiece from a cigar. Smells rather bad."
	icon_state = "woodbutt"
	matter = list(MATERIAL_WOOD = 1)

/obj/item/clothing/mask/smokable/cigarette/trident/mint
	icon_state = "cigarelloMi"
	filling = list(/datum/reagent/tobacco/fine = 6, /datum/reagent/menthol = 2)

/obj/item/clothing/mask/smokable/cigarette/trident/berry
	icon_state = "cigarelloBe"
	filling = list(/datum/reagent/tobacco/fine = 6, /datum/reagent/drink/juice/berry = 2)

/obj/item/clothing/mask/smokable/cigarette/trident/cherry
	icon_state = "cigarelloCh"
	filling = list(/datum/reagent/tobacco/fine = 6, /datum/reagent/nutriment/cherryjelly = 2)

/obj/item/clothing/mask/smokable/cigarette/trident/grape
	icon_state = "cigarelloGr"
	filling = list(/datum/reagent/tobacco/fine = 6, /datum/reagent/drink/juice/grape = 2)

/obj/item/clothing/mask/smokable/cigarette/trident/watermelon
	icon_state = "cigarelloWm"
	filling = list(/datum/reagent/tobacco/fine = 6, /datum/reagent/drink/juice/watermelon = 2)

/obj/item/clothing/mask/smokable/cigarette/trident/orange
	icon_state = "cigarelloOr"
	filling = list(/datum/reagent/tobacco/fine = 6, /datum/reagent/drink/juice/orange = 2)

////////////////////
//SYNDI CIGARETTES//
////////////////////
/obj/item/clothing/mask/smokable/cigarette/syndi_cigs
	chem_volume = 15

/obj/item/clothing/mask/smokable/cigarette/syndi_cigs/flash
	atom_flags = ATOM_FLAG_NO_REACT
	filling = list(/datum/reagent/aluminum = 5, /datum/reagent/potassium = 5, /datum/reagent/sulfur = 5)

/obj/item/clothing/mask/smokable/cigarette/syndi_cigs/mind_breaker
	filling = list(/datum/reagent/mindbreaker = 15)

/obj/item/clothing/mask/smokable/cigarette/syndi_cigs/smoke
	atom_flags = ATOM_FLAG_NO_REACT
	filling = list(/datum/reagent/potassium = 5, /datum/reagent/sugar = 5, /datum/reagent/phosphorus = 5)

/obj/item/clothing/mask/smokable/cigarette/syndi_cigs/tricordrazine
	filling = list(/datum/reagent/tricordrazine = 15)

////////////
// CIGARS //
////////////
/obj/item/clothing/mask/smokable/cigarette/cigar
	name = "premium cigar"
	desc = "A brown roll of tobacco and... well, you're not quite sure. This thing's huge!"
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	ember_state = ""
	type_butt = /obj/item/cigbutt/cigarbutt
	throw_speed = 2
	item_state = "cigaroff"
	smoketime = 900
	chem_volume = 22.5
	filter_trans = 0.25
	filling = list(/datum/reagent/tobacco/fine = 15)
	dynamic_icon = FALSE

/obj/item/clothing/mask/smokable/cigarette/cigar/generate_lighting_message(obj/tool, mob/holder)
	if(!holder || !tool)
		return ..()
	if(src.loc != holder)
		return ..()

	if(istype(tool, /obj/item/flame/lighter) && !istype(tool, /obj/item/flame/lighter/zippo))
		return SPAN("notice", "[holder] manages to offend \his [name] by lighting it with \a [tool].")
	if(istype(tool, /obj/item/flame/candle))
		return SPAN("notice", "[holder] carefully lights \his [name] with \a classic [tool].")
	if(isitem(tool))
		var/obj/item/I = tool
		if(isWelder(I))
			return SPAN("notice", "[holder] insults \his [name] by lighting it with \a [tool].")
	if(istype(tool, /obj/item/device/assembly/igniter))
		return SPAN("notice", "[holder] fiddles with \his [tool.name], and manages to light \a [name] with the power of science.")
	if(istype(tool, /obj/item/reagent_containers/rag))
		return SPAN("notice", "[holder] somehow manages to light \his [name] with \a [tool]. What a clown!")
	return ..()

/obj/item/clothing/mask/smokable/cigarette/cigar/cohiba
	name = "\improper Cohiba Robusto cigar"
	desc = "There's little more you could want from a cigar."
	icon_state = "cigar2off"
	icon_on = "cigar2on"

/obj/item/clothing/mask/smokable/cigarette/cigar/havana
	name = "premium Havanian cigar"
	desc = "A cigar fit for only the best of the best."
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	smoketime = 1500
	chem_volume = 30
	filling = list(/datum/reagent/tobacco/fine = 20)

/obj/item/cigbutt/cigarbutt
	name = "cigar butt"
	desc = "A manky old cigar butt."
	icon_state = "cigarbutt"

/obj/item/clothing/mask/smokable/cigarette/cigar/attackby(obj/item/W as obj, mob/user as mob)
	..()
	user.update_inv_wear_mask(0)
	user.update_inv_l_hand(0)
	user.update_inv_r_hand(1)
