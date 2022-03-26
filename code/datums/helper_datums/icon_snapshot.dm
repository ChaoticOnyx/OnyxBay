/datum/icon_snapshot
	var/real_name
	var/name
	var/examine
	var/icon
	var/icon_state
	var/stand_icon
	var/list/overlays
	var/list/overlays_standing

/datum/icon_snapshot/proc/makeImg()
	if(!icon || !icon_state)
		return
	var/obj/temp = new
	temp.icon = icon
	temp.icon_state = icon_state
	temp.overlays = overlays.Copy()
	var/icon/tempicon = getFlatIcon(temp) // TODO Actually write something less heavy-handed for this
	return tempicon
