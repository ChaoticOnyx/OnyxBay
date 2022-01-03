/obj/item/implant/spy
	name = "spying implant"
	desc = "Used for spying purposes."
	origin_tech = list(TECH_MATERIAL = 1, TECH_BIO = 2, TECH_ILLEGAL = 2)
	var/activated = FALSE
	var/timer

/obj/item/implant/spy/proc/check_compilation()
	if(!imp_in)
		return FALSE
	for(var/datum/antag_contract/implant/C in GLOB.traitors.fixer.return_contracts())
		C.check(src)

/obj/item/implant/spy/implanted(mob/source)
	timer = addtimer(CALLBACK(src, .proc/check_compilation), 1 MINUTES, TIMER_STOPPABLE)
	return TRUE

/obj/item/implant/spy/removed()
	..()
	deltimer(timer)

/obj/item/implanter/spy
	name = "implanter (S)"
	desc = "It has a small label: \"Use your uplink for authorization\"."
	imp = /obj/item/implant/spy

/obj/item/implanter/spy/attackby(obj/item/I, mob/user)
	if(imp && istype(imp, /obj/item/implant/spy) && I.hidden_uplink)
		imp.hidden_uplink = I.hidden_uplink
		to_chat(user, SPAN("notice", "You authorize the [src] with \the [I]."))

/obj/item/implantcase/spy
	name = "glass case - 'spy'"
	imp = /obj/item/implant/spy
