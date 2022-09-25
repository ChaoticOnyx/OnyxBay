/obj/structure/barrel
    name = "barrel"
    desc = "A barrel."
    icon = 'icons/obj/objects.dmi'
    icon_state = "barrel"

/obj/structure/barell/Initialize()
    . = ..()
    set_light(0.3, 0.5, 3, 4.0, "#da6a02")
