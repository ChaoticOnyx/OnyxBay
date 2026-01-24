/obj/item/organ/internal/eyes/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/organ_module))
		var/obj/item/organ_module/module = I
		if(owner)
			to_chat(user, SPAN_NOTICE("You need to remove the eyes first."))
			return
		if(!module.can_install_in(src, user))
			return
		if(!user.drop(I, src))
			return
		module.install(src)
		to_chat(user, SPAN_NOTICE("You install \the [module] into \the [src]."))
		return
	return ..()

/obj/item/organ/internal/eyes/verb/remove_augmentations()
	set name = "Remove augmentations"
	set category = "Object"
	set src in view(1)

	if(usr.stat)
		return
	if(owner)
		to_chat(usr, SPAN_NOTICE("You need to remove the eyes first."))
		return
	if(!LAZYLEN(organ_modules))
		to_chat(usr, SPAN_NOTICE("There are no augmentations installed in \the [src]."))
		return

	var/obj/item/organ_module/choice = input(usr, "Remove which augmentation?", "Remove augmentations") as null|anything in organ_modules
	if(!choice)
		return
	choice.remove(src)
	to_chat(usr, SPAN_NOTICE("You remove \the [choice] from \the [src]."))
