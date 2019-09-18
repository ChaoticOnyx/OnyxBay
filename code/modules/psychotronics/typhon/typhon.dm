/mob/living/typhon
	name = "Typhon"
	real_name = "Typhon"
	icon = 'icons/mob/typhon.dmi'
	health = 25
	maxHealth = 25

	var
		evolution_points = 0
		max_epoints = 500
		sounds = list()
		abilitiesCooldown = list()

	New()
		..()

		if (type == /mob/living/typhon)
			TransformToMimic()

	update_icon()
		return

	Life()
		..()

		update_icon()

		if (evolution_points < max_epoints)
			evolution_points++

	proc
		TransformToMimic()
			if (type == /mob/living/typhon/mimic)
				return

			var/mob/living/typhon/mimic/M = new(src.loc)

			M.evolution_points = evolution_points

			if (client)
				M.client = client

			qdel(src)

		TransformToPhantom()
			if (type == /mob/living/typhon/phantom)
				return

			var/mob/living/typhon/phantom/basic/P = new(src.loc)

			P.evolution_points = evolution_points

			if (client)
				P.client = client

			qdel(src)

/mob/living/typhon/mimic
	name = "Mimic"
	real_name = "Mimic"
	icon_state = "mimic"

	sounds = list(
		"onsight" = list(
			'sound/effects/typhon/mimic/onsight_1.ogg',
			'sound/effects/typhon/mimic/onsight_2.ogg',
			'sound/effects/typhon/mimic/onsight_3.ogg',
			'sound/effects/typhon/mimic/onsight_4.ogg',
			'sound/effects/typhon/mimic/onsight_5.ogg',
			'sound/effects/typhon/mimic/onsight_6.ogg',
			'sound/effects/typhon/mimic/onsight_7.ogg',
			'sound/effects/typhon/mimic/onsight_8.ogg',
			'sound/effects/typhon/mimic/onsight_9.ogg',
			'sound/effects/typhon/mimic/onsight_10.ogg',
			'sound/effects/typhon/mimic/onsight_11.ogg',
			'sound/effects/typhon/mimic/onsight_12.ogg',
			'sound/effects/typhon/mimic/onsight_13.ogg',
		),
		"drain" = list(
			'sound/effects/typhon/mimic/drain_1.ogg',
			'sound/effects/typhon/mimic/drain_2.ogg',
			'sound/effects/typhon/mimic/drain_3.ogg',
			'sound/effects/typhon/mimic/drain_4.ogg'
		),
		"ondrain" = list(
			'sound/effects/typhon/mimic/ondrain_1.ogg',
			'sound/effects/typhon/mimic/ondrain_2.ogg',
			'sound/effects/typhon/mimic/ondrain_3.ogg'
		)
	)

	Bump(atom/user)
		if (istype(user, /obj/structure/table) || istype(user, /mob/living/))
			src.loc = user.loc
		else
			..()

	can_ventcrawl()
		return TRUE

	Stat()
		if (statpanel("Status"))
			stat("Evolution Points", evolution_points)

	update_icon()
		icon_state = "mimic"

	New()
		..()

		verbs += list(
			/mob/living/proc/ventcrawl,
			/mob/living/typhon/proc/Drain
		)

		playsound(src, pick(sounds["onsight"]), 20, 1)

/mob/living/typhon/phantom
	health = 100
	maxHealth = 100
	icon_state = "phantom_basic"

	can_ventcrawl()
		return FALSE

	update_icon()
		icon_state = "phantom_basic"

	New()
		..()

		if (type == /mob/living/typhon/phantom)
			TransformToPhantom()

/mob/living/typhon/phantom/basic
	New()
		..()
