/obj/item/organ_module/active/simple/armsmg
	name = "embedded pistol"
	desc = "A pistol designed to be embedded into prosthetics. Gives you a nice advantage in a firefight"
	action_button_name = "Deploy embedded pistol"
	icon_state = "armsmg"
	matter = list(
		MATERIAL_PLASTEEL = 2000,
		MATERIAL_PLASTIC = 5000,
		MATERIAL_SILVER = 1000
	)
	allowed_organs = list(BP_L_ARM, BP_R_ARM)
	holding_type = /obj/item/gun/projectile/pistol/holdout
	available_in_charsetup = FALSE
	w_class = 2
	cpu_load = 1
	origin_tech = list(TECH_ILLEGAL = 4, TECH_COMBAT = 6, TECH_BIO = 4)

/obj/item/organ_module/active/simple/armsmg/emp_act(severity)
	. = ..()

	var/obj/item/organ/external/E = loc
	var/mob/living/carbon/human/H = E?.owner
	if(!istype(E) || !istype(H))
		return

	var/chance = 10 * (4 - severity)
	if(!prob(chance))
		return

	if(QDELETED(holding) && holding_type)
		holding = new holding_type(src)
		holding.canremove = FALSE
	if(!holding || !istype(holding, /obj/item/gun/projectile))
		return

	var/obj/item/gun/projectile/G = holding
	if(!G.chambered && (!islist(G.loaded) || !G.loaded.len))
		return

	H.visible_message(
		SPAN_WARNING("[H]'s embedded pistol discharges in \his arm!"),
		SPAN_DANGER("Your embedded pistol discharges in your arm!")
	)
	G.Fire(H, H, pointblank = TRUE, target_zone = E.organ_tag)
