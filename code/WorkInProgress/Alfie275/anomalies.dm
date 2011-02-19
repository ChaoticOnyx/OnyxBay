proc/varcopy(var/datum/d)
	var/datum/nd = new d.type
	for(var/v in d.vars)
		if(!v=="type")
			var/nv = d.vars["[v]"]
			nd.vars["[v]"] = nv
	return nd



var/list/artifacts = list("/obj/item/weapon/crystal" = 4,
							"/obj/item/weapon/talkingcrystal" = 2,
							"/obj/item/weapon/fossil/base" =8,
							"/obj/item/weapon/anomaly"=1 )
var/list/anomalyeffects = list("heal"=2,"hurt"=2,"tele"=1)
var/list/anomalyrare = list()
var/list/anomalies = list()


proc/SetupAnomalies()
	var/list/l = list(0,1,2,3)
	for(var/r = 0 to 3)
		var/i = pick(l)
		l.Remove(i)
		var/datum/anomaly/a = new/datum/anomaly(i)
		a.trigger = rand(0)
		var/e = pickweight(anomalyeffects)
		var/npath = text2path("/datum/anomalyeffect/[e]")
		var/datum/anomalyeffect/t = new npath
		for(var/v in anomalyeffects)
			anomalyeffects[v]+=t.rarity
		anomalyeffects[e]-=t.rarity
		anomalyrare["[t.effectname]+[t.range]+[t.magnitude]"] = 1


		a.e = t

		anomalies["[t.effectname]+[t.range]+[t.magnitude]"] = a
	for(var/datum/anomaly/a in anomalies)
		for(var/v in anomalyrare)
			anomalyrare[v]+=a.e.rarity
		anomalyrare["[a.e.effectname]+[a.e.range]+[a.e.magnitude]"]-=a.e.rarity


/obj/item/weapon/artifact
	name = "Strange rock"
	icon = 'rubble.dmi'
	icon_state = "strange"
	var/obj/inside
	var/method // 0 = fire 1+ = acid
	var/rock = 10
	var/ahealth = 10

	New()
		var/datum/reagents/r = new/datum/reagents(50)
		src.reagents = r
		r.my_atom = src
		if(rand(3))
			src.method = 0
		else
			src.method = 1
		src.inside = pickweight(artifacts)

/obj/item/weapon/anomaly
	name = "Anomaly"
	var/id
	var/trigger
	var/cooldown
	var/datum/anomalyeffect/e
	icon = 'anomaly.dmi'

/obj/item/weapon/anomaly/New()
	if(anomalyrare.len)
		var/anoname = pickweight(anomalyrare)
		var/datum/anomaly/a = anomalies["[anoname]"]
		src.trigger = a.trigger
		src.e = new a.e.type
		src.e.o = src
		src.e.range = a.e.range + rand(-(max(a.e.range/10,1)),max(a.e.range/10,1))
		src.e.magnitude = a.e.magnitude+ rand(-(max(a.e.range/10,1)),max(a.e.range/10,1))
		src.e.CalcCooldown()
		src.icon_state = "ano[a.id]"
	else
		spawn(0) src.New()

/obj/item/weapon/anomaly/process()
	if(src.cooldown)
		src.cooldown--
		if(!src.cooldown)
			for(var/mob/m in hearers(get_turf(src)))
				var/t = pick("chimes","pings","buzzes")
				m<<"The [src.name] [t]"
				processing_items.Remove(src)

/obj/item/weapon/anomaly/proc/Activate()
	if(!cooldown)
		src.e.Activate()
		src.cooldown=src.e.cooldown
		processing_items.Add(src)


/obj/item/weapon/anomaly/attack_hand(var/mob/living/carbon/m as mob)
	if(!m.gloves)
		src.Activate()
	..()

/datum/anomaly
	var/id
	var/trigger
	var/datum/anomalyeffect/e

	New(var/id)
		src.id = id

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



/datum/anomalyeffect/tele/CalcCooldown()
	src.cooldown = src.magnitude*2+src.range

/datum/anomalyeffect/heal/Activate()
	for(var/mob/living/carbon/m in range(src.range,get_turf(src.o)))
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
		for(var/t in m.organs)
			var/datum/organ/external/affecting = m.organs["[t]"]
			if(rand(1))
				if (affecting.take_damage(src.magnitude/16, src.magnitude/8,0,0))
					m.UpdateDamageIcon()
				else
					m.UpdateDamage()

		m.updatehealth()
		m << "\red You feel a searing pain."

/datum/anomalyeffect/tele/Activate()
	var/turf/centre = get_turf(src.o)
	var/list/mob/living/carbon/ms = list()
	for(var/mob/living/carbon/m in range(src.range,centre))
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
			if(!o.anchored & !rand(2))
				var/turf/t = get_turf(pick(range(src.magnitude/10,src.o)))
				o.loc = t

/obj/item/weapon/talkingcrystal
	name = "Crystal"
	icon = 'rubble.dmi'
	icon_state = "crystal2"
	var/list/words = list()
	var/lastsaid
/obj/item/weapon/talkingcrystal/New()
	..()
	processing_items += src
	return
/obj/item/weapon/talkingcrystal/catchMessage(msg,mob/source)
	var/done = 1
	while(done)
		var/loc = findtext(msg," ",1,0)
		if(!loc)
			done = 0
		var/X = copytext(msg,1,loc)
		if(!words.Find(X,1,0))
			x = replace(x," ","")
			words += X
		msg = copytext(msg,loc+1,0)
	for(var/mob/O in viewers(src))
		O.show_message("\blue The crystal hums for bit then stops...", 1)
/obj/item/weapon/talkingcrystal/proc/SaySomething()
	var/msg
	var/list/prevwords = list()
	var/limit = rand(7)
	for(var/y,y <= limit,y++)
		var/text = " [pick(words)]"
		if(!prevwords.Find(text))
			msg += text
			prevwords += text
			continue
		else
			continue
	for(var/mob/M in viewers(src))
		M << "\blue You hear \"[msg]\" from the [src]"
	lastsaid = world.timeofday + rand(900,1600)
/obj/item/weapon/talkingcrystal/process()
	if(prob(25) && world.timeofday >= lastsaid && words.len >= 1)
		SaySomething()



/obj/item/weapon/artifact/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/weldingtool/))
		if(src.method)
			src.ahealth -= 3
			for(var/mob/O in viewers(world.view, user))
				O.show_message("\red A hissing sound comes from within the rock.", 1)
		else
			src.rock -= 3
			for(var/mob/O in viewers(world.view, user))
				O.show_message("\blue The surface of the rock burns a little.",1)
	if(src.ahealth<1)
		for(var/mob/O in viewers(world.view, user))
			O.show_message("\red The rock explodes.",1)
		var/turf/t = find_loc(src)
		t.hotspot_expose(SPARK_TEMP,125)
		explosion(t, -1, -1, 5, 3, 1)
		del src
	if(src.rock<1)
		var/obj/o = new src.inside
		o.loc = get_turf(src)
		for(var/mob/O in viewers(world.view, user))
			O.show_message("\blue The rock burns away revealing \a [o.name].",1)
		del src


/obj/item/weapon/artifact/proc/acid(var/volume)
	if(!src.method)
		src.ahealth -= volume
		for(var/mob/O in viewers(world.view, get_turf(src)))
			O.show_message("\red A fizzing sound comes from within the rock.",1)
	else
		src.rock -= volume
		for(var/mob/O in viewers(world.view, get_turf(src)))
			O.show_message("\blue The surface of the rock fizzes.",1)

	if(src.ahealth<1)
		for(var/mob/O in viewers(world.view, get_turf(src)))
			O.show_message("\red The rock collapses.",1)
		new/obj/item/weapon/ore(get_turf(src))
		del src
	if(src.rock<1)
		var/obj/o = new src.inside
		o.loc = get_turf(src)
		for(var/mob/O in viewers(world.view, get_turf(src)))
			O.show_message("\blue The rock fizzes away revealing \a [o.name].",1)

		del src



/obj/item/weapon/crystal
	name = "Crystal"
	icon = 'rubble.dmi'
	icon_state = "crystal"
	desc = "A beautiful crystal."

/obj/item/weapon/fossil
	name = "Fossil"
	icon = 'fossil.dmi'
	icon_state = "bone"
	desc = "It's a fossil."



/obj/item/weapon/fossil/base/New()
	spawn(0)
		var/list/l = list("/obj/item/weapon/fossil/bone"=4,"/obj/item/weapon/fossil/skull"=2,
		"/obj/item/weapon/fossil/skull/horned"=2,"/obj/item/weapon/fossil/shell"=1)
		var/t = pickweight(l)
		new t(src.loc)
		del src




/obj/item/weapon/fossil/bone
	name = "Fossilised bone"
	icon_state = "bone"
	desc = "It's a fossilised bone from an unknown creature."

/obj/item/weapon/fossil/shell
	name = "Fossilised shell"
	icon_state = "shell"
	desc = "It's a fossilised shell from some sort of space mollusc."

/obj/item/weapon/fossil/skull/horned
	icon_state = "hskull"
	desc = "It's a fossilised skull, it has horns."

/obj/item/weapon/fossil/skull
	name = "Fossilised skull"
	icon_state = "skull"
	desc = "It's a fossilised skull."

/obj/item/weapon/fossil/skull/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/fossil/bone))
		var/obj/o = new /obj/skeleton(get_turf(src))
		var/a = new /obj/item/weapon/fossil/bone
		var/b = new src.type
		o.contents.Add(a)
		o.contents.Add(b)
		del W
		del src

/obj/skeleton
	name = "Incomplete skeleton"
	icon = 'fossil.dmi'
	icon_state = "uskel"
	desc = "Incomplete skeleton."
	var/bnum = 1
	var/breq
	var/bstate = 0

/obj/skeleton/New()
	src.breq = rand(6)+3
	src.desc = "Incomplete skeleton, looks like it could use [src.breq-src.bnum] more bones."


/obj/skeleton/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/fossil/bone))
		if(!bstate)
			bnum++
			src.contents.Add(new/obj/item/weapon/fossil/bone)
			del W
			if(bnum==breq)
				usr = user
				icon_state = "skel"
				var/creaturename = input("Input a name for your discovery:","Name your discovery","Spaceosaurus")
				src.bstate = 1
				src.name = "[creaturename] skeleton"
				if(src.contents.Find(/obj/item/weapon/fossil/skull/horned))
					src.desc = "A creature made of [src.contents.len-1] assorted bones and a horned skull, the plaque reads [creaturename]."
				else
					src.desc = "A creature made of [src.contents.len-1] assorted bones and a skull, the plaque reads [creaturename]."
			else
				src.desc = "Incomplete skeleton, looks like it could use [src.breq-src.bnum] more bones."
				user << "Looks like it could use [src.breq-src.bnum] more bones."
		else
			..()
	else
		..()

