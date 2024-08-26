/// Logging for the creation and contraction of viruses
/proc/log_virus(text, list/data)
	logger.Log(LOG_CATEGORY_VIRUS, text, data)

/// Returns a string for admin logging uses, should describe the disease in detail
/datum/disease/proc/admin_details()
	return "[src.name] : [src.type]"

/// Describes this disease to an admin in detail (for logging)
/datum/disease/advance/admin_details()
	var/list/name_symptoms = list()
	for(var/datum/symptom/symptom in symptoms)
		name_symptoms += symptom.name
	return "[name] - sym: [english_list(name_symptoms)] - spread: [spreading_modifier] infect: [infectivity] speed: [stage_prob] cure%: [cure_chance]"

/// A truncated version of symptoms for ghost notification
/datum/disease/advance/proc/symptoms_list()
	var/list/name_symptoms = list()
	for(var/datum/symptom/symptom in symptoms)
		if(istype(symptom, /datum/symptom/viraladaptation) || istype(symptom, /datum/symptom/viralevolution))
			continue
		name_symptoms += symptom.name
	return english_list(name_symptoms)
