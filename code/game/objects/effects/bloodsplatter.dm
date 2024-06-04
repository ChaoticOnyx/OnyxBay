/obj/effect/temporary/bloodsplatter
	icon = 'icons/effects/blood.dmi'
	layer = ABOVE_HUMAN_LAYER
	alpha = 175
	var/splatter_type = "splatter"

/obj/effect/temporary/bloodsplatter/Initialize(mapload, duration = 30, _icon = 'icons/effects/blood.dmi', _state, angle, blood_color)
	if(!blood_color)
		CRASH("Tried to create a blood splatter without a blood_color")

	var/x_component = sin(angle) * -15
	var/y_component = cos(angle) * -15
	if(!GLOB.blood_particles[blood_color])
		GLOB.blood_particles[blood_color] = new /particles/splatter(blood_color)
	particles = GLOB.blood_particles[blood_color]
	particles.velocity = list(x_component, y_component)
	color = blood_color
	icon_state = "[splatter_type][pick(1, 2, 3, 4, 5, 6)]"

	. = ..() // Yes, i'm a moron

	var/target_pixel_x = 0
	var/target_pixel_y = 0
	switch(angle)
		if(0, 360)
			target_pixel_x = 0
			target_pixel_y = 8
		if(1 to 44)
			target_pixel_x = round(4 * ((angle) / 45))
			target_pixel_y = 8
		if(45)
			target_pixel_x = 8
			target_pixel_y = 8
		if(46 to 89)
			target_pixel_x = 8
			target_pixel_y = round(4 * ((90 - angle) / 45))
		if(90)
			target_pixel_x = 8
			target_pixel_y = 0
		if(91 to 134)
			target_pixel_x = 8
			target_pixel_y = round(-3 * ((angle - 90) / 45))
		if(135)
			target_pixel_x = 8
			target_pixel_y = -6
		if(136 to 179)
			target_pixel_x = round(4 * ((180 - angle) / 45))
			target_pixel_y = -6
		if(180)
			target_pixel_x = 0
			target_pixel_y = -6
		if(181 to 224)
			target_pixel_x = round(-6 * ((angle - 180) / 45))
			target_pixel_y = -6
		if(225)
			target_pixel_x = -6
			target_pixel_y = -6
		if(226 to 269)
			target_pixel_x = -6
			target_pixel_y = round(-6 * ((270 - angle) / 45))
		if(270)
			target_pixel_x = -6
			target_pixel_y = 0
		if(271 to 314)
			target_pixel_x = -6
			target_pixel_y = round(8 * ((angle - 270) / 45))
		if(315)
			target_pixel_x = -6
			target_pixel_y = 8
		if(316 to 359)
			target_pixel_x = round(-6 * ((360 - angle) / 45))
			target_pixel_y = 8

	animate(src, pixel_x = target_pixel_x, pixel_y = target_pixel_y, alpha = 0, time = duration)
