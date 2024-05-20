/*
	MouseDrop:

	Called on the atom you're dragging.  In a lot of circumstances we want to use the
	recieving object instead, so that's the default action.  This allows you to drag
	almost anything into a trash can.
*/

/atom/proc/CanMouseDrop(atom/over, mob/user = usr, incapacitation_flags)
	if(!user || !over)
		return FALSE
	if(user.incapacitated(incapacitation_flags))
		return FALSE
	if(!src.Adjacent(user) || !over.Adjacent(user))
		return FALSE // should stop you from dragging through windows
	return TRUE

/atom/MouseDrop(atom/over, atom/src_location, atom/over_location, src_control, over_control, params)
	if(!usr || !over) return
	if(!Adjacent(usr) || !over.Adjacent(usr)) return // should stop you from dragging through windows

	spawn(0)
		over.MouseDrop_T(src,usr, params)
	return

// Receive a mouse drop
/atom/proc/MouseDrop_T(atom/dropping, mob/user, params)
	return

/client/MouseMove(object,location,control,params)
	if(mob && LAZYLEN(mob.mousemove_intercept_objects))
		for(var/datum/D in mob.mousemove_intercept_objects)
			D.onMouseMove(object, location, control, params)
	..()

/datum/proc/onMouseMove(object, location, control, params)
	return

/datum/proc/onMouseDrag(src_object, over_object, src_location, over_location, params, mob)
	return

/client/var/overmap_zoomout = 0
