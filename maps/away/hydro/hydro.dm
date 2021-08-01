#include "hydro_areas.dm"

// Map setup //
/obj/effect/shuttle_landmark/nav_hydro/nav1
	name = "Navpoint Fore"
	landmark_tag = "nav_hydro_1"

/obj/effect/shuttle_landmark/nav_hydro/nav2
	name = "Navpoint Starboard"
	landmark_tag = "nav_hydro_2"

/obj/effect/shuttle_landmark/nav_hydro/nav3
	name = "Navpoint Aft"
	landmark_tag = "nav_hydro_3"

// Objs //
/obj/structure/closet/secure_closet/hydroponics/hydro
	name = "hydroponics supplies locker"
	req_access = list()

/obj/item/projectile/beam/drone/weak
	damage = 5 //1/3rd of regular projectile

// Mobs //
/mob/living/simple_animal/hostile/retaliate/goat/king/hydro //these goats are powerful but are not the king of goats
	name = "strange goat"
	desc = "An impressive goat, in size and coat. His horns look pretty serious!"
	health = 350
	maxHealth = 350
	melee_damage_lower = 20
	melee_damage_upper = 45
	faction = "farmbots"

/mob/living/simple_animal/hostile/retaliate/malf_drone/hydro
	name = "Farmbot"
	desc = "The botanist's best friend. There's something slightly odd about the way it moves."
	icon = 'maps/away/hydro/hydro.dmi'
	speak = list("Initiating harvesting subrout-ine-ine.", "Connection timed out.", "Connection with master AI syst-tem-tem lost.", "Core systems override enab-...")
	emote_see = list("beeps repeatedly", "whirrs violently", "flashes its indicator lights", "emits a ping sound")
	icon_state = "farmbot"
	icon_living = "farmbot"
	icon_dead = "farmbot_dead"
	faction = "farmbots"
	rapid = 0
	health = 200
	maxHealth = 200
	malfunctioning = 0

/mob/living/simple_animal/hostile/retaliate/malf_drone/hydro/Initialize()
	. = ..()
	if(prob(15))
		projectiletype = /obj/item/projectile/beam/drone/weak

/mob/living/simple_animal/hostile/retaliate/malf_drone/hydro/emp_act(severity)
	health -= rand(5,10) * (severity + 1)
	disabled = rand(15, 30)
	malfunctioning = 1
	hostile_drone = 1
	destroy_surroundings = 1
	projectiletype = initial(projectiletype)
	walk(src,0)

/mob/living/simple_animal/hostile/retaliate/malf_drone/hydro/ListTargets()
	if(hostile_drone)
		return view(src, 3)
	else
		return ..()
