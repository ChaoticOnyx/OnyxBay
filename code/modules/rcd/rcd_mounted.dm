/obj/item/construction/rcd/mounted/get_matter(mob/user)
	if(!istype(loc, /obj/item/rig_module))
		return 0

	var/obj/item/rig_module/module = loc

	max_matter = module.holder?.cell?.maxcharge

	return module.holder?.cell?.charge

/obj/item/construction/rcd/mounted/useResource(amount, mob/user)
	if(istype(loc, /obj/item/rig_module))

		var/obj/item/rig_module/module = loc

		if(module.holder && module.holder.cell)
			if(module.holder.cell.charge >= amount)
				. = module.holder.cell.use(amount)

	if(!. && user)
		show_splash_text(user, "insufficient charge!")
	return .

/obj/item/construction/rcd/mounted/checkResource(amount, mob/user)
	if(istype(loc, /obj/item/rig_module))

		var/obj/item/rig_module/module = loc

		if(module.holder && module.holder.cell)
			if(module.holder.cell.charge >= amount)
				. = module.holder.cell.charge >= amount

	if(!. && user)
		show_splash_text(user, "insufficient charge!")
	return .

/obj/item/construction/rcd/mounted/tgui_state(mob/user)
	return GLOB.tgui_conscious_state
