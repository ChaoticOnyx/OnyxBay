/obj/item/organ_module
	name = "embedded organ module"
	desc = "A mechanical augment designed for implantation into a human's flesh or prosthetics."
	icon = 'icons/obj/implants.dmi'
	matter = list(MATERIAL_STEEL = 12)
	can_get_wet = FALSE
	can_be_wrung_out = FALSE
	/// List of organ tags
	var/list/allowed_organs = list()
	/// For cybernetic-specific applicator sprite calls.
	var/mod_overlay
	/// Movspeed modifier added to organ's overall tally.
	var/organ_tally = 0

/obj/item/organ_module/proc/install(obj/item/organ/external/E)
	E.module = src
	E.implants += src
	src.forceMove(E)
	onInstall(E)

/obj/item/organ_module/proc/onInstall(obj/item/organ/external/E)
	if(organ_tally)
		E.update_tally()

/obj/item/organ_module/proc/remove(obj/item/organ/external/E)
	E.module = null
	E.implants -= src
	src.forceMove(E.drop_location())
	onRemove(E)

/obj/item/organ_module/proc/onRemove(obj/item/organ/external/E)
	if(organ_tally)
		E.update_tally()

/obj/item/organ_module/proc/organ_removed(obj/item/organ/external/E, mob/living/carbon/human/H)
	pass()

/obj/item/organ_module/proc/organ_installed(obj/item/organ/external/E, mob/living/carbon/human/H)
	pass()

/obj/item/organ_module/attackby(obj/item/I, mob/user)
	..()
	if(istype(I, /obj/item/implanter/installer/disposable))
		show_splash_text(user, "Can't refill!", SPAN_NOTICE("You cannot refill a single-use applicator."))
		return

	if(istype(I, /obj/item/implanter/installer))
		var/obj/item/implanter/installer/M = I
		if(!M.mod && user.drop(src, M))
			M.mod = src
			M.update_icon()
		return TRUE

	if(istype(I, /obj/item/implanter))
		show_splash_text(user, "Can't insert!", SPAN_NOTICE("You cannot insert cybernetics into an implant applicator."))
		return
