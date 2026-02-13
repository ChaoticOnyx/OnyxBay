
//Overlays
/atom/movable/fake_overlay
	var/atom/master = null
	anchored = 1

/atom/movable/fake_overlay/New()
	src.verbs.Cut()
	..()

/atom/movable/fake_overlay/Destroy()
	master = null
	. = ..()

/atom/movable/fake_overlay/attackby(a, b)
	if (src.master)
		return src.master.attackby(a, b)
	return

/atom/movable/fake_overlay/attack_hand(a, b, c)
	if (src.master)
		return src.master.attack_hand(a, b, c)
	return
