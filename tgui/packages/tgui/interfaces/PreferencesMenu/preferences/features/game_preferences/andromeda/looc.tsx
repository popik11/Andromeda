import { CheckboxInput, FeatureToggle } from '../../base';

export const looc_admin_pref: FeatureToggle = {
  name: 'Видеть LOOC админов',
  category: 'Админ',
  description:
    'Переключает, хотите ли вы видеть LOOC где-либо как администратор или нет.',
  component: CheckboxInput,
};
