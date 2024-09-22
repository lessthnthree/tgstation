SUBSYSTEM_DEF(disease)
	name = "Disease"
	flags = SS_NO_FIRE

	/// List of Active disease in all mobs; purely for quick referencing.
	var/list/active_diseases = list()
	/// List of Event disease in all mobs; purely for quick referencing.
	var/list/event_diseases = list()
	var/list/diseases
	var/list/archive_diseases = list()

	var/static/list/list_symptoms = subtypesof(/datum/symptom)

/datum/controller/subsystem/disease/PreInit()
	if(!diseases)
		diseases = subtypesof(/datum/disease)

/datum/controller/subsystem/disease/Initialize()
	var/list/all_common_diseases = diseases - typesof(/datum/disease/advance)
	for(var/common_disease_type in all_common_diseases)
		var/datum/disease/prototype = new common_disease_type()
		archive_diseases[prototype.GetDiseaseID()] = prototype
	return SS_INIT_SUCCESS

/datum/controller/subsystem/disease/stat_entry(msg)
	msg = "P:[length(active_diseases)] | EV:[length(event_diseases)]"
	return ..()

/datum/controller/subsystem/disease/proc/get_disease_name(id)
	var/datum/disease/advance/archive = archive_diseases[id]
	if(archive.name)
		return archive.name
	else
		return "Unknown"
