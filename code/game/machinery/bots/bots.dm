// AI (i.e. game AI, not the AI player) controlled bots

/obj/machinery/bot
	icon = 'aibots.dmi'
	layer = MOB_LAYER
	var/obj/item/weapon/card/id/botcard			// the ID card that the bot "holds"
	var/on = 1
	var/list/path = new				// list of path turfs

/obj/machinery/bot/proc/CloseDoor(var/obj/machinery/door/D, var/atom/L)
	set background = 1
	while(src.loc == L)
		sleep(10)
		continue
	D.close()

/obj/machinery/bot/process()
	if (!src.on)
		return

// calculates a path to the specified destination
// given an optional turf to avoid
/obj/machinery/bot/proc/calc_path(dest, var/turf/avoid = null)
	path = AStar(src.loc, dest, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 120, id=botcard, exclude=list(/obj/landmark/alterations/nopath, avoid))
	path = reverselist(src.path)