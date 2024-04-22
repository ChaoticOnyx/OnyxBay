/atom/CtrlRightClick(mob/living/user)
	if(!istype(user))
		return ..()

	user.do_farlook(get_turf(src))
	return ..()

// Shifts client's view to selected turf. Max distance 7 tiles.
/mob/living/proc/do_farlook(turf/T)
	if(!is_view_shifted)
		if(!isturf(src.loc))
			return

		if(isnull(client))
			return

		if(stat)
			return

		var/turf/position = get_turf(src)
		var/delta_x = T.x - position.x
		var/delta_y = T.y - position.y

		var/list/view_sizes = get_view_size(client.view)
		if(abs(delta_x) > view_sizes[1] || abs(delta_y) > view_sizes[2])
			return

		if(delta_x == 0 && delta_y == 0)
			return

		register_signal(src, SIGNAL_MOVED, nameof(.proc/reset_farlook))

		face_atom(T)
		visible_message(SPAN_NOTICE("[src] peers into the distance."))
		shift_view(world.icon_size*delta_x, world.icon_size*delta_y, TRUE)
	else
		reset_farlook()

/mob/living/carbon/human/do_farlook(turf/T)
	if(machine_visual)
		return

	..(T)

/mob/living/proc/reset_farlook()
	shift_view(0, 0, TRUE)
	unregister_signal(src, SIGNAL_MOVED, nameof(.proc/reset_farlook))
