/**
 *  # Определения Аномалий
 *  Этот файл содержит определения для подтипов аномалий случайных событий.
 */

///Время в тиках до исчезновения/взрыва аномалии в зависимости от типа.
#define ANOMALY_COUNTDOWN_TIMER (120 SECONDS)

/**
 * Назойливые/забавные аномалии
 */

///Время в секундах до появления аномалии
#define ANOMALY_START_MEDIUM_TIME (6 EVENT_SECONDS)
///Время в секундах до оповещения об аномалии
#define ANOMALY_ANNOUNCE_MEDIUM_TIME (2 EVENT_SECONDS)
///Сообщить, как далеко находится аномалия
#define ANOMALY_ANNOUNCE_MEDIUM_TEXT "дальних сканерах. Предполагаемое местоположение:"

/**
 * Хаотичные, но не опасные аномалии. Дают станции шанс обнаружить их самостоятельно.
 */

///Время в секундах до появления аномалии
#define ANOMALY_START_HARMFUL_TIME (2 EVENT_SECONDS)
///Время в секундах до оповещения об аномалии
#define ANOMALY_ANNOUNCE_HARMFUL_TIME (30 EVENT_SECONDS)
///Сообщить, как далеко находится аномалия
#define ANOMALY_ANNOUNCE_HARMFUL_TEXT "локальных сканерах. Обнаруженное местоположение:"

/**
 * Аномалии, которые могут вас подставить. Дают немного предупреждения.
 */

///Время в секундах до появления аномалии
#define ANOMALY_START_DANGEROUS_TIME (2 EVENT_SECONDS)
///Время в секундах до оповещения об аномалии
#define ANOMALY_ANNOUNCE_DANGEROUS_TIME (30 EVENT_SECONDS)
///Сообщить, как далеко находится аномалия
#define ANOMALY_ANNOUNCE_DANGEROUS_TEXT "локальных сканерах. Обнаруженное местоположение:"
