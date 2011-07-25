var/global/datum/controller/game_controller/master_controller //Set in world.New()
var/ticker_debug
var/updatetime
var/global/gametime = 0
var/global/gametime_last_updated
datum/controller/game_controller
	var/processing = 1
	//var/lastannounce = 0
	var/tick = 0

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
		vsc = new()
		world << "\red \b Setting up shields.."

		ShieldNetwork.makenetwork()
		setupnetwork()
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

		//mining setup
		setupmining()

		setuptitles()
		SetupAnomalies()
	//	tgrid.Setup()
		setupdooralarms()		//Added by Strumpetplaya - Alarm Change
		BOOKHAND = new()
		world << "\red \b Setting up the book system..."
	// Handled by datum declerations now in the shuttle controller file

	//	main_shuttle = new /datum/shuttle_controller/main_shuttle()



		if(!ticker)
			ticker = new /datum/controller/gameticker()

		// setup the in-game time
		gametime = rand(0,2200)
		gametime_last_updated = world.timeofday

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


		world << "\red \b Building Unified Networks"

		MakeUnifiedNetworks()


		world << "\red \b Initializations complete."

		/*var/list/l = new /list
		var/savefile/f = new("closet.sav")
		var/turf/t = locate(38,56,7)
		f["list"]>>l
		for(var/obj/o in l)
			var/obj/b = new o.type
			//var/obj/b.vars = o.vars.Copy()
			b.loc = t*/


	process()

		if(!processing)
			return 0

		// keep track of the ticks
		tick++

		// update the clock
		// one real-life minute is 100 time-units
		gametime += (100 / 60) * (world.timeofday - gametime_last_updated) / 10
		gametime_last_updated = world.timeofday
		if(gametime > 2200) gametime -= 2200

		/*
		if (start_time - lastannounce >= 18000)
			world << "\blue <b>Automatic Announcement:</b>\n \t The forum went down, so we're now at http://whoopshop.com"
			lastannounce = start_time*/

		//world.keepalive()
		// reduce frequency of the air process
		if(tick % 5 == 0)
			sleep(1 * tick_multiplier)
			ticker_debug = "Airprocess"
			air_master.process()

		sleep(1 * tick_multiplier)
		ticker_debug = "Sun calc"
		sun.calc_position()

		sleep(-1)

		for(var/mob/M in world)
			ticker_debug = "[M] [M.real_name] life calc"
			M.Life()

		sleep(-1)

		for(var/obj/machinery/machine in machines)
			ticker_debug = "[machine.name] processing"
			machine.process()

		sleep(-1)

		for(var/obj/fire/F in world)
			ticker_debug = "fire processing"
			F.process()

		sleep(1 * tick_multiplier)

		for(var/obj/item/item in processing_items)
			ticker_debug = "[item] [item.name] processing"
			item.process()

		for(var/datum/pipe_network/network in pipe_networks)
			ticker_debug = "pipe processing"
			network.process()

		for(var/OuterKey in AllNetworks)
			ticker_debug = "uninet processing"
			var/list/NetworkSet = AllNetworks[OuterKey]
			for(var/datum/UnifiedNetwork/Network in NetworkSet)
				if(Network)
					Network.Controller.Process()

		for(var/turf/t in processing_turfs)
			ticker_debug = "turf processing"
			t.process()

		if(world.timeofday >= updatetime)
			ticker_debug = "creating json"
			world.makejson()
			updatetime = world.timeofday + 3000

		for(var/obj/O in processing_others) // The few exceptions which don't fit in the above lists
			ticker_debug = "[O] [O.name] processing"
			O:process()

		//tgrid.Tick(0) // Part of Alfie's travel code
		sleep(-1)

		ticker.process()

		sleep(10 * tick_multiplier)

		spawn process()

		return 1