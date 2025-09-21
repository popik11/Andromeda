/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

type Gas = {
  id: string;
  path: string;
  name: string;
  label: string;
  color: string;
};

// UI states, which are mirrored from the BYOND code.
export const UI_INTERACTIVE = 2;
export const UI_UPDATE = 1;
export const UI_DISABLED = 0;
export const UI_CLOSE = -1;

// All game related colors are stored here
export const COLORS = {
  // Department colors
  department: {
    captain: '#c06616',
    security: '#e74c3c',
    medbay: '#3498db',
    science: '#9b59b6',
    engineering: '#f1c40f',
    cargo: '#f39c12',
    service: '#7cc46a',
    centcom: '#00c100',
    other: '#c38312',
  },
  // Damage type colors
  damageType: {
    oxy: '#3498db',
    toxin: '#2ecc71',
    burn: '#e67e22',
    brute: '#e74c3c',
  },
  // reagent / chemistry related colours
  reagent: {
    acidicbuffer: '#fbc314',
    basicbuffer: '#3853a4',
  },
} as const;

// Colors defined in CSS
export const CSS_COLORS = [
  'average',
  'bad',
  'black',
  'blue',
  'brown',
  'good',
  'green',
  'grey',
  'label',
  'olive',
  'orange',
  'pink',
  'purple',
  'red',
  'teal',
  'transparent',
  'violet',
  'white',
  'yellow',
] as const;

export enum Direction {
  NONE = 0,
  NORTH = 1,
  SOUTH = 2,
  EAST = 4,
  WEST = 8,
  NORTHEAST = NORTH | EAST,
  NORTHWEST = NORTH | WEST,
  SOUTHEAST = SOUTH | EAST,
  SOUTHWEST = SOUTH | WEST,
  VERTICAL = NORTH | SOUTH,
  HORIZONTAL = EAST | WEST,
  ALL = NORTH | SOUTH | EAST | WEST,
}

export type CssColor = (typeof CSS_COLORS)[number];

/* ЕСЛИ ВЫ ИЗМЕНЯЕТЕ ЭТО, СОБЛЮДАЙТЕ СИНХРОНИЗАЦИЮ С CSS ЧАТА */
export const RADIO_CHANNELS = [
  {
    name: 'Синдикат',
    freq: 1213,
    color: '#8f4a4b',
  },
  {
    name: 'Красная команда',
    freq: 1215,
    color: '#ff4444',
  },
  {
    name: 'Синяя команда',
    freq: 1217,
    color: '#3434fd',
  },
  {
    name: 'Зелёная команда',
    freq: 1219,
    color: '#34fd34',
  },
  {
    name: 'Желтая команда',
    freq: 1221,
    color: '#fdfd34',
  },
  {
    name: 'ЦентКом',
    freq: 1337,
    color: '#2681a5',
  },
  {
    name: 'Карго',
    freq: 1347,
    color: '#b88646',
  },
  {
    name: 'Сервис',
    freq: 1349,
    color: '#6ca729',
  },
  {
    name: 'Наука',
    freq: 1351,
    color: '#c68cfa',
  },
  {
    name: 'Командование',
    freq: 1353,
    color: '#fcdf03',
  },
  {
    name: 'Медицинский',
    freq: 1355,
    color: '#57b8f0',
  },
  {
    name: 'Инженерия',
    freq: 1357,
    color: '#f37746',
  },
  {
    name: 'Безопасность',
    freq: 1359,
    color: '#dd3535',
  },
  {
    name: 'ИИ Частный',
    freq: 1447,
    color: '#d65d95',
  },
  {
    name: 'Общий',
    freq: 1459,
    color: '#1ecc43',
  },
] as const;

const GASES = [
  {
    id: 'o2',
    path: '/datum/gas/oxygen',
    name: 'Oxygen',
    label: 'Кислород',
    color: 'blue',
  },
  {
    id: 'n2',
    path: '/datum/gas/nitrogen',
    name: 'Nitrogen',
    label: 'Азот',
    color: 'yellow',
  },
  {
    id: 'co2',
    path: '/datum/gas/carbon_dioxide',
    name: 'Carbon Dioxide',
    label: 'Углекислый газ',
    color: 'grey',
  },
  {
    id: 'plasma',
    path: '/datum/gas/plasma',
    name: 'Plasma',
    label: 'Плазма',
    color: 'pink',
  },
  {
    id: 'water_vapor',
    path: '/datum/gas/water_vapor',
    name: 'Water Vapor',
    label: 'Водяной пар',
    color: 'lightsteelblue',
  },
  {
    id: 'hypernoblium',
    path: '/datum/gas/hypernoblium',
    name: 'Hyper-noblium',
    label: 'Гипер-Ноблий',
    color: 'teal',
  },
  {
    id: 'n2o',
    path: '/datum/gas/nitrous_oxide',
    name: 'Nitrous Oxide',
    label: 'Оксид азота',
    color: 'bisque',
  },
  {
    id: 'no2',
    path: '/datum/gas/nitrium',
    name: 'Nitrium',
    label: 'Нитрий',
    color: 'brown',
  },
  {
    id: 'tritium',
    path: '/datum/gas/tritium',
    name: 'Tritium',
    label: 'Тритий',
    color: 'limegreen',
  },
  {
    id: 'bz',
    path: '/datum/gas/bz',
    name: 'BZ',
    label: 'BZ',
    color: 'mediumpurple',
  },
  {
    id: 'pluoxium',
    path: '/datum/gas/pluoxium',
    name: 'Pluoxium',
    label: 'Плюоксий',
    color: 'mediumslateblue',
  },
  {
    id: 'miasma',
    path: '/datum/gas/miasma',
    name: 'Miasma',
    label: 'Миазмы',
    color: 'olive',
  },
  {
    id: 'freon',
    path: '/datum/gas/freon',
    name: 'Freon',
    label: 'Фреон',
    color: 'paleturquoise',
  },
  {
    id: 'hydrogen',
    path: '/datum/gas/hydrogen',
    name: 'Hydrogen',
    label: 'Водород',
    color: 'white',
  },
  {
    id: 'healium',
    path: '/datum/gas/healium',
    name: 'Healium',
    label: 'Хеалиум',
    color: 'salmon',
  },
  {
    id: 'proto_nitrate',
    path: '/datum/gas/proto_nitrate',
    name: 'Proto Nitrate',
    label: 'Прото-Нитрат',
    color: 'greenyellow',
  },
  {
    id: 'zauker',
    path: '/datum/gas/zauker',
    name: 'Zauker',
    label: 'Заукер',
    color: 'darkgreen',
  },
  {
    id: 'halon',
    path: '/datum/gas/halon',
    name: 'Halon',
    label: 'Галон',
    color: 'purple',
  },
  {
    id: 'helium',
    path: '/datum/gas/helium',
    name: 'Helium',
    label: 'Гелий',
    color: 'aliceblue',
  },
  {
    id: 'antinoblium',
    path: '/datum/gas/antinoblium',
    name: 'Antinoblium',
    label: 'Гипер-Ноблий',
    color: 'maroon',
  },
  {
    id: 'nitrium',
    path: '/datum/gas/nitrium',
    name: 'Nitrium',
    label: 'Нитрий',
    color: 'brown',
  },
] as const;

// Returns gas label based on gasId
export const getGasLabel = (gasId: string, fallbackValue?: string) => {
  if (!gasId) return fallbackValue || 'None';

  const gasSearchString = gasId.toLowerCase();

  for (let idx = 0; idx < GASES.length; idx++) {
    if (GASES[idx].id === gasSearchString) {
      return GASES[idx].label;
    }
  }

  return fallbackValue || 'None';
};

// Returns gas color based on gasId
export const getGasColor = (gasId: string) => {
  if (!gasId) return 'black';

  const gasSearchString = gasId.toLowerCase();

  for (let idx = 0; idx < GASES.length; idx++) {
    if (GASES[idx].id === gasSearchString) {
      return GASES[idx].color;
    }
  }

  return 'black';
};

// Returns gas object based on gasId
export const getGasFromId = (gasId: string): Gas | undefined => {
  if (!gasId) return;

  const gasSearchString = gasId.toLowerCase();

  for (let idx = 0; idx < GASES.length; idx++) {
    if (GASES[idx].id === gasSearchString) {
      return GASES[idx];
    }
  }
};

// Returns gas object based on gasPath
export const getGasFromPath = (gasPath: string): Gas | undefined => {
  if (!gasPath) return;

  for (let idx = 0; idx < GASES.length; idx++) {
    if (GASES[idx].path === gasPath) {
      return GASES[idx];
    }
  }
};
