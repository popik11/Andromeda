/// from base of /datum/wires/proc/cut : (wire)
#define COMSIG_CUT_WIRE(wire) "cut_wire [wire]"
#define COMSIG_MEND_WIRE(wire) "mend_wire [wire]"

/// from base of /datum/wires/proc/on_pulse : (wire, mob/user)
#define COMSIG_PULSE_WIRE "pulse_wire"

// Directionality of wire pulses

/// The wires interact with their holder when pulsed
#define WIRES_INPUT (1<<0)
/// The wires have a reason to toggle whether attached assemblies are armed
#define WIRES_TOGGLE_ARMED (1<<1)
/// The wires only want to activate assemblies that do something other than (dis)arming themselves
#define WIRES_FUNCTIONAL_OUTPUT (1<<2)
/// The holder can both pulse its wires and be affected by its wires getting pulsed
#define WIRES_ALL (WIRES_INPUT | WIRES_TOGGLE_ARMED | WIRES_FUNCTIONAL_OUTPUT)

/// The assembly can pulse a wire it is attached to
#define ASSEMBLY_INPUT (1<<0)
/// The assembly toggles whether it will pulse the attached wire when it is pulsed by the attached wire
#define ASSEMBLY_TOGGLE_ARMED (1<<1)
/// The assembly does something other than just (dis)arming itself when it is pulsed by the wire it is attached to
#define ASSEMBLY_FUNCTIONAL_OUTPUT (1<<2)
/// The assembly can both pulse the wire it is attached to, and (dis)arms itself when pulsed by the wire
#define ASSEMBLY_TOGGLEABLE_INPUT (ASSEMBLY_INPUT | ASSEMBLY_TOGGLE_ARMED)
#define ASSEMBLY_ALL (ASSEMBLY_TOGGLEABLE_INPUT | ASSEMBLY_FUNCTIONAL_OUTPUT)

//retvals for attempt_wires_interaction
#define WIRE_INTERACTION_FAIL 0
#define WIRE_INTERACTION_SUCCESSFUL 1
#define WIRE_INTERACTION_BLOCK 2 //don't do anything else rather than open wires and whatever else.

#define WIRE_ACCEPT "Сканирование Успешно"
#define WIRE_ACTIVATE "Активировать"
#define WIRE_LAUNCH "Запуск"
#define WIRE_SAFETIES "Предохранители"
#define WIRE_AGELIMIT "Возрастное Ограничение"
#define WIRE_AI "Подключение ИИ"
#define WIRE_ALARM "Тревога"
#define WIRE_AVOIDANCE "Избегание"
#define WIRE_BACKUP1 "Вспомогательное Питание 1"
#define WIRE_BACKUP2 "Вспомогательное Питание 2"
#define WIRE_BEACON "Маяк"
#define WIRE_BOLTLIGHT "Индикаторы Болтов"
#define WIRE_BOLTS "Болты"
#define WIRE_BOOM "Провод Взрыва"
#define WIRE_CAMERA "Камера"
#define WIRE_CONTRABAND "Контрабанда"
#define WIRE_DELAY "Задержка"
#define WIRE_DENY "Сканирование Провалено"
#define WIRE_DISABLE "Отключить"
#define WIRE_DISARM "Обезвредить"
#define	WIRE_ON "Вкл"
#define	WIRE_DROP "Сброс"
#define	WIRE_ITEM_TYPE "Тип Предмета"
#define	WIRE_CHANGE_MODE "Смена Режима"
#define	WIRE_ONE_PRIORITY_BUTTON "Кнопка Приоритета"
#define	WIRE_THROW_RANGE "Дальность Броска"
#define WIRE_DUD_PREFIX "__пустышка"
#define WIRE_HACK "Взлом"
#define WIRE_IDSCAN "ID Сканирование"
#define WIRE_INTERFACE "Интерфейс"
#define WIRE_LAWSYNC "Синхронизация Законов ИИ"
#define WIRE_LIGHT "Свет"
#define WIRE_LIMIT "Ограничитель"
#define WIRE_LOADCHECK "Проверка Загрузки"
#define WIRE_LOCKDOWN "Блокировка"
#define WIRE_MODE_SELECT "Выбор Режима"
#define WIRE_MOTOR1 "Мотор 1"
#define WIRE_MOTOR2 "Мотор 2"
#define WIRE_OPEN "Открыть"
#define WIRE_PANIC "Паническое Откачивание"
#define WIRE_POWER "Питание"
#define WIRE_POWER1 "Основное Питание 1"
#define WIRE_POWER2 "Основное Питание 2"
#define WIRE_PRIZEVEND "Аварийная Выдача Приза"
#define WIRE_PROCEED "Продолжить"
#define WIRE_RESET_MODEL "Сброс Модели"
#define WIRE_RESETOWNER "Сброс Владельца"
#define WIRE_UNRESTRICTED_EXIT "Свободный Выход"
#define WIRE_RX "Приём"
#define WIRE_SAFETY "Безопасность"
#define WIRE_SHOCK "Высоковольтное Заземление"
#define WIRE_SIGNAL "Сигнал"
#define WIRE_SPEAKER "Динамик"
#define WIRE_STRENGTH "Сила"
#define WIRE_THROW "Бросок"
#define WIRE_TIMING "Тайминг"
#define WIRE_TX "Передача"
#define WIRE_UNBOLT "Разблокировать"
#define WIRE_ZAP "Высоковольтная Цепь"
#define WIRE_ZAP1 "Высоковольтная Цепь 1"
#define WIRE_ZAP2 "Высоковольтная Цепь 2"
#define WIRE_OVERCLOCK "Разгон"
#define WIRE_EQUIPMENT "Оборудование"
#define WIRE_ENVIRONMENT "Окружение"
#define WIRE_LOOP_MODE "Режим Цикла"
#define WIRE_REPLAY_MODE "Режим Повтора"
#define WIRE_FIRE_DETECT "Автодетекция"
#define WIRE_FIRE_TRIGGER "Триггер Тревоги"
#define WIRE_FIRE_RESET "Сброс Тревоги"

// Wire states for the AI
#define AI_WIRE_NORMAL 0
#define AI_WIRE_DISABLED 1
#define AI_WIRE_HACKED 2
#define AI_WIRE_DISABLED_HACKED -1

#define MAX_WIRE_COUNT 17
