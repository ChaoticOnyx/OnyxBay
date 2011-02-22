/obj/machinery/bot/lightbot
	name = "LightBot"
	desc = "A little light replace robot, he looks so gloomy!"
	icon = 'aibots.dmi'
	icon_state = "floorbot0"
	layer = 5.0
	density = 0
	anchored = 0
	//weight = 1.0E7
	var/amount = 10
	var/locked = 1
	var/obj/machinery/light/target
	var/obj/machinery/light/oldtarget
	var/lightbulbs = 40
	var/working = 0
	var/oldloc = null
	req_access = list(access_atmospherics)
/obj/machinery/bot/lightbot/process()
	if(path.len <= 0 && !target)
		var/list/targets = list()
		for(var/obj/machinery/light/T in oview(src))
			if(target != oldtarget && target.loc != src.loc)
				targets += T
		target = locate() in targets
		if(target && target != oldtarget)
			src.path = AStar(src.loc, src.target.loc, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 120, id=botcard, exclude=list(/obj/landmark/alterations/nopath))
			world << "found light"
		else
			return // This should happen...
	else if(target.loc == src.loc)
		checklight()
		return
	else if(src.path.len > 0 && src.target && (src.target != null))
		step_towards_3d(src, src.path[1])
		src.path -= src.path[1]
		return
	else if(src.path.len == 1)
		step_towards_3d(src, target)
		src.path = new()
		return
/obj/machinery/bot/lightbot/proc/checklight()
	if(!target)
		return
	if(target.status)
		target.status = 1
		target.switchcount = 0
		target.update()
	for(var/mob/O in viewers(src, null))
		O.show_message(text("[src] emits a high squeal as it devours the lightblub"), 1)
	if(target.status == 1)
		target.status = 1
	for(var/mob/O in viewers(src, null))
		O.show_message(text("[src] emits a high statsifactory beep."), 1)
	oldtarget = target
	target = null
	path = new()
