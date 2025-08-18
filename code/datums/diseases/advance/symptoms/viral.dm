/*Viral adaptation
 * Greatly increases stealth
 * Tremendous buff for resistance
 * Greatly decreases stage speed
 * No effect to transmissibility
 *
 * Bonus: Buffs resistance & stealth. Extremely useful for buffing viruses
*/
/datum/symptom/viraladaptation
	name = "Вирусная самоадаптация"
	desc = "Вирус имитирует функции нормальных клеток организма, становясь менее заметным и труднее устранимым, но снижая скорость своего развития."
	stealth = 3
	resistance = 5
	stage_speed = -3
	transmittable = 0
	level = 3

/*Viral evolution
 * Reduces stealth
 * Greatly reduces resistance
 * Tremendous buff for stage speed
 * Greatly increases transmissibility
 *
 * Bonus: Buffs transmission and speed. Extremely useful for buffing viruse*
*/
/datum/symptom/viralevolution
	name = "Ускоренная вирусная эволюция"
	desc = "Вирус быстро адаптируется для максимально быстрого распространения как внутри, так и вне носителя. \
	Однако это делает вирус более заметным и менее устойчивым к лечению."
	stealth = -2
	resistance = -3
	stage_speed = 5
	transmittable = 3
	level = 3
