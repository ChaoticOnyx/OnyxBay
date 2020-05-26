/obj/structure/geltank
	name = "unknown gel tank"
	desc = "I'm not supposed to exist. Somebody has done something very wrong."
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"
	density = 1
	anchored = 0
	pull_sound = "pull_machine"
	var/capacity_max = 300
	var/capacity = 300
	atom_flags = ATOM_FLAG_CLIMBABLE

/obj/structure/geltank/examine(mob/user)
	. = ..()
	if(.)
		if(capacity >= 0)
			to_chat(user, "It contains [capacity]/[capacity_max] units of gel.")
		else
			to_chat(user, "It's empty.")

/obj/structure/geltank/proc/use(amt = 1)
	capacity -= amt
	if(capacity <= 0)
		icon_state = "[initial(icon_state)]-empty"
		name = "empty [name]"
	else if(capacity <= 150)
		icon_state = "[initial(icon_state)]-used"

/obj/structure/geltank/somatic
	name = "somatic gel tank"
	desc = "A tank of somatic gel, manufactured by Vey-Med."
	icon_state = "somatictank"

/obj/structure/geltank/somatic/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/stack/medical/advanced/bruise_pack))
		var/obj/item/stack/medical/advanced/bruise_pack/G = W
		if(capacity <= 0)
			to_chat(user, SPAN("warning", "\The [src] is empty!"))
			return
		if(G.amount >= G.max_amount)
			to_chat(user, SPAN("notice", "\The [G] is already full."))
			return
		var/amt_to_transfer = min((G.max_amount - G.amount), capacity)
		use(amt_to_transfer)
		G.refill(amt_to_transfer)
		to_chat(user, SPAN("notice", "You refill \the [src] with [amt_to_transfer] doses of somatic gel."))
		return
	if(istype(W, /obj/item/weapon/organfixer))
		var/obj/item/weapon/organfixer/G = W
		if(capacity <= 0)
			to_chat(user, SPAN("warning", "\The [src] is empty!"))
			return
		if(G.gel_amt_max == -1)
			to_chat(user, SPAN("notice", "\The [src] doesn't seem to be reloadable."))
			return
		if(G.gel_amt >= G.gel_amt_max)
			to_chat(user, SPAN("notice", "\The [G] is full."))
			return
		var/amt_to_transfer = min((G.gel_amt_max - G.gel_amt), capacity)
		use(amt_to_transfer)
		G.gel_amt += amt_to_transfer
		G.update_icon()
		to_chat(user, SPAN("notice", "You refill \the [src] with [amt_to_transfer] doses of somatic gel."))
		return
	return ..()

/obj/structure/geltank/burn
	name = "burn gel tank"
	desc = "A tank of protein-renaturating gel, manufactured by Vey-Med."
	icon_state = "burntank"

/obj/structure/geltank/burn/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/stack/medical/advanced/ointment))
		var/obj/item/stack/medical/advanced/ointment/G = W
		if(capacity <= 0)
			to_chat(user, SPAN("warning", "\The [src] is empty!"))
			return
		if(G.amount >= G.max_amount)
			to_chat(user, SPAN("notice", "\The [G] is already full."))
			return
		var/amt_to_transfer = min((G.max_amount - G.amount), capacity)
		use(amt_to_transfer)
		G.refill(amt_to_transfer)
		to_chat(user, SPAN("notice", "You refill \the [src] with [amt_to_transfer] doses of burn gel."))
		return
	return ..()
