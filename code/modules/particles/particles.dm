/particles/smoke
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("smoke_1" = 1, "smoke_2" = 1, "smoke_3" = 2)
	width = 100
	height = 100
	count = 1000
	spawning = 4
	lifespan = 1.5 SECONDS
	fade = 1 SECONDS
	velocity = list(0, 0.4, 0)
	position = list(6, 0, 0)
	drift = generator("sphere", 0, 2, NORMAL_RAND)
	friction = 0.2
	gravity = list(0, 0.95)
	grow = 0.05

/particles/smoke/burning
	position = list(0, 0, 0)

/particles/smoke/burning/small
	count = 150
	spawning = 50
	scale = list(0.8, 0.8)
	velocity = list(0, 0.4, 0)

/particles/smoke/steam/mild
	spawning = 1
	velocity = list(0, 0.3, 0)
	friction = 0.25

/particles/smoke/steam
	icon_state = list("steam_1" = 1, "steam_2" = 1, "steam_3" = 2)
	fade = 1.5 SECONDS

/particles/heat
	width = 500
	height = 500
	count = 250
	spawning = 15
	lifespan = 1.85 SECONDS
	fade = 1.25 SECONDS
	position = generator("box", list(-16, -16), list(16, 0), NORMAL_RAND)
	friction = 0.15
	gradient = list(0, COLOR_WHITE, 0.75, COLOR_ORANGE)
	color_change = 0.1
	color = 0
	gravity = list(0, 1)
	drift = generator("circle", 0.4, NORMAL_RAND)
	velocity = generator("circle", 0, 3, NORMAL_RAND)

/particles/heat/high
	count = 600
	spawning = 35

/particles/mist
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("steam_1" = 1, "steam_2" = 1, "steam_3" = 1)
	count = 500
	spawning = 7
	lifespan = 5 SECONDS
	fade = 1 SECOND
	fadein = 1 SECOND
	velocity = generator("box", list(-0.5, -0.25, 0), list(0.5, 0.25, 0), NORMAL_RAND)
	position = generator("box", list(-14, -14), list(14, 14), UNIFORM_RAND)
	friction = 0.2
	grow = 0.0015

/particles/fire_smoke
	width = 500
	height = 500
	count = 3000
	spawning = 3
	bound1 = list(-1000,0,-1000)
	bound2 = list(1000,75,1000)
	lifespan = 8
	fade = 10
	fadein = 5
	velocity = list(0, 2)
	position = list(0, 8)
	gravity = list(0, 1)
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = "smoke_3"
	position = generator("vector", list(-12,8,0), list(12,8,0))
	grow = list(0.3, 0.3)
	friction = 0.2
	drift = generator("vector", list(-0.16, -0.2), list(0.16, 0.2))
	color = "white"

/particles/fog
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("chill_1" = 2, "chill_2" = 2, "chill_3" = 1)

/particles/fog/breath
	count = 1
	spawning = 1
	lifespan = 1 SECONDS
	fade = 0.5 SECONDS
	grow = 0.05
	spin = 2
	color = "#fcffff77"

/particles/overheat_smoke
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("smoke_1" = 1, "smoke_2" = 1, "smoke_3" = 2)
	width = 25
	height = 60
	count = 1000
	spawning = 3
	lifespan = 1.5 SECONDS
	fade = 1 SECONDS
	velocity = list(0, 0.3, 0)
	position = list(8, 8)
	drift = generator("sphere", 0, 1, NORMAL_RAND)
	friction = 0.2
	gravity = list(0, 0.95)
	scale = list(0.5, 0.5)
	grow = 0.05

GLOBAL_LIST_EMPTY(blood_particles)
/particles/splatter
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	width = 500
	height = 500
	count = 20
	spawning = 20
	lifespan = 0.5 SECONDS
	fade = 0.7 SECONDS
	grow = 0.1
	scale = 0.2
	spin = generator("num", -20, 20)
	velocity = list(50, 0)
	friction = generator("num", 0.1, 0.5)
	position = generator("circle", 6, 6)

/particles/splatter/New(set_color)
	..()
	if(set_color != "red") // we're already red colored by default
		color = set_color

/particles/debris
	icon = 'icons/effects/particles/generic_particles.dmi'
	width = 500
	height = 500
	count = 10
	spawning = 10
	lifespan = 0.7 SECONDS
	fade = 0.4 SECONDS
	drift = generator("circle", 0, 7)
	scale = 0.7
	velocity = list(50, 0)
	friction = generator("num", 0.1, 0.15)
	spin = generator("num", -20, 20)

/particles/impact_smoke
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	width = 500
	height = 500
	count = 20
	spawning = 20
	lifespan = 0.7 SECONDS
	fade = 8 SECONDS
	grow = 0.1
	scale = 0.2
	spin = generator("num", -20, 20)
	velocity = list(50, 0)
	friction = generator("num", 0.1, 0.5)

/particles/firing_smoke
	icon = 'icons/effects/96x96.dmi'
	icon_state = "smoke3"
	width = 500
	height = 500
	count = 5
	spawning = 15
	lifespan = 0.5 SECONDS
	fade = 2.4 SECONDS
	grow = 0.12
	drift = generator("circle", 8, 8)
	scale = 0.1
	spin = generator("num", -20, 20)
	velocity = list(50, 0)
	friction = generator("num", 0.3, 0.6)


/particles/bonfire
	icon = 'icons/effects/particles/bonfire.dmi'
	icon_state = "bonfire"
	width = 100
	height = 100
	count = 1000
	spawning = 4
	lifespan = 0.7 SECONDS
	fade = 1 SECONDS
	grow = -0.01
	velocity = list(0, 0)
	position = generator("circle", 0, 16, NORMAL_RAND)
	drift = generator("vector", list(0, -0.2), list(0, 0.2))
	gravity = list(0, 0.95)
	scale = generator("vector", list(0.3, 0.3), list(1,1), NORMAL_RAND)
	rotation = 30
	spin = generator("num", -20, 20)
