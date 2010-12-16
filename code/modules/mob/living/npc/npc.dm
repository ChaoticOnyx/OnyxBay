mob/living/npc
	name = "npc"
	bruteloss = 0 // brute damage taken
	fireloss = 0
	oxyloss = 0
	var/agressive = 0 // will he attack enmies?
	var/hunt = 0 // will he  seek out ennimes?
	var/search = 0 // will he seek out friends?
	var/helpfull = 0 // will he do something heplfull to friends?
	var/list/friends = list(/mob/living/npc/test)
	var/breath = 0
	var/list/say = list()
	var/mob/target
	var/slashattack = 0 // will he cause bleeding?
	var/superblunt = 0 // Will he have a incressed chance to destory limbs?
	var/attackmessage = "punches"
	var/brutedmg = 0 // brute dmg taken per attack
	var/firedmg = 0 // fire dmg taken per attack
	var/oxydmg = 0 // oxy dmg taken per attack
mob/living/npc/Life()
	if(stat == 2)
		return
	if(breath)
		Breath()
	if(bruteloss||fireloss||oxyloss)
		Healthcheck()
	Act()
	if(say.len && prob(10))
		DoSay()
mob/living/npc/proc/Healthcheck()
	if((bruteloss + fireloss + oxyloss) > 200)
		Die()
mob/living/npc/proc/Die()
	stat = 2
	return
mob/living/npc/proc/Breath()
	return
mob/living/npc/attack_hand(mob/user)
	Attacked(user)
mob/living/npc/proc/Attacked(mob/user,obj/item/weapon/W)
	if(!W)
		for(var/mob/M in viewers(user))
			M << "[user] punches [src]"
		src.brutedmg += rand(1,3)
mob/living/npc/proc/Act()
	var/isidle = 1
	if(target in view(1,src))
	//	world << " I SEE EM"
		if(!friends.Find(target.type) && target.stat < 2 && agressive)
			//world << "ATTACKING"
			Attack(target,brutedmg,firedmg,oxydmg)
			isidle = 0
			target = null
		else if(target.stat < 2 && helpfull)
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
	say(texts)
mob/living/npc/proc/Attack(mob/M,brute=0,fire=0,o2=0)
	if (world.time <= src.lastDblClick+2) // SAME RULES FOR NPCS AS HUMANS :D
		return
	else
		src.lastDblClick = world.time
	var/render = "\red [src] [attackmessage] [M]"
	var/render2 = "\red [src] [attackmessage] you!"
	if(M in view(1,src))
		if(istype(M,/mob/living/carbon/human))
			var/datum/organ/external/org = pick(M:organs2)
			if(org)
				render = "\red [src] [attackmessage] [M]\s [org.display_name]"
				render2 = "\red [src] [attackmessage] your [org.display_name]"
				org.take_damage(brute,fire,slashattack,superblunt)
				M << render2
			M.oxyloss += o2
		else
			M.bruteloss += brute
			M.fireloss += fire
			M.oxyloss += o2
			M.show_message(render2)
		for(var/mob/MS in viewers(src))
			if(MS != M)
				MS << render
			return
mob/living/npc/proc/Help(mob/M)
	if(lastDblClick <= 0)
		lastDblClick = world.time+3
	if (world.time <= src.lastDblClick+2) // SAME RULES FOR NPCS AS HUMANS :D
		return
	else
		src.lastDblClick = world.time
mob/living/npc/proc/DoIdle()
	step_rand(src)
	sleep(10)
	return
mob/living/npc/test
	name = "crab"
//	rname = "crab"
	icon = 'beach.dmi'
	icon_state = "crab2"
	agressive = 1
	hunt = 1
	attackmessage = "pinches"
	brutedmg = 1