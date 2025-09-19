import { useBackend } from 'tgui/backend';
import {
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { capitalizeFirst } from 'tgui-core/string';

import type { Data } from './types';

/** Displays loaded container info, if it exists */
export const BeakerDisplay = (props) => {
  const { act, data } = useBackend<Data>();
  const { has_beaker, beaker, has_blood } = data;
  const cant_empty = !has_beaker || !beaker?.volume;
  let content;
  if (!has_beaker) {
    content = <NoticeBox>Мензурка не загружена.</NoticeBox>;
  } else if (!beaker?.volume) {
    content = <NoticeBox>Мензурка пуста.</NoticeBox>;
  } else if (!has_blood) {
    content = <NoticeBox>Образец крови не загружен.</NoticeBox>;
  } else {
    content = (
      <Stack vertical>
        <Stack.Item>
          <Info />
        </Stack.Item>
        <Stack.Item>
          <Antibodies />
        </Stack.Item>
      </Stack>
    );
  }

  return (
    <Section
      title="Мензурка"
      buttons={
        <>
          <Button
            icon="times"
            content="Очистить и Извлечь"
            color="bad"
            disabled={cant_empty}
            onClick={() => act('empty_eject_beaker')}
          />
          <Button
            icon="trash"
            content="Очистить"
            disabled={cant_empty}
            onClick={() => act('empty_beaker')}
          />
          <Button
            icon="eject"
            content="Извлечь"
            disabled={!has_beaker}
            onClick={() => act('eject_beaker')}
          />
        </>
      }
    >
      {content}
    </Section>
  );
};

/** Displays info about the blood type, beaker capacity - volume */
const Info = (props) => {
  const { data } = useBackend<Data>();
  const { beaker, blood } = data;
  if (!beaker || !blood) {
    return <NoticeBox>Мензурка не загружена</NoticeBox>;
  }

  return (
    <Stack>
      <Stack.Item grow={2}>
        <LabeledList>
          <LabeledList.Item label="ДНК">
            {capitalizeFirst(blood.dna)}
          </LabeledList.Item>
          <LabeledList.Item label="Группа">
            {capitalizeFirst(blood.type)}
          </LabeledList.Item>
        </LabeledList>
      </Stack.Item>
      <Stack.Item grow={2}>
        <LabeledList>
          <LabeledList.Item label="Контейнер">
            <ProgressBar
              color="darkred"
              value={beaker.volume}
              minValue={0}
              maxValue={beaker.capacity}
              ranges={{
                good: [beaker.capacity * 0.85, beaker.capacity],
                average: [beaker.capacity * 0.25, beaker.capacity * 0.85],
                bad: [0, beaker.capacity * 0.25],
              }}
            />
          </LabeledList.Item>
        </LabeledList>
      </Stack.Item>
    </Stack>
  );
};

/** If antibodies are present, returns buttons to create vaccines */
const Antibodies = (props) => {
  const { act, data } = useBackend<Data>();
  const { is_ready, resistances = [] } = data;
  if (!resistances) {
    return <NoticeBox>Ничего не обнаружено</NoticeBox>;
  }

  return (
    <LabeledList>
      <LabeledList.Item label="Антитела">
        {!resistances.length
          ? 'Отсутствуют'
          : resistances.map((resistance) => {
              return (
                <Button
                  key={resistance.name}
                  icon="eye-dropper"
                  disabled={!is_ready}
                  tooltip="Создает флакон для вакцины."
                  onClick={() =>
                    act('create_vaccine_bottle', {
                      index: resistance.id,
                    })
                  }
                >
                  {`${resistance.name}`}
                </Button>
              );
            })}
      </LabeledList.Item>
    </LabeledList>
  );
};
