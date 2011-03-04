var/list/anomalyeffects = list("heal"=2,"hurt"=2, list("march" = 1,"repel"=1,"tele"=2)=4)


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
		if(!CanAnom(ob))
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
