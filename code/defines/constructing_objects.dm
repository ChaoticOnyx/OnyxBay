


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
	)