/datum/design/circuit/pacman
	name = "PACMAN-type generator"
	id = "pacman"

	build_path = /obj/item/circuitboard/pacman
	sort_string = "JBAAA"
	category_items = list("Engineering Boards")

/datum/design/circuit/superpacman
	name = "SUPERPACMAN-type generator"
	id = "superpacman"

	build_path = /obj/item/circuitboard/pacman/super
	sort_string = "JBAAB"
	category_items = list("Engineering Boards")

/datum/design/circuit/mrspacman
	name = "MRSPACMAN-type generator"
	id = "mrspacman"

	build_path = /obj/item/circuitboard/pacman/mrs
	sort_string = "JBAAC"
	category_items = list("Engineering Boards")

/datum/design/circuit/batteryrack
	name = "cell rack PSU"
	id = "batteryrack"

	build_path = /obj/item/circuitboard/batteryrack
	sort_string = "JBABA"
	category_items = list("Engineering Boards")

/datum/design/circuit/smes_cell
	name = "'SMES' superconductive magnetic energy storage"
	desc = "Allows for the construction of circuit boards used to build a SMES."
	id = "smes_cell"

	build_path = /obj/item/circuitboard/smes
	sort_string = "JBABB"
	category_items = list("Engineering Boards")

/datum/design/circuit/gas_heater
	name = "gas heating system"
	id = "gasheater"

	build_path = /obj/item/circuitboard/unary_atmos/heater
	sort_string = "JCAAA"
	category_items = list("Engineering Boards")

/datum/design/circuit/gas_cooler
	name = "gas cooling system"
	id = "gascooler"

	build_path = /obj/item/circuitboard/unary_atmos/cooler
	sort_string = "JCAAB"
	category_items = list("Engineering Boards")

/datum/design/circuit/secure_airlock
	name = "secure airlock electronics"
	desc =  "Allows for the construction of a tamper-resistant airlock electronics."
	id = "securedoor"

	build_path = /obj/item/airlock_electronics/secure
	sort_string = "JDAAA"
	category_items = list("Engineering Boards")

/datum/design/circuit/tcom

	category_items = list("Engineering Boards")

/datum/design/circuit/tcom/AssembleDesignName()
	name = "Telecommunications machinery circuit design ([name])"
/datum/design/circuit/tcom/AssembleDesignDesc()
	desc = "Allows for the construction of a telecommunications [name] circuit board."

/datum/design/circuit/tcom/server
	name = "server mainframe"
	id = "tcom-server"
	build_path = /obj/item/circuitboard/telecomms/server
	sort_string = "PAAAA"

/datum/design/circuit/tcom/processor
	name = "processor unit"
	id = "tcom-processor"
	build_path = /obj/item/circuitboard/telecomms/processor
	sort_string = "PAAAB"

/datum/design/circuit/tcom/bus
	name = "bus mainframe"
	id = "tcom-bus"
	build_path = /obj/item/circuitboard/telecomms/bus
	sort_string = "PAAAC"

/datum/design/circuit/tcom/hub
	name = "hub mainframe"
	id = "tcom-hub"
	build_path = /obj/item/circuitboard/telecomms/hub
	sort_string = "PAAAD"

/datum/design/circuit/tcom/relay
	name = "relay mainframe"
	id = "tcom-relay"

	build_path = /obj/item/circuitboard/telecomms/relay
	sort_string = "PAAAE"

/datum/design/circuit/tcom/broadcaster
	name = "subspace broadcaster"
	id = "tcom-broadcaster"

	build_path = /obj/item/circuitboard/telecomms/broadcaster
	sort_string = "PAAAF"

/datum/design/circuit/tcom/receiver
	name = "subspace receiver"
	id = "tcom-receiver"

	build_path = /obj/item/circuitboard/telecomms/receiver
	sort_string = "PAAAG"
