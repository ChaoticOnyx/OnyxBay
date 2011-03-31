var/list/anomalyeffects = list("emp" = 2, "heal"=2,"hurt"=2, list("march" = 1,"repel"=1,"tele"=2)=4)


/datum/anomalyeffect
	var/effectname
	var/obj/o
	var/range
	var/magnitude
	var/cooldown
	var/fluff
	var/rarity = 1

/datum/anomalyeffect/New()
	src.range = rand(1,10)
	src.magnitude = rand(10,50)
	src.CalcCooldown()


/datum/anomalyeffect/proc/CalcCooldown()


/datum/anomalyeffect/proc/Activate()


/datum/anomalyeffect/heal
	effectname = "heal"
	fluff = "Biological stabiliser field."

/datum/anomalyeffect/hurt
	effectname = "hurt"
	fluff = "Biological destabiliser field."

/datum/anomalyeffect/emp
	effectname = "emp"
	fluff = "Electro Magnetic Pulse."

/datum/anomalyeffect/tele
	effectname = "tele"
	fluff = "Spatial displacement field."
	rarity = 2

/datum/anomalyeffect/march
	effectname = "march"
	fluff = "Spatial attraction field."
	rarity = 2
	var/dur

/datum/anomalyeffect/repel
	effectname = "repel"
	fluff = "Spatial repulsion field."
	rarity = 2
	var/dur




/datum/anomalyeffect/tele/CalcCooldown()
	src.cooldown = src.magnitude*2+src.range

/datum/anomalyeffect/heal/Activate()
	for(var/mob/living/carbon/m in range(src.range,get_turf(src.o)))
		if(!CanAnom(m))
			continue
		for(var/t in m.organs)
			var/datum/organ/external/affecting = m.organs["[t]"]
			if (affecting.heal_damage(src.magnitude/16, src.magnitude/8))
				m.UpdateDamageIcon()
			else
				m.UpdateDamage()
		m.oxyloss = max(0.0,m.oxyloss-src.magnitude)
		m.toxloss = max(0.0,m.toxloss-src.magnitude)
		m.fireloss = max(0.0,m.fireloss-src.magnitude)
		m.bruteloss = max(0.0,m.bruteloss-src.magnitude)
		m.health = min(m.health_full,m.health+src.magnitude)
		m.updatehealth()
		m << "\blue You feel a tingling sensation."


/datum/anomalyeffect/emp/Activate()
	playsound(o.loc, 'Welder2.ogg', 25, 1)
	var/turf/T = get_turf(o)
	if(T)
		T.hotspot_expose(SPARK_TEMP,125)

	var/obj/overlay/pulse = new/obj/overlay ( T )
	pulse.icon = 'effects.dmi'
	pulse.icon_state = "emppulse"
	pulse.name = "emp pulse"
	pulse.anchored = 1
	spawn(20)
		del(pulse)

	for(var/obj/item/weapon/W in range(range, T))

		if (istype(W, /obj/item/assembly/m_i_ptank) || istype(W, /obj/item/assembly/r_i_ptank) || istype(W, /obj/item/assembly/t_i_ptank))

			var/fuckthis
			if(istype(W:part1,/obj/item/weapon/tank/plasma))
				fuckthis = W:part1
				fuckthis:ignite()
			if(istype(W:part2,/obj/item/weapon/tank/plasma))
				fuckthis = W:part2
				fuckthis:ignite()
			if(istype(W:part3,/obj/item/weapon/tank/plasma))
				fuckthis = W:part3
				fuckthis:ignite()


	for(var/mob/living/M in viewers(range, T))

		if(!istype(M, /mob/living)) continue

		if (istype(M, /mob/living/silicon))
			M.fireloss += 25
			flick("noise", M:flash)
			M << "\red <B>*BZZZT*</B>"
			M << "\red Warning: Electromagnetic pulse detected."
			if(istype(M, /mob/living/silicon/ai))
				if (prob(30))
					switch(pick(1,2,3)) //Add Random laws.
						if(1)
							M:cancel_camera()
						if(2)
							M:lockdown()
						if(3)
							M:ai_call_shuttle()
			continue


		M << "\red <B>Your equipment malfunctions.</B>" //Yeah, i realise that this WILL
														//show if theyre not carrying anything
														//that is affected. lazy.
		if (locate(/obj/item/weapon/cloaking_device, M))
			for(var/obj/item/weapon/cloaking_device/S in M)
				S.active = 0
				S.icon_state = "shield0"

		if (locate(/obj/item/weapon/gun/energy, M))
			for(var/obj/item/weapon/gun/energy/G in M)
				G.charges = 0
				G.update_icon()

		if ((istype(M, /mob/living/carbon/human)) && (istype(M:glasses, /obj/item/clothing/glasses/thermal)))
			M << "\red <B>Your thermals malfunction.</B>"
			M.eye_blind = 3
			M.eye_blurry = 5
			M.disabilities |= 1
			spawn(100)
				M.disabilities &= ~1

		if (locate(/obj/item/device/radio, M))
			for(var/obj/item/device/radio/R in M) //Add something for the intercoms.
				R.broadcasting = 0
				R.listening = 0

		if (locate(/obj/item/device/flash, M))
			for(var/obj/item/device/flash/F in M) //Add something for the intercoms.
				F.attack_self()

		if (locate(/obj/item/weapon/baton, M))
			for(var/obj/item/weapon/baton/B in M) //Add something for the intercoms.
				B.charges = 0

		if(locate(/obj/item/clothing/under/chameleon, M))
			for(var/obj/item/clothing/under/chameleon/C in M) //Add something for the intercoms.
				M << "\red <B>Your jumpsuit malfunctions</B>"
				C.name = "psychedelic"
				C.desc = "Groovy!"
				C.icon_state = "psyche"
				C.color = "psyche"
				spawn(200)
					C.name = "Black Jumpsuit"
					C.icon_state = "bl_suit"
					C.color = "black"
					C.desc = null

		M << "\red <B>BZZZT</B>"


	for(var/obj/machinery/A in range(range, T))
		A.use_power(7500)

		var/obj/overlay/pulse2 = new/obj/overlay ( A.loc )
		pulse2.icon = 'effects.dmi'
		pulse2.icon_state = "empdisable"
		pulse2.name = "emp sparks"
		pulse2.anchored = 1
		pulse2.dir = pick(cardinal)

		spawn(10)
			del(pulse2)

		if(istype(A, /obj/machinery/turret))
			A:enabled = 0
			A:lasers = 0
			A:power_change()

		if(istype(A, /obj/machinery/computer) && prob(20))
			A:set_broken()

		if(istype(A, /obj/machinery/firealarm) && prob(50))
			A:alarm()

		if(istype(A, /obj/machinery/power/smes))
			A:online = 0
			A:charging = 0
			A:output = 0
			A:charge -= 1e6
			if (A:charge < 0)
				A:charge = 0
			spawn(100)
				A:output = initial(A:output)
				A:charging = initial(A:charging)
				A:online = initial(A:online)

		if(istype(A, /obj/machinery/door))
			if(prob(20) && (istype(A,/obj/machinery/door/airlock) || istype(A,/obj/machinery/door/window)) )
				A:open()
			if(prob(40))
				if(A:secondsElectrified != 0) continue
				A:secondsElectrified = -1
				spawn(300)
					A:secondsElectrified = 0

		if(istype(A, /obj/machinery/power/apc))
			if(A:cell)
				A:cell:charge -= 1000
				if (A:cell:charge < 0)
					A:cell:charge = 0
			A:lighting = 0
			A:equipment = 0
			A:environ = 0
			spawn(600)
				A:equipment = 3
				A:environ = 3

		if(istype(A, /obj/machinery/camera))
			A.icon_state = "cameraemp"
			A:network = null                   //Not the best way but it will do. I think.

			var/initial_status = A:status	   //So that motion cameras get disabled and won't send any messages when EMPed
			A:status = 0

			spawn(900)
				A:network = initial(A:network)
				A:icon_state = initial(A:icon_state)
				A:status = initial_status
			for(var/mob/living/silicon/ai/O in world)
				if (O.current == A)
					O.cancel_camera()
					O << "Your connection to the camera has been lost."
			for(var/mob/O in world)
				if (istype(O.machine, /obj/machinery/computer/security))
					var/obj/machinery/computer/security/S = O.machine
					if (S.current == A)
						O.machine = null
						S.current = null
						O.reset_view(null)
						O << "The screen bursts into static."

		if(istype(A, /obj/machinery/clonepod))
			A:malfunction()

	for(var/obj/shielding/shield/S in range(range, T))
		S.disabled = 1
		var/obj/overlay/pulse2 = new/obj/overlay ( S.loc )
		pulse2.icon = 'effects.dmi'
		pulse2.icon_state = "empdisable"
		pulse2.name = "emp sparks"
		pulse2.anchored = 1
		pulse2.dir = pick(cardinal)
		S.density = 0
		S.invisibility = 101
		S.explosionstrength = 0
		spawn(40)
			del(pulse2)
		spawn(500)
			if(S)
				S.disabled = 0

	return




/datum/anomalyeffect/hurt/Activate()
	for(var/mob/living/carbon/m in range(src.range,get_turf(src.o)))
		if(!CanAnom(m))
			continue
		for(var/t in m.organs)
			var/datum/organ/external/affecting = m.organs["[t]"]
			if(rand(1))
				if (affecting.take_damage(src.magnitude/16, src.magnitude/8,0,0))
					m.UpdateDamageIcon()
				else
					m.UpdateDamage()

		m.updatehealth()
		m << "\red You feel a searing pain."





/datum/anomalyeffect/march/Activate()
	var/turf/centre = get_turf(src.o)
	var/list/atom/A = list()
	for(var/mob/living/carbon/m in range(src.range,centre))
		if(!CanAnom(m)||m == o||o.loc==m)
			continue
		if(m.buckled)
			if(m.buckled.CanAnom()&&!m.buckled.anchored)
				A.Add(m)
		else
			A.Add(m)
			m<<"\blue You feel a compulsion to walk."
	for(var/obj/ob in range(src.range,centre))
		if(!CanAnom(ob))
			continue
		if(get_dist(ob,o)==0)
			if(FindRecursive(o,ob))
				continue
		if(!ob.anchored)
			A.Add(ob)

	spawn(10)
		dur=round(magnitude/5)+1

		while(dur)
			sleep(-1)
			for(var/atom/a in A)
				if(istype(a,/mob))
					if(!rand(2))
						a:say("*shake")
						a<<"You free yourself from the force's grasp!"
						A.Remove(A)
				step_to(a,get_turf(o))
			dur-=1
			sleep(10)





/datum/anomalyeffect/repel/Activate()
	var/turf/centre = get_turf(src.o)
	var/list/atom/A = list()
	for(var/mob/living/carbon/m in range(src.range,centre))
		if(!CanAnom(m)||m == o||o.loc==m)
			continue
		if(m.buckled)
			if(m.buckled.CanAnom()&&!m.buckled.anchored)
				A.Add(m)
		else
			A.Add(m)
			m<<"\blue You feel a compulsion to walk."
	for(var/obj/ob in range(src.range,centre))
		if(!CanAnom(ob)||ob==o)
			continue
		if(get_dist(ob,o)==0)
			if(FindRecursive(o,ob))
				continue
		if(!ob.anchored)
			A.Add(ob)

	spawn(10)
		dur=round(magnitude/5)+1

		while(dur)
			sleep(-1)
			for(var/atom/a in A)
				if(istype(a,/mob))
					if(!rand(2))
						a:say("*shake")
						a<<"You free yourself from the force's grasp!"
						A.Remove(A)
				step_away(a,get_turf(o))
			dur-=1
			sleep(10)



/datum/anomalyeffect/tele/Activate()
	var/turf/centre = get_turf(src.o)
	var/list/mob/living/carbon/ms = list()
	for(var/mob/living/carbon/m in range(src.range,centre))
		if(!CanAnom(m))
			continue
		if(m.buckled)
			if(!m.buckled.anchored)
				ms.Add(m)
		else
			ms.Add(m)
	for(var/mob/living/carbon/m in ms)
		var/turf/t = get_turf(pick(range(src.magnitude/5,m)))
		if(!istype(t,/turf/))
			break
		m.loc = t
		var/turf/nt = get_turf(m)
		var/n = nt.loc.name
		m << "\blue You suddenly appear in \the [n]."
		ms.Remove(m)
	if(src.magnitude>35)
		for(var/obj/o in range(src.range,centre))
			if(!CanAnom(o))
				continue
			if(!o.anchored && !rand(0,2))
				var/turf/t = get_turf(pick(range(src.magnitude/10,centre)))
				o.loc = t
