
/datum/mutation/breathless
	name = "Бездыханность"
	desc = "Мутация кожи, позволяющая фильтровать и поглощать кислород через кожу."
	text_gain_indication = span_notice("Ваши лёгкие чувствуют себя прекрасно.")
	text_lose_indication = span_warning("Ваши лёгкие снова чувствуют себя нормально.")
	locked = TRUE

/datum/mutation/breathless/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	ADD_TRAIT(acquirer, TRAIT_NOBREATH, GENETIC_MUTATION)

/datum/mutation/breathless/on_losing(mob/living/carbon/human/owner)//this shouldnt happen under normal condition but just to be sure
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_NOBREATH, GENETIC_MUTATION)

/datum/mutation/quick
	name = "Проворство"
	desc = "Мутация мышц ног, позволяющая им работать на 20% больше обычной мощности."
	text_gain_indication = span_notice("Ваши ноги чувствуют себя быстрее и сильнее.")
	text_lose_indication = span_warning("Ваши ноги чувствуют себя слабее и медленнее.")
	locked = TRUE

/datum/mutation/quick/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	acquirer.add_movespeed_modifier(/datum/movespeed_modifier/dna_vault_speedup)

/datum/mutation/quick/on_losing(mob/living/carbon/human/owner)
	. = ..()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/dna_vault_speedup)

/datum/mutation/tough
	name = "Крепость"
	desc = "Мутация эпидермиса, делающая его более устойчивым к разрывам."
	text_gain_indication = span_notice("Ваша кожа кажется более прочной.")
	text_lose_indication = span_warning("Ваша кожа кажется более слабой.")
	locked = TRUE

/datum/mutation/tough/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	acquirer.physiology.brute_mod *= 0.7
	ADD_TRAIT(acquirer, TRAIT_PIERCEIMMUNE, GENETIC_MUTATION)

/datum/mutation/tough/on_losing(mob/living/carbon/human/owner)
	. = ..()
	owner.physiology.brute_mod /= 0.7
	REMOVE_TRAIT(owner, TRAIT_PIERCEIMMUNE, GENETIC_MUTATION)

/datum/mutation/dextrous
	name = "Ловкость"
	desc = "Мутация нервной системы, позволяющая совершать более быстрые и отзывчивые действия."
	text_gain_indication = span_notice("Ваши конечности чувствуют себя более ловкими и отзывчивыми.")
	text_lose_indication = span_warning("Ваши конечности чувствуют себя менее ловкими и отзывчивыми.")
	locked = TRUE

/datum/mutation/dextrous/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	acquirer.next_move_modifier *= 0.5

/datum/mutation/dextrous/on_losing(mob/living/carbon/human/owner)
	. = ..()
	owner.next_move_modifier /= 0.5

/datum/mutation/fire_immunity
	name = "Иммунитет к Огню"
	desc = "Мутация тела, позволяющая стать негорючим и выдерживать более высокие температуры."
	text_gain_indication = span_notice("Ваше тело чувствует, что может выдержать огонь.")
	text_lose_indication = span_warning("Ваше тело снова чувствует уязвимость к огню.")
	locked = TRUE

/datum/mutation/fire_immunity/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	acquirer.physiology.burn_mod *= 0.5
	acquirer.add_traits(list(TRAIT_RESISTHEAT, TRAIT_NOFIRE), GENETIC_MUTATION)

/datum/mutation/fire_immunity/on_losing(mob/living/carbon/human/owner)
	. = ..()
	owner.physiology.burn_mod /= 0.5
	owner.remove_traits(list(TRAIT_RESISTHEAT, TRAIT_NOFIRE), GENETIC_MUTATION)

/datum/mutation/quick_recovery
	name = "Быстрое Восстановление"
	desc = "Мутация нервной системы, позволяющая быстрее восстанавливаться после падений."
	text_gain_indication = span_notice("Вы чувствуете, что сможете легче оправиться от падения.")
	text_lose_indication = span_warning("Вы чувствуете, что восстановление после падения снова стало сложной задачей.")
	locked = TRUE

/datum/mutation/quick_recovery/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	acquirer.physiology.stun_mod *= 0.5

/datum/mutation/quick_recovery/on_losing(mob/living/carbon/human/owner)
	. = ..()
	owner.physiology.stun_mod /= 0.5

/datum/mutation/plasmocile
	name = "Плазмосайл"
	desc = "Мутация лёгких, обеспечивающая иммунитет к токсичной природе плазмы."
	text_gain_indication = span_notice("Ваши лёгкие чувствуют себя устойчивыми к воздушным загрязнителям.")
	text_lose_indication = span_warning("Ваши лёгкие снова чувствуют уязвимость к воздушным загрязнителям.")
	locked = TRUE

/datum/mutation/plasmocile/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	var/obj/item/organ/lungs/improved_lungs = acquirer.get_organ_slot(ORGAN_SLOT_LUNGS)
	ADD_TRAIT(owner, TRAIT_VIRUSIMMUNE, GENETIC_MUTATION)
	if(improved_lungs)
		apply_buff(improved_lungs)
	RegisterSignal(acquirer, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(remove_modification))
	RegisterSignal(acquirer, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(reapply_modification))

/datum/mutation/plasmocile/on_losing(mob/living/carbon/human/owner)
	. = ..()
	var/obj/item/organ/lungs/improved_lungs = owner.get_organ_slot(ORGAN_SLOT_LUNGS)
	REMOVE_TRAIT(owner, TRAIT_VIRUSIMMUNE, GENETIC_MUTATION)
	UnregisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN)
	UnregisterSignal(owner, COMSIG_CARBON_GAIN_ORGAN)
	if(improved_lungs)
		remove_buff(improved_lungs)

/datum/mutation/plasmocile/proc/remove_modification(mob/source, obj/item/organ/old_organ)
	SIGNAL_HANDLER

	if(istype(old_organ, /obj/item/organ/lungs))
		remove_buff(old_organ)

/datum/mutation/plasmocile/proc/reapply_modification(mob/source, obj/item/organ/new_organ)
	SIGNAL_HANDLER

	if(istype(new_organ, /obj/item/organ/lungs))
		apply_buff(new_organ)

/datum/mutation/plasmocile/proc/apply_buff(obj/item/organ/lungs/our_lungs)
	our_lungs.plas_breath_dam_min *= 0
	our_lungs.plas_breath_dam_max *= 0

/datum/mutation/plasmocile/proc/remove_buff(obj/item/organ/lungs/our_lungs)
	our_lungs.plas_breath_dam_min = initial(our_lungs.plas_breath_dam_min)
	our_lungs.plas_breath_dam_max = initial(our_lungs.plas_breath_dam_max)

