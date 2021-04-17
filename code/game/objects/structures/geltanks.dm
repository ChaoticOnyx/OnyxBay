/obj/structure/geltank
	name = "unknown gel tank"
	desc = "I'm not supposed to exist. Somebody has done something very wrong."
	icon = 'icons/obj/reagent_tanks.dmi'
	icon_state = "watertank"
	density = 1
	anchored = 0
	pull_sound = "pull_machine"
	pull_slowdown = PULL_SLOWDOWN_LIGHT
	var/capacity_max = 300
	var/capacity = 300
	var/gel_type = "unknown"
	atom_flags = ATOM_FLAG_CLIMBABLE

/obj/structure/geltank/examine(mob/user)
	. = ..()
	if(capacity >= 0)
		. += "\nIt contains [capacity]/[capacity_max] units of gel."
	else
		. += "\nIt's empty."

/obj/structure/geltank/proc/use(amt = 1)
	capacity -= amt
	if(capacity <= 0)
		icon_state = "[initial(icon_state)]-empty"
		name = "empty [name]"
	else if(capacity <= 150)
		icon_state = "[initial(icon_state)]-used"

/obj/structure/geltank/proc/fill_gel(obj/item/stack/medical/advanced/O, mob/user)
	if(capacity <= 0)
		to_chat(user, SPAN("warning", "\The [src] is empty!"))
		return
	var/amt_to_transfer = min((O.max_amount - O.amount), capacity)
	if(O.refill(amt_to_transfer))
		to_chat(user, SPAN("notice", "You refill \the [O] with [amt_to_transfer] doses of [gel_type] gel."))
		use(amt_to_transfer)
	else
		to_chat(user, SPAN("notice", "\The [O] is already full."))

/obj/structure/geltank/somatic
	name = "somatic gel tank"
	desc = "A tank of somatic gel, manufactured by Vey-Med. The nozzle design makes it only possible to refill the specialized containers."
	icon_state = "somatictank"
	gel_type = "somatic"

/obj/structure/geltank/somatic/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/stack/medical/advanced/bruise_pack))
		var/obj/item/stack/medical/advanced/bruise_pack/O = W
		fill_gel(O, user)
		return
	if(istype(W, /obj/item/weapon/organfixer))
		var/obj/item/weapon/organfixer/G = W
		if(capacity <= 0)
			to_chat(user, SPAN("warning", "\The [src] is empty!"))
			return
		if(G.gel_amt_max == -1)
			to_chat(user, SPAN("notice", "\The [G] doesn't seem to be reloadable."))
			return
		var/amt_to_transfer = min((G.gel_amt_max - G.gel_amt), capacity)
		if(G.refill(amt_to_transfer))
			G.update_icon()
			to_chat(user, SPAN("notice", "You refill \the [G] with [amt_to_transfer] doses of somatic gel."))
			use(amt_to_transfer)
		else
			to_chat(user, SPAN("notice", "\The [G] is full."))
		return
	return ..()

/obj/structure/geltank/burn
	name = "burn gel tank"
	desc = "A tank of protein-renaturating gel, manufactured by Vey-Med. The nozzle design makes it only possible to refill the specialized containers."
	icon_state = "burntank"
	gel_type = "burn"

/obj/structure/geltank/burn/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/stack/medical/advanced/ointment))
		var/obj/item/stack/medical/advanced/ointment/O = W
		fill_gel(O, user)
		return
	return ..()
