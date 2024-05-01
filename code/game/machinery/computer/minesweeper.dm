#define STATE_EMPTY "empty"
#define STATE_BLANK "blank"
#define STATE_MINE "mine"
/// Grid X, Grid Y, number of mines
#define DIFFICULTY_BEGINNER list("grid_x" = 9, "grid_y" = 9, "mines" = 10, "time_limit" = 2)
#define DIFFICULTY_INTERMEDIATE list("grid_x" = 16, "grid_y" = 16, "mines" = 40, "time_limit" = 3)
#define DIFFICULTY_EXPERT list("grid_x" = 30, "grid_y" = 16, "mines" = 99, "time_limit" = 5)
/// List of prizes. 'amount of mines' -> list(prizes)
GLOBAL_LIST_INIT(minesweeper_arcade_prizes, list(
	"10" = list(
		/obj/item/toy/blink                            = 2,
		/obj/item/clothing/under/syndicate/tacticool   = 2,
		/obj/item/toy/sword                            = 2,
		/obj/item/gun/projectile/revolver/capgun       = 2,
		/obj/item/toy/crossbow                         = 2,
		/obj/item/toy/plushie/snail                    = 4,
		/obj/item/reagent_containers/spray/waterflower = 1,
		/obj/item/spacecash/bundle/c50                 = 2,
	),
	"40" = list(
		/obj/item/clothing/mask/uwu                    = 3,
		/obj/item/bikehorn                             = 3,
		/obj/item/spacecash/bundle/c200                = 3,
		/obj/item/clothing/gloves/insulated            = 1,
		/obj/item/storage/pill_bottle/happy            = 1,
		/obj/item/pickaxe/diamond                      = 1,
		/obj/item/soap/gold                            = 1,
	),
	"99" = list(
		/obj/item/plastique                            = 1,
		/obj/item/storage/toolbox/syndicate            = 2,
		/obj/item/spacecash/bundle/c1000               = 2,
		/obj/random/voidsuit                           = 1,
		/obj/item/clothing/gloves/insulated            = 6,
		/obj/item/melee/telebaton                      = 1,
	),
	"emagged" = list(
		/obj/item/plastique                            = 3,
		/obj/item/pen/energy_dagger                    = 3,
		/obj/item/melee/energy/sword/pirate            = 1,
		/obj/item/melee/energy/sword/one_hand/red      = 1,
		/obj/item/melee/energy/sword/one_hand/purple   = 1,
		/obj/item/gun/energy/crossbow                  = 1,
	),
))

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
	var/grid_flags = 0
	var/list/nearest_mask = list(
		list(-1, -1), list(0, -1), list(1, -1),
		list(-1, 0), list(1, 0),
		list(-1, 1), list(0, 1), list(1, 1)
		)
	/// If emagged - used to calculate time left
	var/explode_time
	/// If emagged - holds weakref to a player
	var/weakref/player_weakref = null

/obj/machinery/computer/arcade/minesweeper/Destroy()
	var/mob/player = player_weakref?.resolve()
	if(istype(player))
		unregister_signal(player, SIGNAL_MOVED)
	player_weakref = null
	return ..()

/obj/machinery/computer/arcade/minesweeper/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	tgui_interact(user)

/obj/machinery/computer/arcade/minesweeper/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "Minesweeper")
		ui.open()
		ui.set_autoupdate(TRUE)

	if(emagged && isnull(player_weakref))
		player_weakref = weakref(user)
		register_signal(user, SIGNAL_MOVED, nameof(.proc/game_over))

/obj/machinery/computer/arcade/minesweeper/tgui_data(mob/user)
	var/list/data = list(
		"grid" = grid,
		"width" = grid_x * 30,
		"height" = grid_y * 30,
		"mines" = "[num2text(grid_mines)] mines",
		"flags" = "[num2text(grid_flags)] flags",
		"difficulty" = isnull(difficulty) ? FALSE : TRUE,
		"emagged" = emagged,
		"timeLeft" = 0,
	)

	if(emagged && !isnull(difficulty))
		var/timeleft = (explode_time - world.time) / 10
		data["timeLeft"] = "[add_zero(num2text((timeleft / 60) % 60),2)]:[add_zero(num2text(timeleft % 60), 2)]"

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

/obj/machinery/computer/arcade/minesweeper/emag_act(remaining_charges, mob/user, emag_source)
	if(emagged)
		return

	playsound(get_turf(src), 'sound/effects/computer_emag.ogg', 25, FALSE, -1)
	emagged = TRUE
	if(game_set_up || !isnull(difficulty))
		won()
	return 1

/obj/machinery/computer/arcade/minesweeper/proc/explode_player(mob/player)
	explosion(get_turf(src), -1, -1, 2, 3)
	explosion(get_turf(player), 0, 1, 3, 6)
	switch(rustg_rand_range_i32(0, 100))
		if(0 to 60)
			return
		else
			player.gib()

	if(!QDELETED(src))
		qdel_self()

/obj/machinery/computer/arcade/minesweeper/proc/won()
	playsound(get_turf(src), GET_SFX(SFX_MINESWEEPER_WIN), 100, FALSE, -1)
	var/atom/movable/prize = null
	if(!emagged)
		prize = util_pick_weight(GLOB.minesweeper_arcade_prizes[num2text(difficulty["mines"])])
	else
		prize = util_pick_weight(GLOB.minesweeper_arcade_prizes["emagged"])
	prize = new prize(get_turf(src))
	clear_variables()

/obj/machinery/computer/arcade/minesweeper/proc/game_over(mob/player)
	playsound(get_turf(src), GET_SFX(SFX_MINESWEEPER_LOSE), 100, FALSE, -1)
	for(var/mob/living/M in viewers(src, 2))
		M.flash_eyes()
	clear_variables()

/obj/machinery/computer/arcade/minesweeper/proc/clear_variables()
	game_set_up = FALSE
	difficulty = null
	SStgui.close_uis(src)

	var/mob/player = player_weakref?.resolve()
	if(istype(player))
		unregister_signal(player, SIGNAL_MOVED)
	player_weakref = null
	if(emagged)
		explode_player(player)

/obj/machinery/computer/arcade/minesweeper/proc/button_press(y, x)
	if(grid[y][x]["flag"])
		return

	if(grid[y][x]["state"] == STATE_MINE)
		game_over()
		return

	reveal_button(x, y)

/obj/machinery/computer/arcade/minesweeper/proc/button_flag(y, x)
	var/list/L = grid[y][x]
	if(L["state"] != STATE_EMPTY)
		L["flag"] = !L["flag"]
		grid_flags += L["flag"] ? 1 : -1

/obj/machinery/computer/arcade/minesweeper/proc/setup_grid()
	playsound(get_turf(src), GET_SFX(SFX_MINESWEEPER_START), 100, FALSE, -1)
	if(emagged)
		explode_time = world.time + (difficulty["time_limit"] MINUTES)
		set_next_think(world.time + (difficulty["time_limit"] MINUTES))

	grid_x = difficulty["grid_x"]
	grid_y = difficulty["grid_y"]

	grid_mines = difficulty["mines"]

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

			if(TICK_CHECK)
				game_set_up = FALSE
				SStgui.close_uis(src)
				return

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
		won()
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

/obj/machinery/computer/arcade/minesweeper/think()
	game_over()

#undef STATE_EMPTY
#undef STATE_BLANK
#undef STATE_MINE
