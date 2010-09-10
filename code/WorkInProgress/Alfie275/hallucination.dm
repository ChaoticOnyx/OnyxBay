atom/var/icon/hal
atom/var/halstate

atom/New()
	src.hal = src.icon
	src.halstate = src.icon_state
	..()

atom/proc/hallucinate(var/mob/m as mob)
	var/image/hal = new /image(src.hal[src.halstate],m)
	m<<hal