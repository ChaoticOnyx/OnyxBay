


/obj/constructing/example_object
	icon = 'constructing_door.dmi'
	initial_state = "sheet"

	states = list(
		"sheet" = list(
			"crowbar" = list(
				"state" = null,
				"drop" = list(
					/obj/item/weapon/sheet/metal{amount = 5},
				),
				"wait" = 20,
			),

			"metal" = list(
				"state" = "sheet2",
				"use_amount" = 5,
				"wait" = 20,
			),
		),

		"sheet2" = list(
			"crowbar" = list(
				"state" = "sheet",
				"drop" = list(
					/obj/item/weapon/sheet/metal{amount = 5},
				),
				"wait" = 20,
				"start_message" = "You begin prying apart the object",
				"done_message" = "You pry some metal off the object",
			),

			"metal" = list(
				"state" = null,
				"use_amount" = 5,
				"wait" = 20,
				"create" = list(
					/obj/machinery/door/airlock,
				),
			),
		),

		//This state exists only to show features not present in the other examples
		"another state" = list(
			"icon" = 'constructing_door.dmi',
			"icon_state" = "invisible",

			/obj/item/weapon/book = list(
				"state" = null,
				"name" = "alternate name",
				"desc" = "alternate description",
			),
		),
	)


/obj/constructing/airlock
	icon = 'constructing_airlock.dmi'
	initial_state = "frame"
	name = "Airlock frame"
	anchored = 0
	desc = "The frame for an airlock. It isn't attached to anything."

	states = list(
		"frame" = list(
			desc = "The frame for an airlock. It isn't attached to anything.",
			anchored = 0,

			"wrench" = list(
				state = "frame_anchored",
				done_message = "You attach the airlock frame to the floor.",
			),

			"screwdriver" = list(
				state = null,
				wait = 10,
				start_message = "You start to disassemble the airlock frame.",
				done_message = "You finish disassembling the airlock frame.",
				drop = list(
					/obj/item/weapon/sheet/metal {amount = 1},
				),
			),
		),

		"frame_anchored" = list(
			icon_state = "frame",
			"desc" = "The frame for an airlock.",
			anchored = 1,
			density = 0,

			"wrench" = list(
				state = "frame",
				done_message = "You detach the airlock frame.",
			),

			"glass" = list(
				state = "frame_glass",
				use_amount = 1,
				wait = 20,
				start_message = "You start putting glass windows in the airlock frame.",
				done_message = "You finish putting glass windows in the airlock frame.",
			),

			"metal" = list(
				state = "frame_metal",
				use_amount = 1,
				wait = 20,
				start_message = "You start putting metal plates in the airlock frame.",
				done_message = "You finish putting metal plates in the airlock frame.",
			),
		),

		"frame_glass" = list(
			"desc" = "The frame for an airlock with windows.",
			density = 1,

			"wrench" = list(
				state = "frame_anchored",
				wait = 10,
				start_message = "You start removing the windows from the airlock frame.",
				drop = list(
					/obj/item/weapon/sheet/glass {amount = 1},
				),
			),
		),

		"frame_metal" = list(
			density = 1,

			"wrench" = list(
				state = "frame_anchored",
				wait = 10,
				start_message = "You start removing the plates from the airlock frame.",
				drop = list(
					/obj/item/weapon/sheet/metal {amount = 1},
				),
			),
		),
	)

/*
The following are the various types of door, and their icons/states:

	/obj/machinery/door/airlock
		icon = 'doorint.dmi'
		icon_state = "door_closed"
	/obj/machinery/door/airlock/command
		name = "Airlock"
		icon = 'Doorcom.dmi'
	/obj/machinery/door/airlock/glass/command
		icon = 'Doorcomglass.dmi'
	/obj/machinery/door/airlock/security
		name = "Airlock"
		icon = 'Doorsec.dmi'
	/obj/machinery/door/airlock/glass/security
		icon = 'Doorsecglass.dmi'
	/obj/machinery/door/airlock/security/hatch
		icon = 'Doorhatcharmoury.dmi'
	/obj/machinery/door/airlock/engineering
		name = "Airlock"
		icon = 'Dooreng.dmi'
	/obj/machinery/door/airlock/glass/engineering
		icon = 'Doorengglass.dmi'
	/obj/machinery/door/airlock/medical
		name = "Airlock"
		icon = 'Doormed.dmi'
	/obj/machinery/door/airlock/science
		name = "Airlock"
		icon = 'Doorsci.dmi'
	/obj/machinery/door/airlock/glass/medical
		icon = 'Doormedglass.dmi'
	/obj/machinery/door/airlock/glass/science
		icon = 'Doorsciglass.dmi'
	/obj/machinery/door/airlock/maintenance
		name = "Maintenance Access"
		icon = 'Doormaint.dmi'
	/obj/machinery/door/airlock/maintenance/hatch
		name = "Maintenance Access"
		icon = 'Doorhatchmaint.dmi'
	/obj/machinery/door/airlock/external
		name = "External Airlock"
		icon = 'Doorext.dmi'
	/obj/machinery/door/airlock/glass
		name = "Glass Airlock"
		icon = 'Doorglass.dmi'
	/obj/machinery/door/airlock/highsec
		name = "Secure Airlock"
		icon = 'Doorhatchele.dmi'
	/obj/machinery/door/airlock/freezer
		icon = 'Doorfreezer.dmi'
*/