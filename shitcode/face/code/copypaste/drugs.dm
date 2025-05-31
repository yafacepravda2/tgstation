// Skyrat drugs

//the reagent itself
/datum/reagent/drug/thc
	name = "THC"
	description = "A chemical found in cannabis that serves as its main psychoactive component."
	color = "#cfa40c"
	overdose_threshold = 30 //just gives funny effects, but doesnt hurt you; thc has no actual known overdose
	ph = 6
	taste_description = "skunk"

/datum/reagent/drug/thc/concentrated
	name = "Concentrated THC"
	description = "TCH in pure concentrated form"

/datum/reagent/drug/thc/on_mob_life(mob/living/carbon/M, seconds_per_tick, times_fired)
	var/high_message = pick("You feel relaxed.", "You feel fucked up.", "You feel totally wrecked...")
	if(M.hud_used!=null)
		var/atom/movable/plane_master_controller/game_plane_master_controller = M.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
		game_plane_master_controller.add_filter("weed_blur", 10, angular_blur_filter(0, 0, 0.45))
	if(SPT_PROB(2.5, seconds_per_tick))
		to_chat(M, span_notice("[high_message]"))
	M.add_mood_event("stoned", /datum/mood_event/stoned, 1, name)
	M.throw_alert("stoned", /atom/movable/screen/alert/stoned)
	M.sound_environment_override = SOUND_ENVIRONMENT_DRUGGED
	M.set_dizzy_if_lower(5 * REM * seconds_per_tick * 2 SECONDS)
	M.adjust_nutrition(-1 * REM * seconds_per_tick) //munchies
	if(SPT_PROB(3.5, seconds_per_tick))
		M.emote(pick("laugh","giggle"))
	..()

/datum/reagent/drug/thc/on_mob_end_metabolize(mob/living/carbon/M)
	. = ..()
	if(M.hud_used!=null)
		var/atom/movable/plane_master_controller/game_plane_master_controller = M.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
		game_plane_master_controller.remove_filter("weed_blur")
	M.clear_alert("stoned")
	M.sound_environment_override = SOUND_ENVIRONMENT_NONE

/datum/reagent/drug/thc/overdose_process(mob/living/M, seconds_per_tick, times_fired)
	var/cg420_message = pick("It's major...", "Oh my goodness...",)
	if(SPT_PROB(1.5, seconds_per_tick))
		M.say("[cg420_message]")
	M.adjust_drowsiness(0.2 SECONDS * REM * normalise_creation_purity() * seconds_per_tick)
	if(SPT_PROB(3.5, seconds_per_tick))
		playsound(M, pick('shitcode/face/sounds/misc/lungbust_cough1.ogg','shitcode/face/sounds/misc/lungbust_cough2.ogg'), 50, TRUE)
		M.emote("cough")
	..()
	. = TRUE

/datum/reagent/drug/thc/hash //only exists to generate hash object
	name = "hashish"
	description = "Concentrated cannabis extract. Delivers a much better high when used in a bong."
	color = "#cfa40c"

/obj/item/reagent_containers/hash
	name = "hash"
	desc = "Concentrated cannabis extract. Delivers a much better high when used in a bong."
	icon = 'shitcode/face/icons/obj/crack.dmi'
	icon_state = "hash"
	volume = 20
	has_variable_transfer_amount = FALSE
	list_reagents = list(/datum/reagent/drug/thc = 15, /datum/reagent/toxin/lipolicide = 5)

/obj/item/reagent_containers/hash/dabs
	name = "dab"
	desc = "Oil extract from cannabis plants. Just delivers a different type of hit."
	icon = 'shitcode/face/icons/obj/crack.dmi'
	icon_state = "dab"
	volume = 40
	has_variable_transfer_amount = FALSE
	list_reagents = list(/datum/reagent/drug/thc/concentrated = 40) //horrendously powerful

/obj/item/reagent_containers/hashbrick
	name = "hash brick"
	desc = "A brick of hash. Good for transport!"
	icon = 'shitcode/face/icons/obj/crack.dmi'
	icon_state = "hashbrick"
	volume = 80
	has_variable_transfer_amount = FALSE
	list_reagents = list(/datum/reagent/drug/thc = 60, /datum/reagent/toxin/lipolicide = 20)


/obj/item/reagent_containers/hashbrick/attack_self(mob/user)
	user.visible_message(span_notice("[user] starts breaking up the [src]."))
	if(do_after(user,10))
		to_chat(user, span_notice("You finish breaking up the [src]."))
		for(var/i = 1 to 4)
			new /obj/item/reagent_containers/hash(user.loc)
		qdel(src)

/datum/crafting_recipe/hashbrick
	name = "Hash brick"
	result = /obj/item/reagent_containers/hashbrick
	reqs = list(/obj/item/reagent_containers/hash = 4)
	parts = list(/obj/item/reagent_containers/hash = 4)
	time = 20
	category = CAT_CHEMISTRY

/obj/item/food/grown/cannabis/on_grind()
	. = ..()
	if(HAS_TRAIT(src, TRAIT_DRIED))
		grind_results = list(/datum/reagent/drug/thc/hash = 0.15*src.seed.potency)
		reagents.clear_reagents() //prevents anything else from coming out

/datum/chemical_reaction/hash
	required_reagents = list(/datum/reagent/drug/thc/hash = 10)
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL

/datum/chemical_reaction/hash/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/reagent_containers/hash(location)

/datum/chemical_reaction/dabs
	required_reagents = list(/datum/reagent/drug/thc = 20)
	required_temp = 420 //haha very funny
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL

/datum/chemical_reaction/dabs/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/reagent_containers/hash/dabs(location)

//shit for effects
/datum/mood_event/stoned
	description = span_nicegreen("You're totally baked right now...\n")
	mood_change = 6
	timeout = 3 MINUTES

/atom/movable/screen/alert/stoned
	name = "Stoned"
	desc = "You're stoned out of your mind! Woaaahh..."
	icon_state = "high"

//export values
/datum/export/hash
	cost = CARGO_CRATE_VALUE * 0.35
	unit_name = "hash"
	export_types = list(/obj/item/reagent_containers/hash)
	include_subtypes = FALSE

/datum/export/crack/hashbrick
	cost = CARGO_CRATE_VALUE * 2
	unit_name = "hash brick"
	export_types = list(/obj/item/reagent_containers/hashbrick)
	include_subtypes = FALSE

/datum/export/dab
	cost = CARGO_CRATE_VALUE * 0.4
	unit_name = "dab"
	export_types = list(/obj/item/reagent_containers/hash/dabs)
	include_subtypes = FALSE

/datum/chemical_reaction/powder_cocaine
	is_cold_recipe = TRUE
	required_reagents = list(/datum/reagent/drug/cocaine = 10)
	required_temp = 250 //freeze it
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL
	mix_message = "The solution freezes into a powder!"

/datum/chemical_reaction/powder_cocaine/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/reagent_containers/cocaine(location)

/datum/chemical_reaction/freebase_cocaine
	required_reagents = list(/datum/reagent/drug/cocaine = 10, /datum/reagent/water = 5, /datum/reagent/ash = 10) //mix 20 cocaine, 10 water, 20 ash
	required_temp = 480 //heat it up
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL

/datum/chemical_reaction/freebase_cocaine/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/reagent_containers/crack(location)

/datum/reagent/drug/cocaine
	name = "cocaine"
	description = "A powerful stimulant extracted from coca leaves. Reduces stun times, but causes drowsiness and severe brain damage if overdosed."
	color = "#ffffff"
	overdose_threshold = 20
	ph = 9
	taste_description = "bitterness" //supposedly does taste bitter in real life
	addiction_types = list(/datum/addiction/stimulants = 14) //5.6 per 2 seconds

/datum/reagent/drug/cocaine/on_mob_metabolize(mob/living/containing_mob)
	..()
	ADD_TRAIT(containing_mob, TRAIT_BATON_RESISTANCE, type)

/datum/reagent/drug/cocaine/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(30, seconds_per_tick))
		if(affected_mob.adjustToxLoss(1 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
			return UPDATE_MOB_HEALTH

/datum/reagent/drug/cocaine/on_mob_end_metabolize(mob/living/containing_mob)
	REMOVE_TRAIT(containing_mob, TRAIT_BATON_RESISTANCE, type)
	..()

/datum/reagent/drug/cocaine/on_mob_life(mob/living/carbon/M, seconds_per_tick, times_fired)
	if(SPT_PROB(2.5, seconds_per_tick))
		var/high_message = pick("You feel jittery.", "You feel like you gotta go fast.", "You feel like you need to step it up.")
		to_chat(M, span_notice("[high_message]"))
	M.add_mood_event("zoinked", /datum/mood_event/stimulant_heavy, 1, name)
	M.AdjustStun(-15 * REM * seconds_per_tick)
	M.AdjustKnockdown(-15 * REM * seconds_per_tick)
	M.AdjustUnconscious(-15 * REM * seconds_per_tick)
	M.AdjustImmobilized(-15 * REM * seconds_per_tick)
	M.AdjustParalyzed(-15 * REM * seconds_per_tick)
	M.adjustStaminaLoss(-2 * REM * seconds_per_tick, 0)
	if(SPT_PROB(2.5, seconds_per_tick))
		M.emote("shiver")
	..()
	. = TRUE

/datum/reagent/drug/cocaine/overdose_start(mob/living/M)
	to_chat(M, span_userdanger("Your heart beats is beating so fast, it hurts..."))

/datum/reagent/drug/cocaine/overdose_process(mob/living/M, seconds_per_tick, times_fired)
	M.adjustToxLoss(5 * REM * seconds_per_tick, 0)
	M.adjustOrganLoss(ORGAN_SLOT_HEART, (rand(10, 20) / 10) * REM * seconds_per_tick)
	M.set_jitter_if_lower(5 SECONDS)
	if(SPT_PROB(2.5, seconds_per_tick))
		M.emote(pick("twitch","drool"))
	if(!HAS_TRAIT(M, TRAIT_FLOORED))
		if(SPT_PROB(1.5, seconds_per_tick))
			M.visible_message(span_danger("[M] collapses onto the floor!"))
			M.Paralyze(135,TRUE)
			M.drop_all_held_items()
	..()
	. = TRUE

/datum/reagent/drug/cocaine/freebase_cocaine
	name = "freebase cocaine"
	description = "A smokable form of cocaine."
	color = "#f0e6bb"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/drug/cocaine/powder_cocaine
	name = "powder cocaine"
	description = "The powder form of cocaine."
	color = "#ffffff"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/obj/item/reagent_containers/crack
	name = "crack"
	desc = "A rock of freebase cocaine, otherwise known as crack."
	icon = 'shitcode/face/icons/obj/crack.dmi'
	icon_state = "crack"
	volume = 10
	has_variable_transfer_amount = FALSE
	list_reagents = list(/datum/reagent/drug/cocaine/freebase_cocaine = 10)

/obj/item/reagent_containers/crackbrick
	name = "crack brick"
	desc = "A brick of crack cocaine."
	icon = 'shitcode/face/icons/obj/crack.dmi'
	icon_state = "crackbrick"
	volume = 40
	has_variable_transfer_amount = FALSE
	list_reagents = list(/datum/reagent/drug/cocaine/freebase_cocaine = 40)

/obj/item/reagent_containers/crackbrick/attackby(obj/item/W, mob/user, params)
	if(W.get_sharpness())
		user.show_message(span_notice("You cut \the [src] into some rocks."), MSG_VISUAL)
		for(var/i = 1 to 4)
			new /obj/item/reagent_containers/crack(user.loc)
		qdel(src)

/datum/crafting_recipe/crackbrick
	name = "Crack brick"
	result = /obj/item/reagent_containers/crackbrick
	reqs = list(/obj/item/reagent_containers/crack = 4)
	parts = list(/obj/item/reagent_containers/crack = 4)
	time = 20
	category = CAT_CHEMISTRY //i might just make a crafting category for drugs at some point

// Should probably give this the edible component at some point
/obj/item/reagent_containers/cocaine
	name = "cocaine"
	desc = "Reenact your favorite scenes from Scarface!"
	icon = 'shitcode/face/icons/obj/crack.dmi'
	icon_state = "cocaine"
	volume = 5
	has_variable_transfer_amount = FALSE
	list_reagents = list(/datum/reagent/drug/cocaine = 5)

/obj/item/reagent_containers/cocaine/proc/snort(mob/living/user)
	if(!iscarbon(user))
		return
	var/covered = ""
	if(user.is_mouth_covered(ITEM_SLOT_HEAD))
		covered = "headgear"
	else if(user.is_mouth_covered(ITEM_SLOT_MASK))
		covered = "mask"
	if(covered)
		to_chat(user, span_warning("You have to remove your [covered] first!"))
		return
	user.visible_message(span_notice("[user] starts snorting the [src]."))
	if(do_after(user, 30))
		to_chat(user, span_notice("You finish snorting the [src]."))
		if(reagents.total_volume)
			reagents.trans_to(user, reagents.total_volume, transferred_by = user, methods = INGEST)
		qdel(src)

/obj/item/reagent_containers/cocaine/attack(mob/target, mob/user)
	if(target == user)
		snort(user)

/obj/item/reagent_containers/cocaine/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	. = SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(!in_range(user, src) || user.get_active_held_item())
		return

	snort(user)

	return

/obj/item/reagent_containers/cocainebrick
	name = "cocaine brick"
	desc = "A brick of cocaine. Good for transport!"
	icon = 'shitcode/face/icons/obj/crack.dmi'
	icon_state = "cocainebrick"
	volume = 25
	has_variable_transfer_amount = FALSE
	list_reagents = list(/datum/reagent/drug/cocaine = 25)


/obj/item/reagent_containers/cocainebrick/attack_self(mob/user)
	user.visible_message(span_notice("[user] starts breaking up the [src]."))
	if(do_after(user,10))
		to_chat(user, span_notice("You finish breaking up the [src]."))
		for(var/i = 1 to 5)
			new /obj/item/reagent_containers/cocaine(user.loc)
		qdel(src)

/datum/crafting_recipe/cocainebrick
	name = "Cocaine brick"
	result = /obj/item/reagent_containers/cocainebrick
	reqs = list(/obj/item/reagent_containers/cocaine = 5)
	parts = list(/obj/item/reagent_containers/cocaine = 5)
	time = 20
	category = CAT_CHEMISTRY //i might just make a crafting category for drugs at some point

//if you want money, convert it into crackbricks
/datum/export/crack
	cost = CARGO_CRATE_VALUE * 0.5
	unit_name = "crack"
	export_types = list(/obj/item/reagent_containers/crack)
	include_subtypes = FALSE

/datum/export/crack/crackbrick
	cost = CARGO_CRATE_VALUE * 2.5
	unit_name = "crack brick"
	export_types = list(/obj/item/reagent_containers/crackbrick)
	include_subtypes = FALSE

/datum/export/cocaine
	cost = CARGO_CRATE_VALUE * 0.4
	unit_name = "cocaine"
	export_types = list(/obj/item/reagent_containers/cocaine)
	include_subtypes = FALSE

/datum/export/cocainebrick
	cost = CARGO_CRATE_VALUE * 2
	unit_name = "cocaine brick"
	export_types = list(/obj/item/reagent_containers/cocainebrick)
	include_subtypes = FALSE

// <------------------------------------->
// Opium

/datum/chemical_reaction/heroin
	results = list(/datum/reagent/drug/opium/heroin = 4)
	required_reagents = list(/datum/reagent/drug/opium = 2, /datum/reagent/acetone = 2)
	reaction_tags = REACTION_TAG_CHEMICAL
	required_temp = 480
	optimal_ph_min = 8
	optimal_ph_max = 12
	H_ion_release = -0.04
	rate_up_lim = 12.5
	purity_min = 0.5

/datum/chemical_reaction/powder_heroin
	is_cold_recipe = TRUE
	required_reagents = list(/datum/reagent/drug/opium/heroin = 8)
	required_temp = 250 //freeze it
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL
	mix_message = "The solution freezes into a powder!"

/datum/chemical_reaction/powder_heroin/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/reagent_containers/heroin(location)

/obj/item/reagent_containers/heroin
	name = "heroin"
	desc = "Take a line and take some time of man."
	icon = 'shitcode/face/icons/obj/crack.dmi'
	icon_state = "heroin"
	volume = 4
	has_variable_transfer_amount = FALSE
	list_reagents = list(/datum/reagent/drug/opium/heroin = 4)

/obj/item/reagent_containers/heroin/proc/snort(mob/living/user)
	if(!iscarbon(user))
		return
	var/covered = ""
	if(user.is_mouth_covered(ITEM_SLOT_HEAD))
		covered = "headgear"
	else if(user.is_mouth_covered(ITEM_SLOT_MASK))
		covered = "mask"
	if(covered)
		to_chat(user, span_warning("You have to remove your [covered] first!"))
		return
	user.visible_message(span_notice("'[user] starts snorting the [src]."))
	if(do_after(user, 30))
		to_chat(user, span_notice("You finish snorting the [src]."))
		if(reagents.total_volume)
			reagents.trans_to(user, reagents.total_volume, transferred_by = user, methods = INGEST)
		qdel(src)

/obj/item/reagent_containers/heroin/attack(mob/target, mob/user)
	if(target == user)
		snort(user)

/obj/item/reagent_containers/heroin/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	. = SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(!in_range(user, src) || user.get_active_held_item())
		return

	snort(user)

	return

/obj/item/reagent_containers/heroinbrick
	name = "heroin brick"
	desc = "A brick of heroin. Good for transport!"
	icon = 'shitcode/face/icons/obj/crack.dmi'
	icon_state = "heroinbrick"
	volume = 20
	has_variable_transfer_amount = FALSE
	list_reagents = list(/datum/reagent/drug/opium/heroin = 20)


/obj/item/reagent_containers/heroinbrick/attack_self(mob/user)
	user.visible_message(span_notice("[user] starts breaking up the [src]."))
	if(do_after(user,10))
		to_chat(user, span_notice("You finish breaking up the [src]."))
		for(var/i = 1 to 5)
			new /obj/item/reagent_containers/heroin(user.loc)
		qdel(src)

/datum/crafting_recipe/heroinbrick
	name = "heroin brick"
	result = /obj/item/reagent_containers/heroinbrick
	reqs = list(/obj/item/reagent_containers/heroin = 5)
	parts = list(/obj/item/reagent_containers/heroin = 5)
	time = 20
	category = CAT_CHEMISTRY

/obj/item/reagent_containers/blacktar
	name = "black tar heroin"
	desc = "A rock of black tar heroin, an impure freebase form of heroin."
	icon = 'shitcode/face/icons/obj/crack.dmi'
	icon_state = "blacktar"
	volume = 5
	has_variable_transfer_amount = FALSE
	list_reagents = list(/datum/reagent/drug/opium/blacktar = 5)

/atom/movable/screen/fullscreen/color_vision/heroin_color
	color = "#444444"

/datum/reagent/drug/opium
	name = "opium"
	description = "A extract from opium poppies. Puts the user in a slightly euphoric state."
	color = "#ffe669"
	overdose_threshold = 30
	ph = 8
	taste_description = "flowers"
	addiction_types = list(/datum/addiction/opioids = 18)

/datum/reagent/drug/opium/on_mob_life(mob/living/carbon/M, seconds_per_tick, times_fired)
	var/high_message = pick("You feel euphoric.", "You feel on top of the world.")
	if(SPT_PROB(2.5, seconds_per_tick))
		to_chat(M, span_notice("[high_message]"))
	M.add_mood_event("smacked out", /datum/mood_event/narcotic_heavy, 1, name)
	M.adjustBruteLoss(-0.1 * REM * seconds_per_tick, 0) //can be used as a (shitty) painkiller
	M.adjustFireLoss(-0.1 * REM * seconds_per_tick, 0)
	M.overlay_fullscreen("heroin_euphoria", /atom/movable/screen/fullscreen/color_vision/heroin_color)
	return ..()

/datum/reagent/drug/opium/overdose_process(mob/living/M, seconds_per_tick, times_fired)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.5 * REM * seconds_per_tick)
	M.adjustToxLoss(1 * REM * seconds_per_tick, 0)
	M.adjust_drowsiness(1 SECONDS * REM * normalise_creation_purity() * seconds_per_tick)
	return TRUE

/datum/reagent/drug/opium/on_mob_metabolize(mob/living/metabolizer)
	. = ..()
	metabolizer.apply_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)

/datum/reagent/drug/opium/on_mob_end_metabolize(mob/living/metabolizer)
	. = ..()
	metabolizer.remove_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)
	metabolizer.clear_fullscreen("heroin_euphoria")

/datum/reagent/drug/opium/heroin
	name = "heroin"
	description = "She's like heroin to me, she's like heroin to me! She cannot... miss a vein!"
	color = "#ffe669"
	overdose_threshold = 20
	ph = 6
	taste_description = "flowers"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	inverse_chem = /datum/reagent/drug/opium/blacktar/liquid

/datum/reagent/drug/opium/heroin/on_mob_life(mob/living/carbon/M, seconds_per_tick, times_fired)
	var/high_message = pick("You feel like nothing can stop you.", "You feel like God.")
	if(SPT_PROB(2.5, seconds_per_tick))
		to_chat(M, span_notice("[high_message]"))
	M.adjustBruteLoss(-0.4 * REM * seconds_per_tick, 0) //more powerful as a painkiller, possibly actually useful to medical now
	M.adjustFireLoss(-0.4 * REM * seconds_per_tick, 0)
	..()

/datum/reagent/drug/opium/blacktar
	name = "black tar heroin"
	description = "An impure, freebase form of heroin. Probably not a good idea to take this..."
	color = "#242423"
	overdose_threshold = 10 //more easy to overdose on
	ph = 8
	taste_description = "flowers"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/drug/opium/blacktar/on_mob_life(mob/living/carbon/M, seconds_per_tick, times_fired)
	var/high_message = pick("You feel like tar.", "The blood in your veins feel like syrup.")
	if(SPT_PROB(2.5, seconds_per_tick))
		to_chat(M, span_notice("[high_message]"))

	M.set_drugginess(20 SECONDS * REM * seconds_per_tick)
	M.adjustToxLoss(0.5 * REM * seconds_per_tick, 0) //toxin damage
	return ..()

/datum/reagent/drug/opium/blacktar/liquid //prevents self-duplication by going one step down when mixed
	name = "liquid black tar heroin"

/datum/chemical_reaction/blacktar
	required_reagents = list(/datum/reagent/drug/opium/blacktar/liquid = 5)
	required_temp = 480
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL

/datum/chemical_reaction/blacktar/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/reagent_containers/blacktar(location)

//Exports
/datum/export/heroin
	cost = CARGO_CRATE_VALUE * 0.5
	unit_name = "heroin"
	export_types = list(/obj/item/reagent_containers/heroin)
	include_subtypes = FALSE

/datum/export/heroinbrick
	cost = CARGO_CRATE_VALUE * 2.5
	unit_name = "heroin brick"
	export_types = list(/obj/item/reagent_containers/heroinbrick)
	include_subtypes = FALSE

/datum/export/blacktar
	cost = CARGO_CRATE_VALUE * 0.4
	unit_name = "black tar heroin"
	export_types = list(/obj/item/reagent_containers/blacktar)
	include_subtypes = FALSE

/obj/item/seeds/poppy/opiumpoppy
	name = "opium poppy seed pack"
	desc = "These seeds grow into real opium poppies."
	icon = 'shitcode/face/icons/misc/seeds.dmi'
	growing_icon = 'shitcode/face/icons/misc/growing.dmi'
	icon_state = "seed-opiumpoppy"
	species = "opiumpoppy"
	plant_icon_offset = 4
	icon_grow = "opiumpoppy-grow"
	icon_dead = "opiumpoppy-dead"
	plantname = "Opium Poppy Plants"
	product = /obj/item/food/grown/poppy/opiumpoppy
	reagents_add = list(/datum/reagent/drug/opium = 0.3, /datum/reagent/toxin/fentanyl = 0.075, /datum/reagent/consumable/nutriment = 0.05)
	slot_flags = null

/obj/item/food/grown/poppy/opiumpoppy
	seed = /obj/item/seeds/poppy/opiumpoppy
	name = "opium poppy seedpod"
	desc = "The seedpod of the opium poppy plant, which contain opium latex."
	icon = 'shitcode/face/icons/misc/harvest.dmi'
	icon_state = "opiumpoppy"
	worn_icon_state = "map_flower"
	greyscale_config = null
	greyscale_config_worn = /datum/greyscale_config/flower_simple_worn
	greyscale_colors = "#01690f"
	distill_reagent = /datum/reagent/consumable/ethanol/turbo //How can a slow drug make fast drink? Don't question it.

/obj/item/seeds/cocaleaf
	name = "coca leaf seed pack"
	desc = "These seeds grow into coca shrubs. They make you feel energized just looking at them..."
	icon = 'shitcode/face/icons/misc/seeds.dmi'
	growing_icon = 'shitcode/face/icons/misc/growing.dmi'
	icon_state = "seed-cocoleaf"
	species = "cocoleaf"
	plantname = "Coca Leaves"
	plant_icon_offset = 4
	maturation = 8
	potency = 20
	growthstages = 1
	product = /obj/item/food/grown/cocaleaf
	mutatelist = list()
	reagents_add = list(/datum/reagent/drug/cocaine = 0.3, /datum/reagent/consumable/nutriment = 0.15)

/obj/item/food/grown/cocaleaf
	seed = /obj/item/seeds/cocaleaf
	name = "coca leaf"
	desc = "A leaf of the coca shrub, which contains a potent psychoactive alkaloid known as 'cocaine'."
	icon = 'shitcode/face/icons/misc/harvest.dmi'
	icon_state = "cocoleaf"
	foodtypes = FRUIT //i guess? i mean it grows on trees...
	tastes = list("leaves" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/sins_delight //Cocaine is one hell of a sin.
