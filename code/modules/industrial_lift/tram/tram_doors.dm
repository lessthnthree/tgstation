#define AIRLOCK_CLOSED 1
#define AIRLOCK_CLOSING 2
#define AIRLOCK_OPEN 3
#define AIRLOCK_OPENING 4
#define AIRLOCK_DENY 5
#define AIRLOCK_EMAG 6
#define AIRLOCK_SECURITY_TRAM 5

#define AIRLOCK_FRAME_CLOSED "closed"
#define AIRLOCK_FRAME_CLOSING "closing"
#define AIRLOCK_FRAME_OPEN "open"
#define AIRLOCK_FRAME_OPENING "opening"

#define TRAM_DOOR_WARNING_TIME (1.4 SECONDS)
#define TRAM_DOOR_RECYCLE_TIME	(3 SECONDS)

/obj/machinery/door/airlock/tram
	name = "tram door"
	icon = 'icons/obj/doors/airlocks/tram/tram-solo.dmi'
	overlays_file = 'icons/obj/doors/airlocks/tram/tram-solo-overlays.dmi'
	opacity = FALSE
	assemblytype = null
	glass = TRUE
	airlock_material = "glass"
	air_tight = TRUE
	// req_access = list("tcomms")
	elevator_linked_id = MAIN_STATION_TRAM
	doorOpen = 'sound/machines/tramopen.ogg'
	doorClose = 'sound/machines/tramclose.ogg'
	autoclose = FALSE
	security_level = AIRLOCK_SECURITY_TRAM
	aiControlDisabled = AI_WIRE_DISABLED
	hackProof = TRUE
	/// Weakref to the tram we're attached
	var/datum/weakref/tram_ref
	/// Are the doors in a malfunctioning state (dangerous)
	var/malfunctioning = FALSE
	var/attempt = 0

/obj/machinery/door/airlock/tram/left
	name = "tram door"
	icon = 'icons/obj/doors/airlocks/tram/tram-left.dmi'
	overlays_file = 'icons/obj/doors/airlocks/tram/tram-left-overlays.dmi'

/obj/machinery/door/airlock/tram/right
	name = "tram door"
	icon = 'icons/obj/doors/airlocks/tram/tram-right.dmi'
	overlays_file = 'icons/obj/doors/airlocks/tram/tram-right-overlays.dmi'

/obj/machinery/door/window/tram
	name = "tram door"
	icon = 'icons/obj/doors/airlocks/tram/tram2.dmi'
	req_access = list("tcomms")
	var/associated_lift = MAIN_STATION_TRAM
	var/datum/weakref/tram_ref
	/// Are the doors in a malfunctioning state (dangerous)
	var/malfunctioning = FALSE

/obj/machinery/door/window/tram/left
	icon_state = "left"
	base_state = "left"

/obj/machinery/door/window/tram/right
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/tram/hilbert
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	associated_lift = HILBERT_TRAM
	icon_state = "windoor"
	base_state = "windoor"

/obj/machinery/door/window/tram/emag_act(mob/living/user)
	if(obj_flags & EMAGGED)
		return
	balloon_alert(user, "disabled motion sensors")
	obj_flags |= EMAGGED

/// Random event called by code\modules\events\tram_malfunction.dm
/// Makes the doors malfunction
/obj/machinery/door/window/tram/proc/start_malfunction()
	if(obj_flags & EMAGGED)
		return

	malfunctioning = TRUE
	process()

/// Random event called by code\modules\events\tram_malfunction.dm
/// Returns doors to their original status
/obj/machinery/door/window/tram/proc/end_malfunction()
	if(obj_flags & EMAGGED)
		return

	malfunctioning = FALSE
	process()

/obj/machinery/door/airlock/tram/proc/cycle_tram_doors(command, rapid)
	switch(command)
		if(OPEN_DOORS)
			if( operating || welded || locked || seal )
				return FALSE
			if(!density)
				return TRUE
			SEND_SIGNAL(src, COMSIG_AIRLOCK_OPEN, FALSE)
			operating = TRUE
			playsound(src, doorOpen, vol = 75, vary = FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
			update_icon(ALL, AIRLOCK_OPENING, TRUE)
			update_freelook_sight()
			sleep(0.7 SECONDS)
			set_density(FALSE)
			flags_1 &= ~PREVENT_CLICK_UNDER_1
			air_update_turf(TRUE, FALSE)
			layer = OPEN_DOOR_LAYER
			update_icon(ALL, AIRLOCK_OPEN, TRUE)
			operating = FALSE
			return TRUE

		if(CLOSE_DOORS)
			attempt_close(rapid)

/obj/machinery/door/airlock/tram/proc/attempt_close(rapid)
	attempt++

	message_admins("TRAM: Door close attempt [attempt]")
	if(attempt >= 3)
		say("DOORS ARE NOW CLOSING, ASSHOLE!")
		close(forced = BYPASS_DOOR_CHECKS, force_crush = TRUE)
		attempt = 0
	else
		playsound(src, 'sound/machines/chime.ogg', 40, vary = FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
		say("Doors are now closing!")
		sleep(TRAM_DOOR_WARNING_TIME)
		close(forced = BYPASS_DOOR_CHECKS)
		addtimer(CALLBACK(src, PROC_REF(verify_status)), 3 SECONDS)

/obj/machinery/door/airlock/tram/proc/verify_status()
	if(airlock_state != 1)
		if(attempt >=2)
			playsound(src, 'sound/machines/buzz-two.ogg', 60, vary = FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
		else
			playsound(src, 'sound/machines/buzz-sigh.ogg', 60, vary = FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
		say("Please stand clear of the doors!")
		attempt_close()
	else
		attempt = 0

/*
/obj/machinery/door/airlock/tram/close(forced = BYPASS_DOOR_CHECKS, force_crush = FALSE)
	if(operating || welded || locked || seal)
		return FALSE
	if(density)
		return TRUE

	use_power(50)
	playsound(src, doorClose, vol = 75, vary = FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	SEND_SIGNAL(src, COMSIG_AIRLOCK_CLOSE, forced)
	operating = TRUE
	do_animate(AIRLOCK_FRAME_CLOSING)
	layer = CLOSED_DOOR_LAYER
	sleep(0.5 SECONDS)
	if(!force_crush)
		for(var/atom/movable/M in get_turf(src))
			if(M.density && M != src) //something is blocking the door
				do_animate(AIRLOCK_FRAME_OPENING)
				say("Stand clear of the closing door!")
				addtimer(CALLBACK(src, PROC_REF(attempt_close)), TRAM_DOOR_RECYCLE_TIME, TIMER_UNIQUE | TIMER_NO_HASH_WAIT | TIMER_OVERRIDE)
				return FALSE
	set_density(TRUE)
	flags_1 |= PREVENT_CLICK_UNDER_1
	air_update_turf(TRUE, TRUE)
	sleep(0.5 SECONDS)
	crush()
	update_freelook_sight()
	update_icon(ALL, AIRLOCK_CLOSED, 1)
	operating = FALSE
	return TRUE
*/
/*
	if((obj_flags & EMAGGED) || malfunctioning)
		do_sparks(5, TRUE, src)
		playsound(src, SFX_SPARKS, vol = 75, vary = FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
		sleep(0.6 SECONDS)
	playsound(src, doorClose, vol = 75, vary = FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	update_icon(ALL, AIRLOCK_CLOSING, TRUE)
	layer = CLOSED_DOOR_LAYER
	flags_1 |= PREVENT_CLICK_UNDER_1
	air_update_turf(TRUE, TRUE)
	update_freelook_sight()
	sleep(1.4 SECONDS)
	if(attempt < 3)
		if(locate(/mob/living) in get_turf(src))
			message_admins("TRAM: Door close attempt [attempt] FAILED.")
			open(1)
			addtimer(CALLBACK(src, PROC_REF(attempt_close)), 3 SECONDS)
			return
	else
		message_admins("TRAM: Door close attempt [attempt] SUCCESS.")
		crush()
	attempt = 0
	set_density(TRUE)
	sleep(1 SECONDS)
	update_icon(ALL, AIRLOCK_CLOSED, 1)
	operating = FALSE
	return TRUE
*/

/obj/machinery/door/airlock/tram/try_to_force_door_open(force_type = FORCING_DOOR_CHECKS)
	use_power(50)
	playsound(src, doorOpen, vol = 50, vary = FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	return TRUE

/obj/machinery/door/airlock/tram/proc/find_tram()
	for(var/datum/lift_master/lift as anything in GLOB.active_lifts_by_type[TRAM_LIFT_ID])
		if(lift.specific_lift_id == elevator_linked_id)
			tram_ref = WEAKREF(lift)

/obj/machinery/door/airlock/tram/Initialize(mapload, set_dir, unres_sides)
	. = ..()
	RemoveElement(/datum/element/atmos_sensitive, mapload)
	INVOKE_ASYNC(src, PROC_REF(open))
	GLOB.tram_doors += src
	// find_tram()

/obj/machinery/door/window/tram/Destroy()
	GLOB.tram_doors -= src
	return ..()

/obj/machinery/door/window/tram/examine(mob/user)
	. = ..()
	. += span_notice("It has labels indicating that it has an emergency mechanism to open using <b>just your hands</b> in the event of an emergency.")

/obj/machinery/door/window/tram/try_safety_unlock(mob/user)
	if(!hasPower()  && density)
		balloon_alert(user, "pulling emergency exit...")
		if(do_after(user, 7 SECONDS, target = src))
			try_to_crowbar(null, user, TRUE)
			return TRUE

/obj/machinery/door/window/tram/bumpopen(mob/user)
	if(operating || !density)
		return
	var/datum/lift_master/tram/tram_part = tram_ref?.resolve()
	add_fingerprint(user)
	if(tram_part.travel_distance < XING_DEFAULT_TRAM_LENGTH || tram_part.travel_distance > tram_part.travel_trip_length - XING_DEFAULT_TRAM_LENGTH)
		return // we're already animating, don't reset that
	//cycle_doors(OPEN_DOORS, TRUE) //making a daring exit midtravel? make sure the doors don't go in the wrong state on arrival.
	return

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/door/window/tram/left, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/door/window/tram/right, 0)

#undef AIRLOCK_CLOSED
#undef AIRLOCK_CLOSING
#undef AIRLOCK_OPEN
#undef AIRLOCK_OPENING
#undef AIRLOCK_DENY
#undef AIRLOCK_EMAG
#undef AIRLOCK_SECURITY_TRAM
