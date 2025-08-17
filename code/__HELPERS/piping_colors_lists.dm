///All colors available to pipes and atmos components
GLOBAL_LIST_INIT(pipe_paint_colors, list(
	"бесцветный" = ATMOS_COLOR_OMNI,
	"зелёный" = COLOR_VIBRANT_LIME,
	"синий" = COLOR_BLUE,
	"красный" = COLOR_RED,
	"оранжевый" = COLOR_ENGINEERING_ORANGE,
	"голубой" = COLOR_CYAN,
	"тёмный" = COLOR_DARK,
	"жёлтый" = COLOR_YELLOW,
	"коричневый" = COLOR_BROWN,
	"розовый" = COLOR_LIGHT_PINK,
	"фиолетовый" = COLOR_PURPLE,
	"лиловый" = COLOR_STRONG_VIOLET,
))

///List that sorts the colors and is used for setting up the pipes layer so that they overlap correctly
GLOBAL_LIST_INIT(pipe_colors_ordered, sort_list(list(
	COLOR_AMETHYST = -6,
	COLOR_BLUE = -5,
	COLOR_BROWN = -4,
	COLOR_CYAN = -3,
	COLOR_DARK = -2,
	COLOR_VIBRANT_LIME = -1,
	ATMOS_COLOR_OMNI = 0,
	COLOR_ENGINEERING_ORANGE = 1,
	COLOR_PURPLE = 2,
	COLOR_RED = 3,
	COLOR_STRONG_VIOLET = 4,
	COLOR_YELLOW = 5
)))

///Names shown in the examine for every colored atmos component
GLOBAL_LIST_INIT(pipe_color_name, sort_list(list(
	ATMOS_COLOR_OMNI = "бесцветный",
	COLOR_BLUE = "синий",
	COLOR_RED = "красный",
	COLOR_VIBRANT_LIME = "зелёный",
	COLOR_ENGINEERING_ORANGE = "оранжевый",
	COLOR_CYAN = "голубой",
	COLOR_DARK = "тёмный",
	COLOR_YELLOW = "жёлтый",
	COLOR_BROWN = "коричневый",
	COLOR_LIGHT_PINK = "розовый",
	COLOR_PURPLE = "фиолетовый",
	COLOR_STRONG_VIOLET = "лиловый"
)))
