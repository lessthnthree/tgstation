/proc/generate_icon_with_ears_accessory(datum/sprite_accessory/sprite_accessory, y_offset = 0)
	var/static/icon/head_icon
	if (isnull(head_icon))
		head_icon = icon('icons/mob/human/bodyparts_greyscale.dmi', "human_head_m")
		head_icon.Blend(skintone2hex("caucasian1"), ICON_MULTIPLY)

	var/icon/final_icon = new(head_icon)
	if (!isnull(sprite_accessory))
		ASSERT(istype(sprite_accessory))

		var/icon/head_accessory_icon = icon(sprite_accessory.icon, "m_ears_[sprite_accessory.icon_state]_ADJ_primary", SOUTH)
		if(y_offset)
			head_accessory_icon.Shift(NORTH, y_offset)
		head_accessory_icon.Blend(COLOR_DARK_BROWN, ICON_MULTIPLY)
		final_icon.Blend(head_accessory_icon, ICON_OVERLAY)

		if(sprite_accessory.hasinner)
			var/icon/inner_accessory_icon = icon(sprite_accessory.icon, "m_ears_[sprite_accessory.icon_state]_ADJ_secondary", SOUTH)
			if(y_offset)
				inner_accessory_icon.Shift(NORTH, y_offset)
			inner_accessory_icon.Blend(COLOR_DARK_BROWN, ICON_MULTIPLY)
			final_icon.Blend(inner_accessory_icon, ICON_OVERLAY)

	final_icon.Crop(10, 19, 22, 31)
	final_icon.Scale(32, 32)

	return final_icon

/datum/preference/choiced/tail_human
	savefile_key = "feature_human_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	can_randomize = FALSE
	relevant_external_organ = /obj/item/organ/external/tail/cat

/datum/preference/choiced/tail_human/init_possible_values()
	return assoc_to_keys_features(SSaccessories.tails_list_human)

/datum/preference/choiced/tail_human/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_cat"] = value

/datum/preference/choiced/tail_human/create_default_value()
	var/datum/sprite_accessory/tails/human/cat/tail = /datum/sprite_accessory/tails/human/cat
	return initial(tail.name)

/datum/preference/choiced/ears
	savefile_key = "feature_human_ears"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE
	relevant_mutant_bodypart = "ears"
	//category = PREFERENCE_CATEGORY_SECONDARY_FEATURES

	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Ears"
	should_generate_icons = TRUE

/datum/preference/choiced/ears/init_possible_values()
	return assoc_to_keys_features(SSaccessories.ears_list)

/datum/preference/choiced/ears/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["ears"] = value

/datum/preference/choiced/ears/create_default_value()
	var/datum/sprite_accessory/ears/cat/ears = /datum/sprite_accessory/ears/cat
	return initial(ears.name)

/datum/preference/choiced/ears/icon_for(value)
	//return generate_felinid_side_shot(SSaccessories.ears_list[value], "ears")
	return generate_icon_with_ears_accessory(SSaccessories.ears_list[value])

/datum/preference/choiced/ears/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "feature_ext_ear_color_1"

	return data
