/obj/structure/window/reinforced/tram
	name = "tram"
	desc = "A reinforced, air-locked modular tram structure with titanium silica windows."
	icon = 'icons/obj/smooth_structures/tram_structure.dmi'
	icon_state = "tram-part-0"
	base_icon_state = "tram-part"
	max_integrity = 150
	wtype = "tram"
	reinf = TRUE
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	obj_flags = CAN_BE_HIT
	heat_resistance = 1600
	armor_type = /datum/armor/tram_structure
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_INDUSTRIAL_LIFT
	canSmoothWith = SMOOTH_GROUP_INDUSTRIAL_LIFT
	explosion_block = 3
	glass_type = /obj/item/stack/sheet/titaniumglass
	glass_amount = 2
	receive_ricochet_chance_mod = 1.2
	rad_insulation = RAD_MEDIUM_INSULATION
	glass_material_datum = /datum/material/alloy/titaniumglass

/datum/armor/tram_structure
	melee = 80
	bullet = 5
	bomb = 45
	fire = 99
	acid = 100

/obj/structure/window/reinforced/tram/spoiler
	name = "tram spoiler"
	desc = "Nanotrasen bought the luxury package under the impression titanium spoilers make the tram go faster. They're just for looks, or potentially stabbing anybody who gets in the way."
	smoothing_flags = NONE
	smoothing_groups = NONE
	icon_state = "tram-spoiler-retracted"
	///Position of the spoiler
	var/deployed = FALSE
	///Weakref to the tram piece we control
	var/datum/weakref/tram_ref
	///The tram we're attached to
	var/tram_id = MAIN_STATION_TRAM

/obj/structure/window/reinforced/tram/spoiler/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/window/reinforced/tram/spoiler/LateInitialize()
	. = ..()
	find_tram()

	var/datum/lift_master/tram/tram_part = tram_ref?.resolve()
	if(tram_part)
		RegisterSignal(tram_part, COMSIG_TRAM_SET_TRAVELLING, PROC_REF(set_spoiler))

/obj/structure/window/reinforced/tram/spoiler/proc/find_tram()
	for(var/datum/lift_master/tram/tram as anything in GLOB.active_lifts_by_type[TRAM_LIFT_ID])
		if(tram.specific_lift_id != tram_id)
			continue
		tram_ref = WEAKREF(tram)
		break

/obj/structure/window/reinforced/tram/spoiler/proc/set_spoiler(source, travelling, direction)
	SIGNAL_HANDLER

	if(!travelling)
		return
	switch(direction)
		if(SOUTH, EAST)
			switch(dir)
				if(NORTH, EAST)
					retract_spoiler()
				if(SOUTH, WEST)
					deploy_spoiler()
		if(NORTH, WEST)
			switch(dir)
				if(NORTH, EAST)
					deploy_spoiler()
				if(SOUTH, WEST)
					retract_spoiler()
	return

/obj/structure/window/reinforced/tram/spoiler/proc/deploy_spoiler()
	if(deployed)
		return
	flick("tram-spoiler-deploying", src)
	icon_state = "tram-spoiler-deployed"
	deployed = TRUE

/obj/structure/window/reinforced/tram/spoiler/proc/retract_spoiler()
	if(!deployed)
		return
	flick("tram-spoiler-retracting", src)
	icon_state = "tram-spoiler-retracted"
	deployed = FALSE

/obj/structure/chair/sofa/bench/tram
	name = "bench"
	desc = "Perfectly designed to be comfortable to sit on, and hellish to sleep on."
	icon_state = "bench_middle"
	greyscale_config = /datum/greyscale_config/bench_middle
	greyscale_colors = "#00CCFF"



/obj/structure/chair/sofa/bench/tram/left
	icon_state = "bench_left"
	greyscale_config = /datum/greyscale_config/bench_left

/obj/structure/chair/sofa/bench/tram/right
	icon_state = "bench_right"
	greyscale_config = /datum/greyscale_config/bench_right

/obj/structure/chair/sofa/bench/tram/corner
	icon_state = "bench_corner"
	greyscale_config = /datum/greyscale_config/bench_corner

/obj/structure/chair/sofa/bench/tram/solo
	icon_state = "bench_solo"
	greyscale_config = /datum/greyscale_config/bench_solo
