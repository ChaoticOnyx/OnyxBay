/obj/item/implant/spy
	name = "spying implant"
	desc = "Used for spying purposes."
	origin_tech = list(TECH_MATERIAL = 1, TECH_BIO = 2, TECH_ILLEGAL = 2)
	var/activated = FALSE
	var/weakref/uplink_ref

/obj/item/implant/spy/Destroy()
	uplink_ref = null
	return ..()

/obj/item/implant/spy/Initialize()
	. = ..()
	add_think_ctx("check_completion", CALLBACK(src, nameof(.proc/check_compilation)), 0)

/obj/item/implant/spy/proc/check_compilation()
	if(!imp_in)
		return FALSE
	for(var/datum/antag_contract/implant/C in GLOB.traitors.fixer.return_contracts())
		C.check(src)

/obj/item/implant/spy/implanted(mob/source)
	set_next_think_ctx("check_completion", world.time + 1 MINUTE)
	return TRUE

/obj/item/implant/spy/removed()
	..()
	set_next_think_ctx("check_completion", 0)

/obj/item/implanter/spy
	name = "implanter (S)"
	desc = "It has a small label: \"Use your uplink for authorization\"."
	imp = /obj/item/implant/spy

/obj/item/implanter/spy/attackby(obj/item/I, mob/user)
	var/datum/component/uplink/U = I.get_component(/datum/component/uplink)
	if(imp && istype(imp, /obj/item/implant/spy) && istype(U))
		var/obj/item/implant/spy/S = imp
		S.uplink_ref = weakref(U)
		to_chat(user, SPAN("notice", "You authorize the [src] with \the [I]."))

/obj/item/implantcase/spy
	name = "glass case - 'spy'"
	imp = /obj/item/implant/spy
