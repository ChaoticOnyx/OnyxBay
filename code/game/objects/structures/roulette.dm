/obj/structure/casino
	icon = 'icons/obj/roulette.dmi'

	density = TRUE
	anchored = TRUE

/obj/structure/casino/chart
	name = "roulette chart"
	desc = "Roulette chart. Place your bets!"

	icon_state = "roulette_l"

/obj/structure/casino/roulette
	name = "roulette"
	desc = "Spin the roulette to try your luck."

	icon_state = "roulette_r"

	var/spinning = FALSE

/obj/structure/casino/roulette/Initialize()
	. = ..()
	add_think_ctx("spin_context", CALLBACK(src, nameof(.proc/finish_spin)), 0)

/obj/structure/casino/roulette/attack_hand(mob/user)
	if(spinning)
		show_splash_text(user, "already spinning!", "The roulette is already spinning!")
		return

	visible_message(SPAN("notice", "[user] spins \the [src] and throws a little ball inside!"))
	spinning = TRUE

	add_fingerprint(user)

	// I HAVE NO CLUE WHAT'S GOING ON
	var/n = rand(0, 36)
	var/color = "green"
	if((n > 0 && n < 11) || (n > 18 && n < 29))
		if(n % 2)
			color = "red"
	else
		color = "black"

	if((n > 10 && n < 19) || (n > 28) )
		if(n % 2)
			color = "black"
	else
		color = "red"

	set_next_think_ctx("spin_context", world.time + 5 SECONDS, n, color)

/obj/structure/casino/roulette/proc/finish_spin(number, color)
	visible_message(SPAN("notice", "\The [src] stops spinning, the ball landing on [number], [color]."))
	spinning = FALSE
