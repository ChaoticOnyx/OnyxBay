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
	var/breath = 0 // does he require air or something else to survive.
	var/list/say = list()
	var/list/findtargets = list()
	var/atom/findtarget
	var/list/path_target = list()// astar
	var/find = 0 // will he try to find something in the findtargets list()
	var/sayprob = 10 // probabilty to say something.
	var/mob/target
	var/slashattack = 0 // will he cause bleeding?
	var/superblunt = 0 // Will he have a incressed chance to destory limbs?
	var/attackmessage = "punches"
	var/helpmesage = "massages"
	var/rangedmessage = "shoots"
	var/brutedmg = 0 // brute dmg taken per attack
	var/firedmg = 0 // fire dmg taken per attack
	var/oxydmg = 0 // oxy dmg taken per attack
	var/ranged = 0 // Does he have a ranged attack?
	var/rangedrange = 4 // at what range will he fire?
	var/frust = 0
mob/living/npc/Life()
	if(stat == 2)
		return
	if(breath)
		Breath()
	if(bruteloss||fireloss||oxyloss)
		Healthcheck()
	if(!src.client)
		Act()
	if(say.len && prob(sayprob))
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
	var/mob/ohshit
	if(target.stat == 2)
		target = null
	for(var/mob/M in view(1))
		if(!friends.Find(M.type) && M.type == src.type && M.stat < 2 && agressive)
			ohshit = M
			break
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
	else if(ohshit in view(1,src))
		Attack(ohshit,brutedmg,firedmg,oxydmg)
		isidle = 0
		target = ohshit
		path_target = list()
		ohshit = null
	else if(ranged && target in view(rangedrange,src))
		RangedAttack(target)
		world << "MOTHERFUCKING SHOOTING"
		if(!path_target.len)
			MoveAstar(target)
			if(path_target.len <= 0)
				path_target = list()
				return
		var/turf/next = path_target[1]
		var/turf/oldloc = src.loc
		step_towards_3d(src,get_step_towards_3d2(next))
		path_target -= next
		if(oldloc == src.loc)
			frust += 5
		isidle = 0
	else if(target in view(4,src))
		step_towards_3d(src,get_step_towards_3d2(target))
		isidle = 0
		path_target = list()
	else if(target in viewers(src))// we see him
		if(!path_target.len)
			MoveAstar(target)
			if(path_target.len <= 0)
				path_target = list()
				return
		var/turf/next = path_target[1]
		step_towards_3d(src,get_step_towards_3d2(next))
		path_target -= next
		isidle = 0
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
	else if(find && findtargets.len)
		for(var/atom/A in findtarget)
			var/atom/B = locate(A) in world
			if(B)
				//astar ghere
				isidle = 0
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
		for(var/mob/MS in hearers(src))
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
//	world << "IDLE"
	step_rand(src)
	return
mob/living/npc/proc/RangedAttack(atom/trg)
	return
mob/living/npc/proc/MoveAstar(atom/trg)
		//target = trg
	if(isturf(trg))
		path_target = AStar(src.loc, target, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 250, null,null)
		path_target = reverselist(path_target)
		return
	path_target = AStar(src.loc, target.loc, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 250, null,null)
	path_target = reverselist(path_target)

mob/living/npc/test
	name = "crab"
//	rname = "crab"
	icon = 'beach.dmi'
	icon_state = "crab2"
	agressive = 1
	hunt = 1
	attackmessage = "pinches"
	brutedmg = 1
mob/living/npc/testrange
	name = "crab"
//	rname = "crab"
	icon = 'beach.dmi'
	icon_state = "crab2"
	agressive = 1
	hunt = 1
	attackmessage = "pinches"
	brutedmg = 1
	ranged = 1
	rangedrange = 6
mob/living/npc/testrange/RangedAttack(atom/trg)
	if(lastDblClick <= 0)
		lastDblClick = world.time+3
	if (world.time <= src.lastDblClick+2) // SAME RULES FOR NPCS AS HUMANS :D
		return
	else
		src.lastDblClick = world.time
	var/turf/T = src.loc
	var/turf/U = (istype(trg, /atom/movable) ? trg.loc : trg)
	if(!U || !T)
		return
	while(U && !istype(U,/turf))
		U = U.loc
	if(!istype(T, /turf))
		return
	if (U == T)
		src.bullet_act(PROJECTILE_TASER)
		return
	if(!istype(U, /turf))
		return

	var/obj/bullet/electrode/A = new /obj/bullet/electrode(src.loc)

	A.current = U
	A.yo = U.y - T.y
	A.xo = U.x - T.x

	A.process()
mob/living/npc/bullet_act(flag)
	if (flag == PROJECTILE_BULLET)
		if (stat != 2)
			bruteloss += 60
			updatehealth()
			weakened = 10
	else if (flag == PROJECTILE_TASER)
		if (prob(75))
			stunned = 15
		else
			weakened = 15
	else if(flag == PROJECTILE_LASER)
		if (stat != 2)
			bruteloss += 20
			updatehealth()
			if (prob(25))
				stunned = 1
	else if(flag == PROJECTILE_PULSE)
		if (stat != 2)
			bruteloss += 40
			updatehealth()
			if (prob(50))
				stunned = min(5, stunned)
	return