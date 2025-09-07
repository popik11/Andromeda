/**
 * # Компонент
 *
 * Датум (datums) компонента
 *
 * Компонент должен быть единым самостоятельным модулем
 * функциональности, который работает, получая сигналы от своего родительского
 * объекта для обеспечения определенной функциональности (например, скользкий компонент),
 * который заставляет объект, к которому он прикреплен, заставлять людей поскальзываться.
 * Полезно, когда вы хотите иметь общее поведение, независимое от наследования типов
 */
/datum/component
	/**
	  * Определяет, как обрабатываются дублирующиеся существующие компоненты при добавлении к Датум
	  *
	  * Смотрите определения [COMPONENT_DUPE_*][COMPONENT_DUPE_ALLOWED] для доступных вариантов
	  */
	var/dupe_mode = COMPONENT_DUPE_HIGHLANDER

	/// Датум, к которому принадлежит этот компонент
	var/datum/parent

	/**
	  * Устанавливайте в true только если вы можете правильно передать этот компонент
	  *
	  * Как минимум, должны использоваться [RegisterWithParent][/datum/component/proc/RegisterWithParent] и [UnregisterFromParent][/datum/component/proc/UnregisterFromParent]
	  *
	  * Убедитесь, что вы также реализуете [PostTransfer][/datum/component/proc/PostTransfer] для любой пост-передаточной обработки
	  */
	var/can_transfer = FALSE

	/// Ленивый список источников для этого компонента
	var/list/sources

/**
 * Создать новый компонент.
 *
 * Дополнительные аргументы передаются в [Initialize()][/datum/component/proc/Initialize]
 *
 * Аргументы:
 * * datum/P родительский датум, на сигналы которого реагирует этот компонент
 */
/datum/component/New(list/raw_args)
	parent = raw_args[1]
	var/list/arguments = raw_args.Copy(2)

	var/result = Initialize(arglist(arguments))

	if(result == COMPONENT_INCOMPATIBLE)
		stack_trace("Несовместимый [type] назначен на [parent.type]! args: [json_encode(arguments)]")
		qdel(src, TRUE, TRUE)
		return

	if(result == COMPONENT_REDUNDANT)
		qdel(src, TRUE, TRUE)
		return

	if(QDELETED(src) || QDELETED(parent))
		CRASH("Компонент [type] был создан с удаленным родителем или был удален до того, как мог быть добавлен к родителю")

	_JoinParent()

/**
 * Вызывается во время создания компонента с теми же аргументами, что и в new, исключая parent.
 *
 * Не вызывайте `qdel(src)` из этой функции, вместо этого используйте `return COMPONENT_INCOMPATIBLE`
 */
/datum/component/proc/Initialize(...)
	return

/**
 * Правильно удаляет компонент из `parent` и очищает ссылки
 *
 * Аргументы:
 * * force - не проверяет и не удаляет компонент из родителя
 */
/datum/component/Destroy(force = FALSE)
	if(!parent)
		return ..()
	if(!force)
		_RemoveFromParent()
	SEND_SIGNAL(parent, COMSIG_COMPONENT_REMOVING, src)
	parent = null
	return ..()

/**
 * Внутренняя процедура для обработки поведения компонентов при присоединении к родителю
 */
/datum/component/proc/_JoinParent()
	var/datum/P = parent
	//ленивая инициализация списка dc родителя
	var/list/dc = P._datum_components
	if(!dc)
		P._datum_components = dc = list()

	//настройка кэша типов
	var/our_type = type
	for(var/I in _GetInverseTypeList(our_type))
		var/test = dc[I]
		if(test) //уже есть другой компонент этого типа
			var/list/components_of_type
			if(!length(test))
				components_of_type = list(test)
				dc[I] = components_of_type
			else
				components_of_type = test
			if(I == our_type) //точное совпадение, имеет приоритет
				var/inserted = FALSE
				for(var/J in 1 to components_of_type.len)
					var/datum/component/C = components_of_type[J]
					if(C.type != our_type) //но не поверх других точных совпадений
						components_of_type.Insert(J, I)
						inserted = TRUE
						break
				if(!inserted)
					components_of_type += src
			else //косвенное совпадение, в конец очереди
				components_of_type += src
		else //единственный компонент этого типа, без списка
			dc[I] = src

	RegisterWithParent()

/**
 * Внутренняя процедура для обработки поведения при удалении из родителя
 */
/datum/component/proc/_RemoveFromParent()
	var/datum/parent = src.parent
	var/list/parents_components = parent._datum_components
	for(var/I in _GetInverseTypeList())
		var/list/components_of_type = parents_components[I]

		if(length(components_of_type)) //
			var/list/subtracted = components_of_type - src

			if(subtracted.len == 1) //остался только один
				parents_components[I] = subtracted[1] //делаем его особенным
			else
				parents_components[I] = subtracted

		else //только мы
			parents_components -= I

	if(!parents_components.len)
		parent._datum_components = null

	UnregisterFromParent()

/**
 * Зарегистрировать компонент в родительском объекте
 *
 * Используйте эту процедуру для регистрации в вашем родительском объекте
 *
 * Переопределяемая процедура, вызываемая при добавлении к новому родителю
 */
/datum/component/proc/RegisterWithParent()
	return

/**
 * Отрегистрироваться от нашего родительского объекта
 *
 * Используйте эту процедуру для отрегистрации от вашего родительского объекта
 *
 * Переопределяемая процедура, вызываемая при удалении из родителя
 * *
 */
/datum/component/proc/UnregisterFromParent()
	return

/**
 * Вызывается, когда у компонента регистрируется новый источник.
 * Верните COMPONENT_INCOMPATIBLE, чтобы сигнализировать, что источник несовместим и не должен быть добавлен
 */
/datum/component/proc/on_source_add(source, ...)
	SHOULD_CALL_PARENT(TRUE)
	if(dupe_mode != COMPONENT_DUPE_SOURCES)
		return COMPONENT_INCOMPATIBLE
	LAZYOR(sources, source)

/**
 * Вызывается, когда у компонента удаляется источник.
 * Вероятно, вы захотите вызвать parent после своей логики, потому что в конце этой процедуры мы удаляем компонент, если у него не осталось источников!
 */
/datum/component/proc/on_source_remove(source)
	SHOULD_CALL_PARENT(TRUE)
	if(dupe_mode != COMPONENT_DUPE_SOURCES)
		CRASH("Компонент '[type]' не использует источники, но пытается удалить источник")
	LAZYREMOVE(sources, source)
	if(!LAZYLEN(sources))
		qdel(src)

/**
 * Вызывается у компонента, когда компонент того же типа был добавлен к тому же родителю
 *
 * Смотрите [/datum/component/var/dupe_mode]
 *
 * Тип `C` всегда будет таким же, как у вызываемого компонента
 */
/datum/component/proc/InheritComponent(datum/component/C, i_am_original)
	return


/**
 * Вызывается у компонента, когда компонент того же типа был добавлен к тому же родителю с [COMPONENT_DUPE_SELECTIVE]
 *
 * Смотрите [/datum/component/var/dupe_mode]
 *
 * Тип `C` всегда будет таким же, как у вызываемого компонента
 *
 * Верните TRUE, если вы поглощаете компонент, иначе FALSE, если вы не против его существования в качестве дубликата
 */
/datum/component/proc/CheckDupeComponent(datum/component/C, ...)
	return


/**
 * Колбек непосредственно перед передачей этого компонента
 *
 * Используйте это для любой специальной очистки, которая может потребоваться перед отменой регистрации из объекта
 */
/datum/component/proc/PreTransfer(datum/new_parent)
	return

/**
 * Колбек сразу после передачи компонента
 *
 * Используйте это для любой специальной настройки, которую нужно выполнить после перемещения на новый объект
 *
 * Не вызывайте `qdel(src)` из этой функции, вместо этого используйте `return COMPONENT_INCOMPATIBLE`
 */
/datum/component/proc/PostTransfer(datum/new_parent)
	return COMPONENT_INCOMPATIBLE //По умолчанию не поддерживаем передачу, так как вы должны правильно её поддерживать

/**
 * Внутренняя процедура для создания списка нашего типа и всех родительских типов
 */
/datum/component/proc/_GetInverseTypeList(our_type = type)
	//мы можем сделать этот простой трюк
	. = list(our_type)
	var/current_type = parent_type
	//и поскольку большинство компонентов находятся на корневом уровне + 1, это даже не придется запускать
	while (current_type != /datum/component)
		. += current_type
		current_type = type2parent(current_type)

// Аргумент type приводится, чтобы initial работал, вы не должны передавать реальный экземпляр в эту функцию
/**
 * Возвращает любой компонент, назначенный этому дейтауму указанного типа
 *
 * Вызовет ошибку, если возможно наличие более одного компонента этого типа на родителе
 *
 * Аргументы:
 * * datum/component/c_type Тип компонента, на который вы хотите получить ссылку
 */
/datum/proc/GetComponent(datum/component/c_type)
	RETURN_TYPE(c_type)
	if(initial(c_type.dupe_mode) == COMPONENT_DUPE_ALLOWED || initial(c_type.dupe_mode) == COMPONENT_DUPE_SELECTIVE)
		stack_trace("GetComponent был вызван для получения компонента, несколько копий которого могут находиться на объекте. Это может легко сломаться и должно быть изменено. Тип: \[[c_type]\]")
	var/list/dc = _datum_components
	if(!dc)
		return null
	. = dc[c_type]
	if(length(.))
		return .[1]

// Аргумент type приводится, чтобы initial работал, вы не должны передавать реальный экземпляр в эту функцию
/**
 * Возвращает любой компонент, назначенный этому дейтауму точно указанного типа
 *
 * Вызовет ошибку, если возможно наличие более одного компонента этого типа на родителе
 *
 * Аргументы:
 * * datum/component/c_type Тип компонента, на который вы хотите получить ссылку
 */
/datum/proc/GetExactComponent(datum/component/c_type)
	RETURN_TYPE(c_type)
	var/initial_type_mode = initial(c_type.dupe_mode)
	if(initial_type_mode == COMPONENT_DUPE_ALLOWED || initial_type_mode == COMPONENT_DUPE_SELECTIVE)
		stack_trace("GetComponent был вызван для получения компонента, несколько копий которого могут находиться на объекте. Это может легко сломаться и должно быть изменено. Тип: \[[c_type]\]")
	var/list/all_components = _datum_components
	if(!all_components)
		return null
	var/datum/component/potential_component
	if(length(all_components))
		potential_component = all_components[c_type]
	if(potential_component?.type == c_type)
		return potential_component
	return null

/**
 * Получить все компоненты указанного типа, прикрепленные к этому дейтауму
 *
 * Аргументы:
 * * c_type Тип компонента
 */
/datum/proc/GetComponents(c_type)
	var/list/components = _datum_components?[c_type]
	if(!components)
		return list()
	return islist(components) ? components : list(components)

/**
 * Создает экземпляр `new_type` в дейтауме и прикрепляет его как родителя
 *
 * Отправляет сигнал [COMSIG_COMPONENT_ADDED] в дейтаум
 *
 * Возвращает созданный компонент. Или старый компонент в ситуации дублирования, где был установлен [COMPONENT_DUPE_UNIQUE]
 *
 * Если эта попытка добавить компонент к несовместимому типу, компонент будет удален и результатом будет `null`. Это очень не производительно, старайтесь не делать этого
 *
 * Правильно обрабатывает ситуации дублирования на основе переменной `dupe_mode`
 */
/datum/proc/_AddComponent(list/raw_args, source)
	var/original_type = raw_args[1]
	var/datum/component/component_type = original_type

	if(QDELING(src))
		CRASH("Попытка добавить новый компонент типа \[[component_type]\] к удаляемому родителю типа \[[type]\]!")

	var/datum/component/new_component

	if(!ispath(component_type, /datum/component))
		if(!istype(component_type, /datum/component))
			CRASH("Попытка создать экземпляр \[[component_type]\] как компонент, добавленный к родителю типа \[[type]\]!")
		else
			new_component = component_type
			component_type = new_component.type
	else if(component_type == /datum/component)
		CRASH("[component_type] попытка создания экземпляра!")

	var/dupe_mode = initial(component_type.dupe_mode)
	var/uses_sources = (dupe_mode == COMPONENT_DUPE_SOURCES)
	if(uses_sources && !source)
		CRASH("Попытка добавить компонент с источником типа '[component_type]' к '[type]' без источника!")
	else if(!uses_sources && source)
		CRASH("Попытка добавить обычный компонент типа '[component_type]' к '[type]' с источником!")

	var/datum/component/old_component

	raw_args[1] = src
	if(dupe_mode != COMPONENT_DUPE_ALLOWED && dupe_mode != COMPONENT_DUPE_SELECTIVE)
		old_component = GetComponent(component_type)

		if(old_component)
			switch(dupe_mode)
				if(COMPONENT_DUPE_UNIQUE)
					if(!new_component)
						new_component = new component_type(raw_args)
					if(!QDELETED(new_component))
						old_component.InheritComponent(new_component, TRUE)
						QDEL_NULL(new_component)

				if(COMPONENT_DUPE_HIGHLANDER)
					if(!new_component)
						new_component = new component_type(raw_args)
					if(!QDELETED(new_component))
						new_component.InheritComponent(old_component, FALSE)
						QDEL_NULL(old_component)

				if(COMPONENT_DUPE_UNIQUE_PASSARGS)
					if(!new_component)
						var/list/arguments = raw_args.Copy(2)
						arguments.Insert(1, null, TRUE)
						old_component.InheritComponent(arglist(arguments))
					else
						old_component.InheritComponent(new_component, TRUE)
						QDEL_NULL(new_component)

				if(COMPONENT_DUPE_SOURCES)
					if((source in old_component.sources) && !old_component.allow_source_update(source))
						return old_component // источник уже зарегистрирован, нечего делать

					if(old_component.on_source_add(arglist(list(source) + raw_args.Copy(2))) == COMPONENT_INCOMPATIBLE)
						stack_trace("несовместимый источник добавлен к [old_component.type]. Аргументы: [json_encode(raw_args)]")
						return null

		else if(!new_component)
			new_component = new component_type(raw_args) // Есть допустимый режим дублирования, но нет старого компонента, действуйте как обычно

	else if(dupe_mode == COMPONENT_DUPE_SELECTIVE)
		var/list/arguments = raw_args.Copy()
		arguments[1] = new_component
		var/make_new_component = TRUE
		for(var/datum/component/existing_component as anything in GetComponents(original_type))
			if(existing_component.CheckDupeComponent(arglist(arguments)))
				make_new_component = FALSE
				QDEL_NULL(new_component)
				break
		if(!new_component && make_new_component)
			new_component = new component_type(raw_args)

	else if(!new_component)
		new_component = new component_type(raw_args) // Дубликаты разрешены, действуйте как обычно

	if(!old_component && !QDELETED(new_component)) // Ничего связанного с дублирующими компонентами не произошло и новый компонент исправен
		if(source && new_component.on_source_add(arglist(list(source) + raw_args.Copy(2))) == COMPONENT_INCOMPATIBLE)
			stack_trace("несовместимый источник добавлен к [new_component.type]. Аргументы: [json_encode(raw_args)]")
			return null
		SEND_SIGNAL(src, COMSIG_COMPONENT_ADDED, new_component)
		return new_component

	return old_component

/**
 * Удаляет источник компонента из этого дейтаума
 */
/datum/proc/RemoveComponentSource(source, datum/component/component_type)
	if(ispath(component_type))
		component_type = GetExactComponent(component_type)
	if(!component_type)
		return
	component_type.on_source_remove(source)

/**
 * Получить существующий компонент типа или создать его и вернуть ссылку на него
 *
 * Используйте это, если элемент должен существовать во время этого вызова, но, возможно, не был создан до этого момента
 *
 * Аргументы:
 * * component_type Тип компонента для создания или возврата
 * * ... дополнительные аргументы, передаваемые при создании компонента, если он не существует
 */
/datum/proc/_LoadComponent(list/arguments)
	. = GetComponent(arguments[1])
	if(!.)
		return _AddComponent(arguments)

/**
 * Удаляет компонент из родителя, в результате родитель становится null
 * Используется как вспомогательная процедура для процедуры передачи компонента, не очищает компонент как Destroy
 */
/datum/component/proc/ClearFromParent(datum/new_parent)
	if(!parent)
		return
	var/datum/old_parent = parent
	PreTransfer(new_parent)
	_RemoveFromParent()
	parent = null
	SEND_SIGNAL(old_parent, COMSIG_COMPONENT_REMOVING, src)

/**
 * Передает этот компонент другому родителю
 *
 * Компонент берется из исходного дейтаума
 *
 * Аргументы:
 * * datum/component/target Целевой дейтаум для передачи
 */
/datum/proc/TakeComponent(datum/component/target)
	if(!target || target.parent == src)
		return
	if(target.parent)
		target.ClearFromParent(src)
	var/result = target.PostTransfer(src)
	switch(result)
		if(COMPONENT_INCOMPATIBLE)
			var/c_type = target.type
			qdel(target)
			CRASH("Попытка передачи несовместимого [c_type] к [type]!")

	AddComponent(target)
	if(!QDELETED(target))
		target.parent = src
		target._JoinParent()

/**
 * Передает все компоненты цели
 *
 * Все компоненты из исходного дейтаума берутся
 *
 * Аргументы:
 * * /datum/target цель для перемещения компонентов
 */
/datum/proc/TransferComponents(datum/target)
	var/list/dc = _datum_components
	if(!dc)
		return
	for(var/component_key in dc)
		var/component_or_list = dc[component_key]
		if(islist(component_or_list))
			for(var/datum/component/component in component_or_list)
				if(component.can_transfer)
					target.TakeComponent(component)
		else
			var/datum/component/component = component_or_list
			if(!QDELETED(component) && component.can_transfer)
				target.TakeComponent(component)

/**
 * Возвращает объект, который является хостом любых UI этого компонента
 */
/datum/component/ui_host()
	return parent

///Разрешено ли компоненту вызывать on_source_add() на источнике, который уже присутствует
/datum/component/proc/allow_source_update(source)
	return FALSE
