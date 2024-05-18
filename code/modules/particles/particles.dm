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
	lifespan = 20
	fade = 30
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

/particles/rain
	width = 672
	height = 480
	count = 2500    // 2500 particles
	spawning = 48
	bound1 = list(-1000, -240, -1000)   // end particles at Y=-240
	lifespan = 60 SECONDS
	fade = 35       // fade out over the last 3.5s if still on screen
	icon = 'icons/effects/particles/weather.dmi'
	icon_state = "rain_small"
	position = generator("box", list(-300,50,0), list(300,300,50))
	gravity = list(0, -3)
	friction = 0.05
	drift = generator("sphere", 0, 1)

/particles/rain/dense
	spawning = 60

/particles/rain/sideways
	rotation = generator("num", -10, -20 )
	gravity = list(0.4, -3)
	drift = generator("box", list(0.1, -1, 0), list(0.4, 0, 0))

/particles/rain/sideways/tile
	count = 5
	spawning = 1.1
	fade = 5
	lifespan = generator("num", 4, 6, LINEAR_RAND)
	position = generator("box", list(-96,32,0), list(300,64,50))
	bound1 = list(-32, -48, -1000)
	bound2 = list(32, 64, 1000)
	// Start up initial speed and gain for tile based emitter due to shorter travel (acceleration)
	gravity = list(0.4*3, -3*3)
	drift = generator("box", list(0.1, -1*2, 0), list(0.4*2, 0, 0))
	width = 96
	height = 96
