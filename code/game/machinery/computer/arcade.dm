/obj/machinery/computer/arcade/
	name = "random arcade"
	desc = "A random arcade machine."
	icon_state = "arcade"
	icon_keyboard = null
	icon_screen = "invaders"
	var/list/prizes = list(	/obj/item/storage/box/snappops										= 2,
							/obj/item/toy/blink															= 2,
							/obj/item/clothing/under/syndicate/tacticool								= 2,
							/obj/item/toy/sword															= 2,
							/obj/item/gun/projectile/revolver/capgun								= 2,
							/obj/item/toy/crossbow														= 2,
							/obj/item/clothing/suit/syndicatefake										= 2,
							/obj/item/storage/fancy/crayons										= 2,
							/obj/item/toy/spinningtoy													= 2,
							/obj/item/toy/prize/ripley													= 1,
							/obj/item/toy/prize/fireripley												= 1,
							/obj/item/toy/prize/deathripley												= 1,
							/obj/item/toy/prize/gygax													= 1,
							/obj/item/toy/prize/durand													= 1,
							/obj/item/toy/prize/honk													= 1,
							/obj/item/toy/prize/marauder												= 1,
							/obj/item/toy/prize/seraph													= 1,
							/obj/item/toy/prize/mauler													= 1,
							/obj/item/toy/prize/odysseus												= 1,
							/obj/item/toy/prize/phazon													= 1,
							/obj/item/reagent_containers/spray/waterflower						= 1,
							/obj/random/action_figure													= 1,
							/obj/random/plushie															= 1,
							/obj/item/toy/cultsword														= 1
							)

/obj/machinery/computer/arcade/Initialize()
	. = ..()
	// If it's a generic arcade machine, pick a random arcade
	// circuit board for it and make the new machine
	if(!circuit)
		var/choice = pick(typesof(/obj/item/circuitboard/arcade) - /obj/item/circuitboard/arcade)
		var/obj/item/circuitboard/CB = new choice()
		new CB.build_path(loc, CB)
		return INITIALIZE_HINT_QDEL

/obj/machinery/computer/arcade/proc/prizevend()
	if(!contents.len)
		var/prizeselect = pickweight(prizes)
		new prizeselect(src.loc)

		if(istype(prizeselect, /obj/item/clothing/suit/syndicatefake)) //Helmet is part of the suit
			new	/obj/item/clothing/head/syndicatefake(src.loc)

	else
		var/atom/movable/prize = pick(contents)
		prize.forceMove(src.loc)

/obj/machinery/computer/arcade/attack_ai(mob/user as mob)
	return src.attack_hand(user)


/obj/machinery/computer/arcade/emp_act(severity)
	if(stat & (NOPOWER|BROKEN))
		..(severity)
		return
	var/empprize = null
	var/num_of_prizes = 0
	switch(severity)
		if(1)
			num_of_prizes = rand(1,4)
		if(2)
			num_of_prizes = rand(0,2)
	for(num_of_prizes; num_of_prizes > 0; num_of_prizes--)
		empprize = pickweight(prizes)
		new empprize(src.loc)

	..(severity)

///////////////////
//  BATTLE HERE  //
///////////////////

/obj/machinery/computer/arcade/battle
	name = "arcade machine"
	desc = "Does not support Pinball."
	icon_state = "arcade"
	circuit = /obj/item/circuitboard/arcade/battle
	var/enemy_name = "Space Villian"
	var/temp = "Winners don't use space drugs" //Temporary message, for attack messages, etc
	var/player_hp = 30 //Player health/attack points
	var/player_mp = 10
	var/enemy_hp = 45 //Enemy health/attack points
	var/enemy_mp = 20
	var/gameover = 0
	var/turtle = 0
	var/list/attack_sounds = list(
			'sound/effects/arcade/attack1.ogg',
			'sound/effects/arcade/attack2.ogg',
			'sound/effects/arcade/attack3.ogg',
			'sound/effects/arcade/attack4.ogg',
			'sound/effects/arcade/attack5.ogg'
		)

	var/list/damage_sounds = list(
		'sound/effects/arcade/damage1.ogg',
		'sound/effects/arcade/damage2.ogg',
		'sound/effects/arcade/damage3.ogg',
	)

/obj/machinery/computer/arcade/battle/Initialize()
	. = ..()
	SetupGame()

/obj/machinery/computer/arcade/battle/proc/SetupGame()
	var/name_action
	var/name_part1
	var/name_part2

	name_action = pick("Defeat ", "Annihilate ", "Save ", "Strike ", "Stop ", "Destroy ", "Robust ", "Romance ", "Pwn ", "Own ", "Ban ")

	name_part1 = pick("the Automatic ", "Farmer ", "Lord ", "Professor ", "the Cuban ", "the Evil ", "the Dread King ", "the Space ", "Lord ", "the Great ", "Duke ", "General ")
	name_part2 = pick("Melonoid", "Murdertron", "Sorcerer", "Ruin", "Jeff", "Ectoplasm", "Crushulon", "Uhangoid", "Vhakoid", "Peteoid", "metroid", "Griefer", "ERPer", "Lizard Man", "Unicorn", "Bloopers")

	src.enemy_name = replacetext((name_part1 + name_part2), "the ", "")
	src.SetName((name_action + name_part1 + name_part2))

/obj/machinery/computer/arcade/battle/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "Arcade", "")
		ui.open()

/obj/machinery/computer/arcade/battle/tgui_data(mob/user)
	return list(
		"title" = name,
		"is_gameover" = gameover,
		"message" = temp,
		"enemy" = list(
			"name" = enemy_name,
			"hp" = enemy_hp,
			"mp" = enemy_mp
		),
		"player" = list(
			"hp" = player_hp,
			"mp" = player_mp
		)
	)

/obj/machinery/computer/arcade/battle/tgui_act(action, params)
	. = ..()

	if(.)
		return

	switch(action)
		if("attack")
			playsound(loc, pick(attack_sounds), 15, TRUE)
			var/attackamt = rand(2,6)
			temp = "You attack for [attackamt] damage!"

			if(turtle > 0)
				turtle--

			enemy_hp -= attackamt
			arcade_action(usr)

			. = TRUE
		if("heal")
			playsound(loc, 'sound/effects/arcade/heal1.ogg', 15, TRUE)
			blocked = 1
			var/pointamt = rand(1,3)
			var/healamt = rand(6,8)
			temp = "You use [pointamt] magic to heal for [healamt] damage!"
			turtle++
			player_mp -= pointamt
			player_hp += healamt
			blocked = 1
			arcade_action(usr)

			. = TRUE
		if("charge")
			playsound(loc, 'sound/effects/arcade/recharge1.ogg', 15, TRUE)
			blocked = 1
			var/chargeamt = rand(4,7)
			temp = "You regain [chargeamt] points"
			player_mp += chargeamt

			if(turtle > 0)
				turtle--

			arcade_action(usr)

			. = TRUE
		if("newgame")
			playsound(loc, 'sound/effects/arcade/start1.ogg', 15, TRUE)
			temp = "New Round"
			player_hp = 30
			player_mp = 10
			enemy_hp = 45
			enemy_mp = 20
			gameover = 0
			turtle = 0

			if(emagged)
				emagged = 0
				SetupGame()

			. = TRUE

	if(.)
		tgui_update()

/obj/machinery/computer/arcade/battle/attack_hand(mob/user)
	. = ..()

	if(.)
		return

	tgui_interact(user)

/obj/machinery/computer/arcade/battle/proc/arcade_action(user)
	if ((enemy_mp <= 0) || (enemy_hp <= 0))
		if(!gameover)
			gameover = 1
			temp = "[enemy_name] has fallen! Rejoice!"

			if(emagged)
				feedback_inc("arcade_win_emagged")
				new /obj/effect/spawner/newbomb/timer/syndicate(loc)
				new /obj/item/clothing/head/collectable/petehat(loc)
				log_and_message_admins("has outbombed Cuban Pete and been awarded a bomb.")
				SetupGame()
				emagged = 0
			else
				feedback_inc("arcade_win_normal")
				prizevend()

	else if (emagged && (turtle >= 4))
		playsound(loc, pick(damage_sounds), 15, TRUE)
		var/boomamt = rand(5,10)
		temp = "[enemy_name] throws a bomb, exploding you for [boomamt] damage!"
		player_hp -= boomamt

	else if ((enemy_mp <= 5) && (prob(70)))
		var/stealamt = rand(2,3)
		temp = "[enemy_name] steals [stealamt] of your power!"
		player_mp -= stealamt
		attack_hand(user)

		if (player_mp <= 0)
			gameover = 1
			sleep(10)
			temp = "You have been drained!"
			if(emagged)
				feedback_inc("arcade_loss_mana_emagged")
				explode()
			else
				feedback_inc("arcade_loss_mana_normal")

	else if ((enemy_hp <= 10) && (enemy_mp > 4))
		temp = "[enemy_name] heals for 4 health!"
		enemy_hp += 4
		enemy_mp -= 4

	else
		var/attackamt = rand(3,6)
		playsound(loc, pick(damage_sounds), 15, TRUE)
		temp = "[enemy_name] attacks for [attackamt] damage!"
		player_hp -= attackamt

	if ((player_mp <= 0) || (player_hp <= 0))
		gameover = 1
		temp = "You have been crushed!"
		if(emagged)
			feedback_inc("arcade_loss_hp_emagged")
			explode()
		else
			feedback_inc("arcade_loss_hp_normal")

	blocked = 0

/obj/machinery/computer/arcade/proc/explode()
	explosion(loc, 0, 1, 2, 3)
	qdel(src)

/obj/machinery/computer/arcade/battle/emag_act(charges, mob/user)
	if(!emagged)
		playsound(src.loc, 'sound/effects/computer_emag.ogg', 25)
		temp = "If you die in the game, you die for real!"
		player_hp = 30
		player_mp = 10
		enemy_hp = 45
		enemy_mp = 20
		gameover = 0
		blocked = 0
		emagged = 1

		enemy_name = "Cuban Pete"
		name = "Outbomb Cuban Pete"

		attack_hand(user)
		return 1
