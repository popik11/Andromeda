import { Button, Stack } from 'tgui-core/components';

import { useBackend } from '../../../../../../backend';
import {
  CheckboxInput,
  type Feature,
  type FeatureChoiced,
  FeatureNumberInput,
  type FeatureNumeric,
  FeatureSliderInput,
  type FeatureToggle,
} from '../../base';
import { FeatureDropdownInput } from '../../dropdowns';

const FeatureBlooperDropdownInput = (props) => {
  const { act } = useBackend();
  return (
    <Stack>
      <Stack.Item grow>
        <FeatureDropdownInput {...props} />
      </Stack.Item>
      <Stack.Item>
        <Button
          onClick={() => {
            act('play_blooper');
          }}
          icon="play"
          width="100%"
          height="100%"
        />
      </Stack.Item>
    </Stack>
  );
};

export const blooper_pitch_range: FeatureNumeric = {
  name: 'Диапазон голоса персонажа',
  description:
    '[0.1 - 0.8] Меньшее число - меньший диапазон. Большее число - больший диапазон.',
  component: FeatureNumberInput,
};

export const blooper_speech: FeatureChoiced = {
  name: 'Голос персонажа',
  component: FeatureBlooperDropdownInput,
};

export const blooper_speech_speed: FeatureNumeric = {
  name: 'Скорость голоса персонажа',
  description:
    '[2 - 16] Меньшее число - большая скорость. Большее число - медленнее голос.',
  component: FeatureNumberInput,
};

export const blooper_speech_pitch: FeatureNumeric = {
  name: 'Высота голоса персонажа',
  description:
    '[0.4 - 2] Меньшее число - ниже высота. Большее число - выше высота.',
  component: FeatureNumberInput,
};

export const hear_sound_blooper: FeatureToggle = {
  name: 'Голоса (Барки) - Слышать',
  description: 'Вы не слышите свои и чужие голоса.',
  category: 'Звук',
  component: CheckboxInput,
};

export const sound_blooper_volume: Feature<number> = {
  name: 'Голоса (Барки) - Громкость',
  category: 'Звук',
  description: 'Громкость, на которой будут воспроизводиться голоса.',
  component: FeatureSliderInput,
};

export const send_sound_blooper: FeatureToggle = {
  name: 'Голоса (Барки) - Издавать голос',
  description: 'Вы можете слышать голоса других, но не издаёте их сами.',
  category: 'Звук',
  component: CheckboxInput,
};
