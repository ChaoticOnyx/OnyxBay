/obj/item/weapon/implant/spy
	name = "spying implant"
	desc = "Used for spying purposes. It has a small label: \"Use your uplink on it for authorization\"."
	origin_tech = list(TECH_MATERIAL = 1, TECH_BIO = 2, TECH_ILLEGAL = 2)
	var/activated = FALSE
	var/timer

/obj/item/weapon/implant/spy/proc/check_compilation()
	if(!imp_in)
		return FALSE
	for(var/datum/antag_contract/implant/C in GLOB.traitors.fixer.return_contracts())
		C.check(src)

/obj/item/weapon/implant/spy/implanted(mob/source)
	timer = addtimer(CALLBACK(src, .proc/check_compilation), 1 MINUTES, TIMER_STOPPABLE)
	return TRUE

/obj/item/weapon/implant/spy/removed()
	..()
	deltimer(timer)

/obj/item/weapon/implanter/spy
	name = "implanter-spy"
	desc = "It has a small label \"Use your uplink on it for authorization\"."
	imp = /obj/item/weapon/implant/spy

/obj/item/weapon/implanter/spy/attackby(obj/item/I, mob/user)
	if(imp && istype(imp, /obj/item/weapon/implant/spy) && I.hidden_uplink)
		imp.hidden_uplink = I.hidden_uplink
		to_chat(user, SPAN_NOTICE("You connect [I]'s uplink to implant auth subsystem."))

/obj/item/weapon/implantcase/spy
	name = "glass case - 'spy'"
	imp = /obj/item/weapon/implant/spy
