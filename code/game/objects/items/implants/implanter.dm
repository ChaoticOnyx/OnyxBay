/obj/item/implanter
	name = "implanter"
	icon = 'icons/obj/items.dmi'
	icon_state = "implanter0"
	item_state = "syringe_0"
	throw_range = 5
	w_class = ITEM_SIZE_SMALL
	matter = list(MATERIAL_STEEL = 1000, MATERIAL_GLASS = 1000)
	var/obj/item/implant/imp = null

/obj/item/implanter/New()
	if(ispath(imp))
		imp = new imp(src)
	..()
	update_icon()

/obj/item/implanter/on_update_icon()
	if (imp)
		icon_state = "implanter1"
	else
		icon_state = "implanter0"

/obj/item/implanter/verb/remove_implant()
	set category = "Object"
	set name = "Remove implant"
	set src in usr

	if(issilicon(usr))
		return

	if(can_use(usr))
		if(!imp)
			to_chat(usr, "<span class='notice'>There is no implant to remove.</span>")
			return
		usr.pick_or_drop(imp, loc)
		to_chat(usr, "<span class='notice'>You remove \the [imp] from \the [src].</span>")
		name = "implanter"
		imp = null
		update_icon()
		return
	else
		to_chat(usr, "<span class='notice'>You cannot do this in your current condition.</span>")

/obj/item/implanter/proc/can_use()

	if(!ismob(loc))
		return 0

	var/mob/M = loc

	if(M.incapacitated())
		return 0
	if((src in M.contents) || (istype(loc, /turf) && in_range(src, M)))
		return 1
	return 0

/obj/item/implanter/attackby(obj/item/I, mob/user)
	if(!imp && istype(I, /obj/item/implant))
		if(!user.drop(I, src))
			return
		to_chat(usr, "<span class='notice'>You slide \the [I] into \the [src].</span>")
		imp = I
		update_icon()
	else
		..()

/obj/item/implanter/attack(mob/M as mob, mob/user as mob)
	if (!istype(M, /mob/living/carbon))
		return
	if (user && src.imp)
		M.visible_message(SPAN("warning", "[user] is attempting to implant [M]."))

		user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
		user.do_attack_animation(M)

		var/target_zone = user.zone_sel.selecting
		if(src.imp.can_implant(M, user, target_zone))
			var/imp_name = imp.name

			if(do_after(user, 50, M, luck_check_type = LUCK_CHECK_COMBAT) && src.imp?.implant_in_mob(M, target_zone))
				M.visible_message("<span class='warning'>[M] has been implanted by [user].</span>")
				admin_attack_log(user, M, "Implanted using \the [src] ([imp_name])", "Implanted with \the [src] ([imp_name])", "used an implanter, \the [src] ([imp_name]), on")

				src.imp = null
				update_icon()

	return
