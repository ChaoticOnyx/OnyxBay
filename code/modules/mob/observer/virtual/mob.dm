/mob/observer/virtual/mob
	host_type = /mob

/mob/observer/virtual/mob/New(location, mob/host)
	..()

	register_signal(host, SIGNAL_SIGHT_SET, /mob/observer/virtual/mob/proc/sync_sight)
	register_signal(host, SIGNAL_SEE_INVISIBLE_SET, /mob/observer/virtual/mob/proc/sync_sight)
	register_signal(host, SIGNAL_SEE_IN_DARK_SET, /mob/observer/virtual/mob/proc/sync_sight)

	sync_sight(host)

/mob/observer/virtual/mob/Destroy()
	unregister_signal(host, SIGNAL_SIGHT_SET)
	unregister_signal(host, SIGNAL_SEE_INVISIBLE_SET)
	unregister_signal(host, SIGNAL_SEE_IN_DARK_SET)

	. = ..()

/mob/observer/virtual/mob/proc/sync_sight(mob/mob_host)
	sight = mob_host.sight
	see_invisible = mob_host.see_invisible
	see_in_dark = mob_host.see_in_dark
