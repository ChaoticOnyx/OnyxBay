///This proc throws up either an icon or an animation for a specified amount of time.
/proc/anim(turf/location, atom/target, a_icon, a_icon_state, flick_anim, sleeptime = 15, direction, name, lay, offX, offY, col, alph, plane, trans, invis, animate_movement)
	if(!location && target)
		location = get_turf(target)
	if(location && !target)
		target = location
	if(!location && !target)
		return
	var/atom/movable/fake_overlay/animation = new /atom/movable/fake_overlay(location)
	if(name)
		animation.name = name
	if(direction)
		animation.dir = direction
	if(alph)
		animation.alpha = alph
	if(invis)
		animation.invisibility = invis
	animation.icon = a_icon
	animation.animate_movement = animate_movement
	animation.mouse_opacity = 0
	if(!lay)
		animation.layer = target.layer + 0.1
	else
		animation.layer = lay
	if(target && istype(target, /atom))
		if(!plane)
			animation.plane = target.plane
		else
			animation.plane = plane
	if(offX)
		animation.pixel_x = offX
	if(offY)
		animation.pixel_y = offY
	if(col)
		animation.color = col
	if(trans)
		animation.transform = trans
	if(a_icon_state)
		animation.icon_state = a_icon_state
	else
		animation.icon_state = "blank"
		animation.master = target
		flick(flick_anim, animation)

	QDEL_IN(animation, max(sleeptime, 15))
	return animation
