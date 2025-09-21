/** Window sizes in pixels */
export enum WindowSize {
  Small = 30,
  Medium = 50,
  Large = 68,
  Width = 325,
}

/** Line lengths for autoexpand */
export enum LineLength {
  Small = 30,
  Medium = 60,
  Large = 90,
}

/**
 * Radio prefixes.
 * Displays the name in the left button, tags a css class.
 */
export const RADIO_PREFIXES = {
  ':a ': 'Рой',
  ':b ': 'Бин',
  ':c ': 'Ком',
  ':e ': 'Инж',
  ':g ': 'Генка',
  ':m ': 'Мед',
  ':n ': 'Иссл',
  ':o ': 'ИИ',
  ':p ': 'Развл',
  ':s ': 'Безоп',
  ':t ': 'Синд',
  ':u ': 'Снаб',
  ':v ': 'Обсл',
  ':y ': 'ЦК',
} as const;
