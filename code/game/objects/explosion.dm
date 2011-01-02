/client/proc/cmd_explode_turf(obj/O as turf in world)
#ifdef DEBUG
	var/A = text2num(input("Explosion"))
	explosion(O, A, A*1.5, A*2, A*3, A*3)
	//if (!usr:holder)
	//	message_admins("\red <b>Explosion spawn by [usr.client.key] blocked</b>")
	//	return

	message_admins("\red <b>Explosion spawned by [usr.client.key]</b>")
#else
	usr << "Function not available in RELEASE configuration"
#endif

proc/explosion(turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, force = 0)
	if(!epicenter)
		return
	if(!force)
		return
	spawn(0)
		if(devastation_range > 1)
			message_admins("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range]) in area [epicenter.loc.name] ")

		defer_cables_rebuild ++

		sleep(5)

		playsound(epicenter.loc, 'explosionfar.ogg', 100, 1, round(devastation_range*2,1) )
		playsound(epicenter.loc, "explosion", 100, 1, round(devastation_range,1) )


		//NEW EXPLOSION CODE - NICER (3D TOO!!) BLASTS
		//epicenter.overlays += image('status_display.dmi', "epicenter")

		var/list/fillqueue = list( )
		var/list/floordist = list( )

		var/list/detonate  = list( )
		var/list/detdists  = list( )

		var/list/checked   = list( )
		var/list/list/orderdetonate = list( )
		var/maxdet

		fillqueue += epicenter
		checked += epicenter
		floordist[epicenter] = 0

		var/obj/item/weapon/dummy/D = new /obj/item/weapon/dummy(epicenter)

		while (fillqueue.len > 0)

			var/turf/T = fillqueue[1]
			fillqueue -= T

			if ((floordist[T] > flash_range))
				continue

			if (0) //TODO replace 0 with locate() for a shield object
				//TODO damage shield
				continue

			detonate += T
			detdists[T] = floordist[T]
			if(orderdetonate["[floordist[T]]"])
				orderdetonate["[floordist[T]]"] += T
			else
				orderdetonate["[floordist[T]]"] = list ( )
				orderdetonate["[floordist[T]]"] += T
			if(floordist[T] > maxdet)
				maxdet = floordist[T]

			D.loc = T

			for(var/dir in cardinal3d) //TODO replace with "IsSameStation" checks
				var/turf/U = get_step_3d(T, dir)

				if(!U)
					continue


				var/addition = U.explosionstrength

				if (dir == DOWN)
					addition = T.floorstrength
				else if (dir == UP)
					addition = U.floorstrength

				var/newdist = floordist[T] + addition

				for(var/obj/O in U)
					if (!O.CanPass(D, T, 0, 2)) //If an object on the turf is blocking the blast wave...

						//Preblast, useful for things that may block shields but still react to them (shields)
						//Use of negative values will prevent blast damage from being simulated unintentionally
						if(floordist[T] <= devastation_range)
							O.ex_act(-3)
						else if (floordist[T] <= heavy_impact_range)
							O.ex_act(-2)
						else if (floordist[T] <= light_impact_range)
							O.ex_act(-1)

						newdist += O.explosionstrength	//Then add its explosion resistance to the distance-from-epicenter var


				if(U in checked) //Now, has this turf been looked at before?
					if (U in fillqueue)//Yes, so only compare epicenter distances
						if (newdist < floordist[U])
							//world << "reassigning dist at [U.x] [U.y] [U.z] - [newdist] < [floordist[U]]"
							floordist[U] = newdist
					else
						if (newdist < detdists[U])
							//world << "reassigning dist at [U.x] [U.y] [U.z] - [newdist] < [detdists[U]]"
							detdists[U] = newdist
				else //No, so store the current epicenter dist and mark this turf for further flood-filling
					fillqueue += U
					checked += U
					floordist[U] = newdist

				//T.overlays += image('status_display.dmi', "black")


		del D

		//for(var/turf/T in detonate)
		//	T.overlays += image('status_display.dmi', "red")
		//	var/image/I = image('status_display.dmi', "[detdists[T]]")
		//	I.pixel_x = 1
		//	I.pixel_y = -1
		//	T.overlays += I

		//return


		//OLD EXPLOSION CODE, RETROFITTED TO SUPPORT ABOVE
		var/sleep
		spawn(0)
			if(heavy_impact_range > 1)
				var/datum/effects/system/explosion/E = new/datum/effects/system/explosion()
				E.set_up(epicenter)
				E.start()

			for(var/Z = 0 to maxdet)
				if(orderdetonate["[Z]"])
					for(var/turf/T in orderdetonate["[Z]"])
						sleep += 1
						if(sleep > 20)
							sleep(15)
							sleep = 0
						var/distance = detdists[T]
						if(distance < 0)
							distance = 0
						if(distance < devastation_range)
							for(var/atom/object in T.contents)
								object.ex_act(1)
							if(prob(5))
								T.ex_act(2)
							else
								T.ex_act(1)
						else if(distance < heavy_impact_range)
							for(var/atom/object in T.contents)
								object.ex_act(2)
							T.ex_act(2)
						else if (distance == heavy_impact_range)
							for(var/atom/object in T.contents)
								object.ex_act(2)
							if(prob(15) && devastation_range > 2 && heavy_impact_range > 2)
								secondaryexplosion(T, 1)
							else
								T.ex_act(2)
						else if(distance <= light_impact_range)
							for(var/atom/object in T.contents)
								object.ex_act(3)
							T.ex_act(3)
						for(var/mob/living/carbon/mob in T)
							flick("flash", mob:flash)


			defer_cables_rebuild --
			if (!defer_cables_rebuild)
				HandleUNExplosionDamage()
	return 1



proc/secondaryexplosion(turf/epicenter, range)
	for(var/turf/tile in range(range, epicenter))
		tile.ex_act(2)