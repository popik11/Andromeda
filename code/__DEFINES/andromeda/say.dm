//Определения Барков
#define BLOOPER_DEFAULT_MINPITCH 0.4
#define BLOOPER_DEFAULT_MAXPITCH 2
#define BLOOPER_DEFAULT_MINVARY 0.1
#define BLOOPER_DEFAULT_MAXVARY 0.8
#define BLOOPER_DEFAULT_MINSPEED 2
#define BLOOPER_DEFAULT_MAXSPEED 16

#define BLOOPER_SPEED_BASELINE 4 //Используется для расчета задержки между Барками, любые скорости Барков ниже этого значения имеют более высокую плотность Барков, любые скорости выше - более низкую плотность. Сохраняет длительность Барков постоянной

#define BLOOPER_MAX_BLOOPERS 24
#define BLOOPER_MAX_TIME (1.5 SECONDS) //Примерное время обработки вышеуказанного со скоростью Барков 2.

#define BLOOPER_PITCH_RAND(gend) ((gend == MALE ? rand(60, 120) : (gend == FEMALE ? rand(80, 140) : rand(60,140))) / 100) //Макрос для определения случайной высоты тона на основе пола
#define BLOOPER_VARIANCE_RAND (rand(BLOOPER_DEFAULT_MINVARY * 100, BLOOPER_DEFAULT_MAXVARY * 100) / 100) //Макрос для рандомизации вариативности Барков для уменьшения количества копипаста

#define BLOOPER_DO_VARY(pitch, variance) (rand(((pitch * 100) - (variance*50)), ((pitch*100) + (variance*50))) / 100)

#define BLOOPER_SOUND_FALLOFF_EXPONENT 0.5 //На низких дистанциях мы хотим, чтобы экспонента была ниже 1, чтобы шепот не звучал слишком странно. На больших дистанциях мы хотим достаточно высокую экспоненту, чтобы крики не были слишком раздражающими
