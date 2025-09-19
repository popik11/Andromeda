export const PHYSICALSTATUS2ICON = {
  Active: 'person-running',
  Debilitated: 'crutch',
  Unconscious: 'moon-o',
  Deceased: 'skull',
};

export const PHYSICALSTATUS2COLOR = {
  Active: 'green',
  Debilitated: 'purple',
  Unconscious: 'orange',
  Deceased: 'red',
} as const;

export const PHYSICALSTATUS2DESC = {
  Active: 'Активен. Индивид в сознании и здоров.',
  Debilitated: 'Нетрудоспособен. Индивид в сознании, но нездоров.',
  Unconscious: 'Без сознания. Индивид может нуждаться в медицинской помощи.',
  Deceased: 'Скончался. Индивид умер и начал разлагаться.',
} as const;

export const MENTALSTATUS2ICON = {
  Stable: 'face-smile-o',
  Watch: 'eye-o',
  Unstable: 'scale-unbalanced-flip',
  Insane: 'head-side-virus',
};

export const MENTALSTATUS2COLOR = {
  Stable: 'green',
  Watch: 'purple',
  Unstable: 'orange',
  Insane: 'red',
} as const;

export const MENTALSTATUS2DESC = {
  Stable: 'Стабилен. Индивид вменяем и свободен от психологических расстройств.',
  Watch:
    'Наблюдение. У индивида есть симптомы психического заболевания. Наблюдайте за ним внимательно.',
  Unstable: 'Нестабилен. Индивид имеет одно или несколько психических заболеваний.',
  Insane: 'Безумен. Индивид демонстрирует тяжелое, ненормальное психическое поведение.',
} as const;
