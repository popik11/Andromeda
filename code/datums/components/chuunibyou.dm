/// количество здоровья, восстанавливаемого при касте "чуни" заклинания
#define CHUUNIBYOU_HEAL_AMOUNT 3
/// кулдаун между исцелениями, чтобы предотвратить спам-исцеление (например, мгновенное исцеление от blink заклинания)
#define CHUUNIBYOU_COOLDOWN_TIME 5 SECONDS

/**
 * ## Компонент чунибаё!
 *
 * Компонент, заставляющий заклинания всегда произноситься с громким крипым возгласом. И их снаряды тоже криповые.
 * Зато после каждого каста заклинания чуни исцеляется.
 */
/datum/component/chuunibyou
	/// возгласы для каждой школы магии
	var/static/list/chuunibyou_invocations
	/// количество восстанавливаемого здоровья за каст
	var/heal_amount = CHUUNIBYOU_HEAL_AMOUNT
	/// кулдаун на исцеление
	COOLDOWN_DECLARE(heal_cooldown)
	/// кастуем ли мы заклинание в данный момент
	var/casting_spell = FALSE

/datum/component/chuunibyou/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	if(!chuunibyou_invocations)
		chuunibyou_invocations = list(
			SCHOOL_UNSET = "Как неловко... Я забыл слова... эм... может, просто помахать рукой вот так... нет, не работает... А! Получилось!",
			SCHOOL_HOLY = "Благословением святого, призываю свет спасения. Да возрадуются союзники. О, Небеса! Благословите их!",
			SCHOOL_PSYCHIC = "Тайной сокровенного, раскрываю истину творения. Да расширится мой разум. О, Тайна! Просвети меня!",
			SCHOOL_MIME = "О, Безмолвие! Обними мою душу и усиль мой жест. Позволь мне создать иллюзию и управлять восприятием!",
			SCHOOL_RESTORATION = "Взываю к имени богини милосердия, услышь мольбу и ниспошли благословение этой душе! Божественная Благодать!",

			SCHOOL_EVOCATION = "Узрите предельную мощь Тёмного Пламени! Призываю древние силы хаоса и разрушения обрушить гнев на врагов!",
			SCHOOL_TRANSMUTATION = "Взываю к закону равнозначного обмена, балансу космоса. Жертвую сие, требую новое творение. Явь, тайну преображения!",
			SCHOOL_TRANSLOCATION = "Мощью пространственных разломов искривляю ткань реальности! Ничто не преградит путь меж измерениями!",
			SCHOOL_CONJURATION = "Оком судьбы вижу нити предназначения. Ничто не укроется. Лицезрите чудо материализации!",

			SCHOOL_NECROMANCY = "Я Владыка Мёртвых, Повелитель Костей, Хранитель Теней. Легионы проклятых, восстаньте из могил и служите мне!",
			SCHOOL_FORBIDDEN = "Отрекаюсь от законов мира, принимаю хаос древних богов! Да течёт запретная сила, уничтожая всё на пути!",
			SCHOOL_SANGUINE = "Повязкой сокрыто око, сдерживающее истинную мощь. Но ныне я отпускаю узды! Питаюсь жизненной силой жертв, крепну с каждой каплей!",
		)

/datum/component/chuunibyou/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_MOB_SPELL_PROJECTILE, PROC_REF(on_spell_projectile))
	RegisterSignal(parent, COMSIG_MOB_PRE_INVOCATION, PROC_REF(on_pre_invocation))
	RegisterSignal(parent, COMSIG_MOB_TRY_SPEECH, PROC_REF(on_try_speech))
	RegisterSignal(parent, COMSIG_MOB_AFTER_SPELL_CAST, PROC_REF(on_after_spell_cast))
	ADD_TRAIT(parent, TRAIT_CHUUNIBYOU, REF(src))

/datum/component/chuunibyou/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_MOB_SPELL_PROJECTILE,
		COMSIG_MOB_PRE_INVOCATION,
		COMSIG_MOB_TRY_SPEECH,
		COMSIG_MOB_AFTER_SPELL_CAST,
	))
	REMOVE_TRAIT(parent, TRAIT_CHUUNIBYOU, REF(src))

/// signal sent when the parent tries to speak. we let speech pass if we are casting a spell so mimes still chuuni their spellcasts
/// (this may end in the mime dying)
/datum/component/chuunibyou/proc/on_try_speech(datum/source, message, ignore_spam, forced)
	SIGNAL_HANDLER

	if(casting_spell && !HAS_TRAIT(src, TRAIT_MUTE))
		return COMPONENT_IGNORE_CAN_SPEAK

///signal sent when the parent casts a spell that has a projectile
/datum/component/chuunibyou/proc/on_spell_projectile(mob/living/source, datum/action/cooldown/spell/spell, atom/cast_on, obj/projectile/to_fire)
	SIGNAL_HANDLER

	playsound(to_fire,'sound/effects/magic/staff_change.ogg', 75, TRUE)
	to_fire.color = "#f825f8"
	to_fire.name = "чуни-[to_fire.name]"
	to_fire.set_light(2, 2, LIGHT_COLOR_PINK, l_on = TRUE)

///signal sent before parent invokes a spell
/datum/component/chuunibyou/proc/on_pre_invocation(mob/living/source, datum/action/cooldown/spell/spell, list/invocation_list)
	SIGNAL_HANDLER

	// this makes it bypass speech checks (being a mime) until the spell is done casting
	// this lets mimes cast with it, but, um... might get them lynched
	casting_spell = TRUE
	invocation_list[INVOCATION_TYPE] = INVOCATION_SHOUT
	invocation_list[INVOCATION_GARBLE_PROB] = 0
	var/chuuni_invocation = chuunibyou_invocations[spell.school]
	if(!chuuni_invocation) // someone forgot to update the CHUUNI LIST to include a desc for the new school
		stack_trace("Chunnibyou invocations is missing a line for spell school \"[spell.school]\"")
		chuuni_invocation = chuunibyou_invocations[SCHOOL_UNSET]
	invocation_list[INVOCATION_MESSAGE] = chuuni_invocation

///signal sent after parent casts a spell
/datum/component/chuunibyou/proc/on_after_spell_cast(mob/living/source, datum/action/cooldown/spell/spell, atom/cast_on)
	SIGNAL_HANDLER

	casting_spell = FALSE
	if(!COOLDOWN_FINISHED(src, heal_cooldown))
		return
	COOLDOWN_START(src, heal_cooldown, CHUUNIBYOU_COOLDOWN_TIME)

	source.heal_overall_damage(heal_amount)
	playsound(source, 'sound/effects/magic/staff_healing.ogg', 30)
	to_chat(source, span_danger("Ты чувствуешь, как силы чуни слегка исцеляют тебя."))

/datum/component/chuunibyou/no_healing
	heal_amount = 0

#undef CHUUNIBYOU_HEAL_AMOUNT
#undef CHUUNIBYOU_COOLDOWN_TIME
