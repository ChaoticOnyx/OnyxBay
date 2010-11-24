var/global/datum/controller/game_controller/master_controller //Set in world.New()

datum/controller/game_controller
	var/processing = 1

	proc
		setup()
		setup_objects()
		process()

	setup()
		set background = 1
		if(master_controller && (master_controller != src))
			del(src)
			//There can be only one master.

		spawn(0)
			world.startmysql()
			world.load_mode()
			world.load_motd()
			world.load_rules()
			world.load_admins()
			world.update_status()
		ShieldNetwork = new /datum/shieldnetwork()
		world << "\red Setting up shields.."
		if(ShieldNetwork.makenetwork())
			world << "\red Shields set up complete."

		makepowernets()

		sun = new /datum/sun()

		vote = new /datum/vote()

		radio_controller = new /datum/controller/radio()
		//main_hud1 = new /obj/hud()
		data_core = new /obj/datacore()
		CreateShuttles()

		if(!air_master)
			air_master = new /datum/controller/air_system()
			air_master.setup()

		plmaster = new /obj/overlay(  )
		plmaster.icon = 'tile_effects.dmi'
		plmaster.icon_state = "plasma"
		plmaster.layer = FLY_LAYER
		plmaster.mouse_opacity = 0

		slmaster = new /obj/overlay(  )
		slmaster.icon = 'tile_effects.dmi'
		slmaster.icon_state = "sleeping_agent"
		slmaster.layer = FLY_LAYER
		slmaster.mouse_opacity = 0

		world.update_status()

		ClearTempbans()

		setup_objects()

		setupgenetics()

		setupdooralarms()		//Added by Strumpetplaya - Alarm Change


	// Handled by datum declerations now in the shuttle controller file

	//	main_shuttle = new /datum/shuttle_controller/main_shuttle()

		if(!ticker)
			ticker = new /datum/controller/gameticker()

		spawn
			ticker.pregame()

	setup_objects()
		world << "\red \b Initializing objects"
		sleep(-1)

		for(var/obj/object in world)
			object.initialize()

		world << "\red \b Initializing pipe networks"
		sleep(-1)

		for(var/obj/machinery/atmospherics/machine in world)
			machine.build_network()


		world << "\red \b Building Computer Networks"
		sleep(-1)
		makecomputernets()


		world << "\red \b Initializations complete."

	process()

		if(!processing)
			return 0

		var/start_time = world.timeofday

		air_master.process()

		sleep(1)

		sun.calc_position()

		sleep(-1)

		for(var/mob/M in world)
			M.Life()

		sleep(-1)

		for(var/obj/machinery/machine in machines)
			machine.process()

		sleep(-1)
		sleep(1)

		for(var/obj/item/item in processing_items)
			item.process()



		for(var/datum/pipe_network/network in pipe_networks)
			network.process()
		for(var/datum/powernet/P in powernets)
			P.reset()

		for(var/turf/t in processing_turfs)
			t.process()

		sleep(-1)

		ticker.process()

		sleep(world.timeofday+10-start_time)

		spawn process()

		return 1