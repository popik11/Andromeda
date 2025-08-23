/**
 * Уровни безопасности
 *
 * Используются подсистемой уровней безопасности. Каждый из них представляет уровень безопасности, который может установить игрок.
 *
 * Базовый тип является абстрактным
 */

/datum/security_level
	/// Название этого уровня безопасности.
	var/name = "не назначен"
	/// Трёхбуквенное сокращение уровня безопасности.
	var/name_shortform = "не установлен"
	/// Цвет разделителя нашего объявления.
	var/announcement_color = "default"
	/// Числовой уровень этого уровня безопасности, см. defines для дополнительной информации.
	var/number_level = -1
	/// Состояние иконки, которое будет отображаться на дисплеях во время этого уровня безопасности
	var/status_display_icon_state
	/// Цвет света пожарной тревоги, устанавливаемый при изменении на этот уровень безопасности
	var/fire_alarm_light_color
	/// Звук, который будет воспроизведён при установке этого уровня безопасности
	var/sound
	/// Зацикленный звук, который будет воспроизводиться пока установлен уровень безопасности
	var/looping_sound
	/// Интервал зацикленного звука
	var/looping_sound_interval
	/// Модификатор времени вызова шаттла для этого уровня безопасности
	var/shuttle_call_time_mod = 0
	/// Наше объявление при понижении до этого уровня
	var/lowering_to_announcement
	/// Наше объявление при повышении до этого уровня
	var/elevating_to_announcement
	/// Ключ конфигурации для текста понижения, если установлен, переопределит стандартное объявление понижения.
	var/lowering_to_configuration_key
	/// Ключ конфигурации для текста повышения, если установлен, переопределит стандартное объявление повышения.
	var/elevating_to_configuration_key
	/// если TRUE, блокирует отправку почтовых отправлений во время этого уровня безопасности
	var/disables_mail = FALSE

/datum/security_level/New()
	. = ..()
	if(lowering_to_configuration_key) // Не уверен насчёт вас, но разве нет более простого способа сделать это?
		lowering_to_announcement = global.config.Get(lowering_to_configuration_key)
	if(elevating_to_configuration_key)
		elevating_to_announcement = global.config.Get(elevating_to_configuration_key)

/**
 * ЗЕЛЁНЫЙ
 *
 * Никаких угроз
 */
/datum/security_level/green
	name = "зелёный"
	name_shortform = "GRE"
	announcement_color = "green"
	sound = 'sound/announcer/notice/notice2.ogg' // Friendly beep
	number_level = SEC_LEVEL_GREEN
	status_display_icon_state = "greenalert"
	fire_alarm_light_color = LIGHT_COLOR_BLUEGREEN
	lowering_to_configuration_key = /datum/config_entry/string/alert_green
	shuttle_call_time_mod = ALERT_COEFF_GREEN

/**
 * СИНИЙ
 *
 * Рекомендуется соблюдать осторожность
 */
/datum/security_level/blue
	name = "синий"
	name_shortform = "BLU"
	announcement_color = "blue"
	sound = 'sound/announcer/notice/notice1.ogg' // Angry alarm
	number_level = SEC_LEVEL_BLUE
	status_display_icon_state = "bluealert"
	fire_alarm_light_color = LIGHT_COLOR_ELECTRIC_CYAN
	lowering_to_configuration_key = /datum/config_entry/string/alert_blue_downto
	elevating_to_configuration_key = /datum/config_entry/string/alert_blue_upto
	shuttle_call_time_mod = ALERT_COEFF_BLUE

/**
 * КРАСНЫЙ
 *
 * Враждебные угрозы
 */
/datum/security_level/red
	name = "красный"
	name_shortform = "RED"
	announcement_color = "red"
	sound = 'sound/announcer/notice/notice3.ogg' // More angry alarm
	number_level = SEC_LEVEL_RED
	status_display_icon_state = "redalert"
	fire_alarm_light_color = LIGHT_COLOR_FLARE
	lowering_to_configuration_key = /datum/config_entry/string/alert_red_downto
	elevating_to_configuration_key = /datum/config_entry/string/alert_red_upto
	shuttle_call_time_mod = ALERT_COEFF_RED

/**
 * ДЕЛЬТА
 *
 * Уничтожение станции неизбежно
 */
/datum/security_level/delta
	name = "дельта"
	name_shortform = "DEL"
	announcement_color = "purple"
	sound = 'sound/announcer/alarm/airraid.ogg' // Air alarm to signify importance
	number_level = SEC_LEVEL_DELTA
	status_display_icon_state = "deltaalert"
	fire_alarm_light_color = LIGHT_COLOR_INTENSE_RED
	elevating_to_configuration_key = /datum/config_entry/string/alert_delta
	shuttle_call_time_mod = ALERT_COEFF_DELTA
	disables_mail = TRUE
