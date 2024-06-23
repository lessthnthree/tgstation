/datum/preference/color/effigy
	abstract_type = /datum/preference/color/effigy
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	//relevant_inherent_trait = TRAIT_MUTANT_COLORS
	var/ext_identifier

/datum/preference/color/effigy/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	var/species_type = preferences.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = GLOB.species_prototypes[species_type]
	return !(TRAIT_FIXED_MUTANT_COLORS in species.inherent_traits)

/datum/preference/color/effigy/create_default_value()
	return sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]")

/datum/preference/color/effigy/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[ext_identifier] = value

/datum/preference/color/effigy/is_valid(value)
	if (!..(value))
		return FALSE

	if (is_color_dark(value, 15))
		return FALSE

	return TRUE

/datum/preference/color/effigy/ears
	savefile_key = "feature_ext_ear_color_1"
	ext_identifier = "ext_ear_color_1"

/datum/preference/color/effigy/ears/secondary
	savefile_key = "feature_ext_ear_color_2"
	ext_identifier = "ext_ear_color_2"

/datum/preference/color/effigy/ears/tertiary
	savefile_key = "feature_ext_ear_color_3"
	ext_identifier = "ext_ear_color_3"
