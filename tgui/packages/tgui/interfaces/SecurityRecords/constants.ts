export const CRIMESTATUS2COLOR = {
  Arrest: 'bad',
  Discharged: 'blue',
  Incarcerated: 'average',
  Parole: 'good',
  Suspected: 'teal',
} as const;

export const CRIMESTATUS2DESC = {
  Arrest: 'Арест. Цель должна иметь действительные преступления для установки этого статуса.',
  Discharged: 'Освобожден. Индивид был оправдан от правонарушений.',
  Incarcerated: 'Заключен. Индивид в настоящее время отбывает наказание.',
  Parole: 'Условно-досрочное освобождение (УДО). Освобожден из тюрьмы, но все еще под наблюдением.',
  Suspected: 'Подозреваемый. Внимательно следите за преступной деятельностью.',
} as const;
