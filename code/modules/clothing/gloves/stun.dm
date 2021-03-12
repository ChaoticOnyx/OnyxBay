// Stun gloves. ~TheUnknownOne

/obj/item/clothing/gloves/stun
	name = "stun gloves"
	desc = "A pair of gloves with some wires with exposed ends at the fingers taped to them."
	icon_state = "black"
	wired = TRUE
	var/obj/item/clothing/gloves/base_gloves
	var/agonyforce = 50
	var/attack_cost = 50
	var/obj/item/weapon/cell/device/bcell

/obj/item/clothing/gloves/stun/Initialize(loc, obj/item/clothing/gloves/G)
	. = ..()
	if(!istype(G))
		return
	base_gloves = G
	appearance = base_gloves.appearance
	name = "stun gloves"
	desc = "[desc]<br>They have some wires with exposed ends at the fingers taped to them."
	if(base_gloves.clipped)
		cut_fingertops()
	wire_color = base_gloves.wire_color
	siemens_coefficient = base_gloves.siemens_coefficient
	armor = base_gloves.armor
	base_gloves.forceMove(src)

/obj/item/clothing/gloves/stun/Destroy()
	QDEL_NULL(bcell)
	QDEL_NULL(base_gloves)
	return ..()

/obj/item/clothing/gloves/stun/update_icon(needs_updating=FALSE)
	..()
	if(bcell)
		overlays += image(icon, "gloves_cell")

/obj/item/clothing/gloves/stun/examine()
	. = ..()
	if(!bcell)
		. += "<br>\The [src] have no power cell installed."
	else
		. += "<br>\The [src] are [round(bcell.percent())]% charged."

/obj/item/clothing/gloves/stun/attackby(obj/item/weapon/W, mob/user)
	if(isWirecutter(W))
		playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
		if(bcell)
			to_chat(user, SPAN("notice", "You carefully disconnect \the [bcell] from the wires on \the [src]."))
			user.put_in_hands(bcell)
			bcell = null
			update_icon(TRUE)
			return

		user.visible_message(SPAN("warning", "\The [user] cuts the tape and the wires from \the [src] with \the [W]."), SPAN("notice", "You cut the tape and the wires from \the [src] with \the [W]."))
		if(!base_gloves)
			qdel(src)
		base_gloves.wired = FALSE
		base_gloves.update_icon(TRUE)
		new /obj/item/stack/cable_coil(user.loc, 15, wire_color)
		user.drop_from_inventory(base_gloves)
		base_gloves = null
		qdel(src)
		return

	if(istype(W, /obj/item/weapon/cell/device))
		if(bcell)
			to_chat(user, SPAN("notice", "The [src] already have \the [bcell] installed."))
			return
		if(user.unEquip(W))
			bcell = W
			bcell.forceMove(src)
			update_icon(TRUE)
			to_chat(user, SPAN("notice", "You connect \the [bcell] to the wires on \the [src]."))
			return

/obj/item/clothing/gloves/stun/emp_act(severity)
	if(bcell)
		bcell.charge -= 100 / severity
		if(bcell.charge < 0)
			bcell.charge = 0
	..()

/obj/item/clothing/gloves/stun/Touch(atom/A, proximity)
	if(!proximity || !bcell)
		return FALSE

	if(ishuman(A) && ishuman(src.loc))
		var/mob/living/carbon/human/user = src.loc
		var/mob/living/carbon/human/victim = A
		if(user.a_intent != I_DISARM)
			return FALSE
		stun_attack(user, victim)
		return TRUE
	return FALSE

/obj/item/clothing/gloves/stun/proc/check_aim(zone)
	var/restricted_bps = list(BP_R_LEG, BP_L_LEG, BP_R_FOOT, BP_L_FOOT)
	check_zone(zone)
	if(zone in restricted_bps)
		zone = BP_GROIN // To avoid stunning people with one stun attack
		to_chat(src.loc, SPAN("notice", "The target will dodge your attack on the legs, so you go for their lower body instead!"))
	return zone

/obj/item/clothing/gloves/stun/proc/stun_attack(mob/living/carbon/human/user, mob/living/carbon/human/victim)
	if(!istype(user) || !istype(victim))
		return

	var/aim = check_aim(user.zone_sel.selecting)
	var/obj/item/organ/external/affecting = victim.get_organ(aim)
	if(!affecting)
		to_chat(user, SPAN("warning", "\The [victim] is missing that bodypart!"))
		return

	user.do_attack_animation(victim)
	if(!bcell.checked_use(attack_cost))
		user.visible_message(SPAN("danger", "\The [user] grips \the [victim]'s [affecting.name] but nothing happens!"), SPAN("danger", "You grip \the [victim]'s [affecting.name] but your [src] aren't activating!"))
		return

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, victim)
	s.start()

	victim.stun_effect_act(0, agonyforce, aim, src)
	victim.forcesay(GLOB.hit_appends)
	user.visible_message(SPAN("danger", "\The [user] grips \the [victim]'s [affecting.name] and sparks emit from their gloves!"))
	to_chat(victim, SPAN("warning", "You feel a shock coming from \the [user]'s gloves!"))

	var/self_shock_chance = 5
	if(MUTATION_CLUMSY in user.mutations)
		self_shock_chance = 50
	if(prob(self_shock_chance) && siemens_coefficient > 0)
		var/self_agony = agonyforce * siemens_coefficient
		user.stun_effect_act(0, self_agony, pick(BP_R_HAND, BP_L_HAND), src)
		user.visible_message(SPAN("danger", "\The [user] accidentally shocks themself with their [src]!"), SPAN("danger", "You accidentally shock yourself with your [src]!"))

	msg_admin_attack("[key_name(user)] stun gripped [key_name(victim)] with the [src].")
