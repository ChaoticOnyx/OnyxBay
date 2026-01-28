/obj/item/organ_module/muscle
	name = "mechanical muscles"
	desc = "A set of mechanical muscles designed to be implanted into legs. (Using them without CPU will cause damage.)"
	allowed_organs = list(BP_R_LEG, BP_L_LEG)
	icon_state = "muscle"
	organ_tally = -0.1
	available_in_charsetup = TRUE
	augment_cost = 5
	cpu_load = 1
	w_class = 2
	origin_tech = list(TECH_COMBAT = 6, TECH_ENGINEERING = 6, TECH_BIO = 6)
	matter = list(
		MATERIAL_GOLD = 1000,
		MATERIAL_PLASTEEL = 3000,
		MATERIAL_SILVER = 100
	)
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL | OM_FLAG_MECHANICAL
/// later will be used for jumps

/obj/item/organ_module/muscle/post_install(obj/item/organ/external/E)
	var/mob/living/carbon/human/H = E?.owner
	if(!istype(H))
		return
	H.add_movespeed_modifier(/datum/movespeed_modifier/mechanical_muscles)

/obj/item/organ_module/muscle/post_removed(obj/item/organ/external/E)
	var/mob/living/carbon/human/H = E?.owner
	if(!istype(H))
		return
	H.remove_movespeed_modifier(/datum/movespeed_modifier/mechanical_muscles)


/obj/item/organ_module/muscle/emp_act(severity)
	. = ..()

	var/obj/item/organ/external/E = loc
	var/mob/living/carbon/human/H = E?.owner
	if(!istype(E) || !istype(H))
		return

	var/chance = 10 * (4 - severity)
	if(!prob(chance))
		return

	if(!E.fracture())
		return

	H.visible_message(
		SPAN_DANGER("[H]'s mechanical muscles overload, shattering their leg!"),
		SPAN_DANGER("Your mechanical muscles overload, shattering your leg!")
	)
