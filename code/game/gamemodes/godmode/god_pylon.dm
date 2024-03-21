
/obj/structure/deity/pylon
	name = "pylon"
	desc = "A crystal platform used to communicate with the deity."
	build_cost = 400
	icon_state = "pylon"
	var/list/intuned = list()

/obj/structure/deity/pylon/attack_deity(mob/living/deity/D)
	if(D.pylon == src)
		D.leave_pylon()
	else
		D.possess_pylon(src)

/obj/structure/deity/pylon/Destroy()
	if(linked_god && linked_god.pylon == src)
		linked_god.leave_pylon()
	return ..()

/obj/structure/deity/pylon/attack_hand(mob/living/L)
	if(!linked_god)
		return
	if(L in intuned)
		remove_intuned(L)
	else
		add_intuned(L)

/obj/structure/deity/pylon/proc/add_intuned(mob/living/L)
	if(L in intuned)
		return
	to_chat(L, "<span class='notice'>You place your hands on \the [src], feeling yourself intune to its vibrations.</span>")
	intuned += L
	register_signal(L, SIGNAL_QDELETING, /obj/structure/deity/pylon/proc/remove_intuned)

/obj/structure/deity/pylon/proc/remove_intuned(mob/living/L)
	if(!(L in intuned))
		return
	to_chat(L, "<span class='warning'>You no longer feel intuned to \the [src].</span>")
	intuned -= L
	unregister_signal(L, SIGNAL_QDELETING)
