mob/living/npc
	name = "npc"
	var/brutedmg = 0
	var/firedmg = 0
	var/o2dmg = 0
	var/agressive = 0 // will he attack enmies?
	var/hunt = 0 // will he  seek out ennimes?
	var/search = 0 // will he seek out friends?
	var/helpfull = 0 // will he do something heplfull to friends?
	var/list/friends = new()
	var/breath = 0
	var/list/say = list(/mob/living/npc/test)
	var/mob/target
	var/attackmessage = "punches"
mob/living/npc/Life()
	if(breath)
		Breath()
	if(brutedmg||firedmg||o2dmg)
		Healthcheck()
	Act()
	if(say.len)
		DoSay()
mob/living/npc/proc/Healthcheck()
	if((brutedmg + firedmg + o2dmg) > 200)
		Die()
mob/living/npc/proc/Die()
	stat = 2
	return
mob/living/npc/proc/Breath()
	return
mob/living/npc/proc/Act()
	var/isidle = 1
/*	if(!target)
		for(var/mob/living/M in view(1))
			if(!friends.Find(M.type) && agressive && M.stat < 2)
				Attack(M)
				isidle = 0
				break
			else if(helpfull)
				Help(M)
				isidle = 0
				break*/
	if(target in view(1,src))
	//	world << " I SEE EM"
		if(!friends.Find(target.type) && target.stat < 2)
			//world << "ATTACKING"
			Attack(target)
			isidle = 0
			target = null
		else if(target.stat < 2)
			Help(target)
			isidle = 0
			target = null
	if(target in viewers(src))// we see him
		//world << "OH I SEE HIM"
		step_towards(src,target)
		sleep(10)
	else if(hunt || search) // we lost him
		target = null
		for(var/mob/living/M in viewers(src))
			if(hunt && !friends.Find(M.type) && M.stat < 2)
				target = M
				isidle = 0
				step_towards(src,target)
				break
			else if(search && M.stat < 2)
				target = M
				isidle = 0
				step_towards(src,target)
				break
	if(isidle)
		DoIdle()
	return
mob/living/npc/proc/DoSay()
	var/texts = pick(say)
mob/living/npc/proc/Attack(mob/M,brutedmg=1,firedmg=1,o2dmg=1)
	var/render = "\red [src] [attackmessage] [M]"
	if(M in view(1,src))
		M << render
		//take damage
	for(var/mob/MS in viewers(src))
		MS << render
		return
mob/living/npc/proc/Help(mob/M)
mob/living/npc/proc/DoIdle()
	step_rand(src)
	sleep(10)
mob/living/npc/test
	name = "crab"
	icon = 'beach.dmi'
	icon_state = "crab2"
	agressive = 1
	hunt = 1