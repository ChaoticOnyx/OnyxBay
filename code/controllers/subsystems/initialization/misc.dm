SUBSYSTEM_DEF(misc)
	name = "Early Initialization"
	init_order = SS_INIT_MISC
	flags = SS_NO_FIRE

/datum/controller/subsystem/misc/Initialize()
	if(config.game.generate_asteroid)
		GLOB.using_map.perform_map_generation()

	// Create robolimbs for chargen.
	populate_robolimb_list()

	job_master = new /datum/controller/occupations()
	job_master.SetupOccupations(setup_titles=1)
	job_master.LoadJobs("config/jobs.toml")

	GLOB.syndicate_code_phrase = generate_code_phrase()
	GLOB.code_phrase_highlight_rule = generate_code_regex(GLOB.syndicate_code_phrase, @"\u0430-\u0451") // Russian chars only
	GLOB.syndicate_code_response = generate_code_phrase()
	GLOB.code_response_highlight_rule = generate_code_regex(GLOB.syndicate_code_response, @"\u0430-\u0451") // Russian chars only

	setupgenetics()

	//Create colors for different poisonous lizards
	var/list/toxin_color = list()
	toxin_color["notoxin"] = hex2rgb(rand_hex_color())
	var/list/toxin_list = POSSIBLE_LIZARD_TOXINS
	for(var/T in toxin_list)
		toxin_color[T] = hex2rgb(rand_hex_color())
	GLOB.lizard_colors = toxin_color

	transfer_controller = new
	. = ..()
