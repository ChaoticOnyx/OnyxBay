#define STATE_EMPTY "empty"
#define STATE_BLANK "blank"
#define STATE_MINE "mine"
/// Grid X, Grid Y, number of mines
#define DIFFICULTY_BEGINNER list(9, 9, 10)
#define DIFFICULTY_INTERMEDIATE list(16, 16, 40)
#define DIFFICULTY_EXPERT list(30, 16, 99)

/obj/machinery/computer/arcade/minesweeper
	name = "arcade machine"
	desc = "Does not support Pinball."
	icon_state = "arcade"
	circuit = /obj/item/circuitboard/arcade/battle
	clicksound = SFX_MINESWEEPER_CLICK
	var/difficulty = null
	var/game_set_up = FALSE
	var/list/grid
	var/grid_x = 0
	var/grid_y = 0
	var/grid_mines = 0
	var/grid_blanks = 0
	var/grid_pressed = 0
	var/list/nearest_mask = list(
		list(-1, -1), list(0, -1), list(1, -1),
		list(-1, 0), list(1, 0),
		list(-1, 1), list(0, 1), list(1, 1)
		)

/obj/machinery/computer/arcade/minesweeper/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	tgui_interact(user)

/obj/machinery/computer/arcade/minesweeper/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "Minesweeper", src.name)
		ui.open()

/obj/machinery/computer/arcade/minesweeper/tgui_data(mob/user)
	var/list/data = list()

	data["grid"] = grid
	data["width"] = grid_x * 30
	data["height"] = grid_y * 30
	data["mines"] = "[num2text(grid_mines)] mines."
	data["difficulty"] = isnull(difficulty) ? FALSE : TRUE

	return data

/obj/machinery/computer/arcade/minesweeper/tgui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("set_difficulty")
			var/chosen_difficulty = params["difficulty"]
			switch(chosen_difficulty)
				if("beginner")
					difficulty = DIFFICULTY_BEGINNER
				if("intermediate")
					difficulty = DIFFICULTY_INTERMEDIATE
				if("expert")
					difficulty = DIFFICULTY_EXPERT
			setup_grid()
			return TRUE

		if("button_press")
			button_press(text2num(params["choice_y"]), text2num(params["choice_x"]))
			return TRUE

		if("button_flag")
			button_flag(text2num(params["choice_y"]), text2num(params["choice_x"]))
			return TRUE

/obj/machinery/computer/arcade/minesweeper/proc/won()
	playsound(get_turf(src), GET_SFX(SFX_MINESWEEPER_WIN), 100, FALSE, -1)

	switch(difficulty[3])
		if(40)
			contents += new /obj/item/clothing/mask/uwu(src)

		if(99)
			contents += new /obj/item/plastique(src) // Will be picked from contents in prizevend()

	prizevend()

	game_set_up = FALSE
	difficulty = null
	SStgui.close_uis(src)

/obj/machinery/computer/arcade/minesweeper/proc/game_over()
	playsound(get_turf(src), GET_SFX(SFX_MINESWEEPER_LOSE), 100, FALSE, -1)
	game_set_up = FALSE
	difficulty = null
	for(var/mob/living/carbon/C in viewers(src, 2))
		C.flash_eyes()

/obj/machinery/computer/arcade/minesweeper/proc/SpawnGoodLoot()
	//playsound(src, 'sound/misc/mining_reward_3.ogg', 100, 100, FALSE)

/obj/machinery/computer/arcade/minesweeper/proc/SpawnMediumLoot()
	//playsound(src, 'sound/misc/mining_reward_2.ogg', 100, 100, FALSE)

/obj/machinery/computer/arcade/minesweeper/proc/SpawnBadLoot()
	//playsound(src, 'sound/misc/mining_reward_1.ogg', 100, 100, FALSE)
	//switch(rand(1, 3))

/obj/machinery/computer/arcade/minesweeper/proc/SpawnDeathLoot()
	//playsound(src, 'sound/misc/mining_reward_0.ogg', 100, 100, FALSE)
	//new /mob/living/simple_animal/hostile/mimic/crate(loc)
	qdel(src)

/obj/machinery/computer/arcade/minesweeper/proc/button_press(y, x)
	if(grid[y][x]["flag"])
		return

	if(grid[y][x]["state"] == STATE_MINE)
		game_over()
		return

	reveal_button(x,y)

/obj/machinery/computer/arcade/minesweeper/proc/button_flag(y, x)
	var/list/L = grid[y][x]
	if(L["state"] != STATE_EMPTY)
		L["flag"] = !L["flag"]

/obj/machinery/computer/arcade/minesweeper/proc/setup_grid()
	playsound(get_turf(src), GET_SFX(SFX_MINESWEEPER_START), 100, FALSE, -1)

	grid_x = difficulty[1]
	grid_y = difficulty[2]

	grid_mines = difficulty[3]

	grid = new /list(grid_y, grid_x)

	for(var/i = 1 to grid_y)
		var/list/Line = grid[i]
		for(var/j = 1 to grid_x)
			Line[j] = list("state" = STATE_BLANK, "x" = j, "y" = i, "nearest" = "", "flag" = FALSE)
			grid_blanks++

/obj/machinery/computer/arcade/minesweeper/proc/setup_mines(x_to_skip, y_to_skip)
	for(var/i = 1 to grid_mines)
		while(TRUE)
			var/y = rustg_rand_range_i32(1, grid_y)
			var/x = rustg_rand_range_i32(1, grid_x)
			if(x == x_to_skip && y == y_to_skip)
				continue

			var/list/L = grid[y][x]
			if(L["state"] == STATE_MINE)
				continue

			else
				L["state"] = STATE_MINE
				grid_blanks--
				break

	game_set_up = TRUE

/obj/machinery/computer/arcade/minesweeper/proc/check_in_grid(x, y)
	return x >= 1 && x <= grid_x && y >= 1 && y <= grid_y

/obj/machinery/computer/arcade/minesweeper/proc/reveal_button(x, y)
	if(!check_in_grid(x, y) || grid[y][x]["state"] == STATE_EMPTY || grid[y][x]["flag"])
		return

	grid[y][x]["state"] = STATE_EMPTY
	grid[y][x]["flag"] = FALSE
	grid_pressed++

	if(!game_set_up)
		setup_mines(x, y)

	if(check_complete())
		return

	var/mi = check_mines(x,y)
	grid[y][x]["nearest"] = mi
	if(mi != " ")
		return

	for(var/list/mask in nearest_mask)
		reveal_button(x + mask[1], y + mask[2])

/obj/machinery/computer/arcade/minesweeper/proc/check_mines(x, y)
	var/mins = 0

	for(var/list/mask in nearest_mask)
		if(check_in_grid(x + mask[1], y + mask[2]) && grid[y + mask[2]][x + mask[1]]["state"] == STATE_MINE)
			mins++

	return mins ? num2text(mins) : " "

/obj/machinery/computer/arcade/minesweeper/proc/check_complete()
	return grid_pressed == grid_blanks

#undef STATE_EMPTY
#undef STATE_BLANK
#undef STATE_MINE
