import { filter, map } from 'es-toolkit/compat';
import { useState } from 'react';
import {
  Box,
  Button,
  Divider,
  Dropdown,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { exhaustiveCheck } from 'tgui-core/exhaustive';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type CurrentStationTrait = {
  can_revert: BooleanLike;
  name: string;
  ref: string;
};

type ValidStationTrait = {
  name: string;
  path: string;
};

type StationTraitsData = {
  current_traits: CurrentStationTrait[];
  future_station_traits?: ValidStationTrait[];
  too_late_to_revert: BooleanLike;
  valid_station_traits: ValidStationTrait[];
};

enum Tab {
  SetupFutureStationTraits,
  ViewStationTraits,
}

const FutureStationTraitsPage = (props) => {
  const { act, data } = useBackend<StationTraitsData>();
  const { future_station_traits } = data;

  const [selectedTrait, setSelectedTrait] = useState<string>('');

  const traitsByName = Object.fromEntries(
    data.valid_station_traits.map((trait) => {
      return [trait.name, trait.path];
    }),
  );

  const traitNames = Object.keys(traitsByName);
  traitNames.sort();

  return (
    <Box>
      <Stack fill>
        <Stack.Item grow>
          <Dropdown
            onSelected={setSelectedTrait}
            options={traitNames}
            placeholder="Выберите трейт для добавления..."
            selected={selectedTrait}
            width="100%"
          />
        </Stack.Item>

        <Stack.Item>
          <Button
            color="green"
            icon="plus"
            onClick={() => {
              if (!selectedTrait) {
                return;
              }

              const selectedPath = traitsByName[selectedTrait];

              let newStationTraits = [selectedPath];
              if (future_station_traits) {
                const selectedTraitPaths = future_station_traits.map(
                  (trait) => trait.path,
                );

                if (selectedTraitPaths.indexOf(selectedPath) !== -1) {
                  return;
                }

                newStationTraits = newStationTraits.concat(
                  ...selectedTraitPaths,
                );
              }

              act('setup_future_traits', {
                station_traits: newStationTraits,
              });
            }}
          >
            Добавить
          </Button>
        </Stack.Item>
      </Stack>

      <Divider />

      {Array.isArray(future_station_traits) ? (
        future_station_traits.length > 0 ? (
          <Stack vertical fill>
            {future_station_traits.map((trait) => (
              <Stack.Item key={trait.path}>
                <Stack fill>
                  <Stack.Item grow>{trait.name}</Stack.Item>

                  <Stack.Item>
                    <Button
                      color="red"
                      icon="times"
                      onClick={() => {
                        act('setup_future_traits', {
                          station_traits: filter(
                            map(future_station_traits, (t) => t.path),
                            (p) => p !== trait.path,
                          ),
                        });
                      }}
                    >
                      Удалить
                    </Button>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            ))}
          </Stack>
        ) : (
          <>
            <Box>В следующем раунде не будет запущено ни одного станционного трейта.</Box>

            <Box>
              <Button
                color="red"
                icon="times"
                tooltip="Следующий раунд будет случайным образом выбирать станционные трейты, как обычно."
                onClick={() => act('clear_future_traits')}
              >
                Запускать станционные трейты - Обычно
              </Button>
            </Box>
          </>
        )
      ) : (
        <>
          <Box>Будущие станционные трейты не запланированы.</Box>

          <Box>
            <Button
              color="red"
              icon="times"
              onClick={() =>
                act('setup_future_traits', {
                  station_traits: [],
                })
              }
            >
              Запретить запуск станционных трейтов в следующем раунде
            </Button>
          </Box>
        </>
      )}
    </Box>
  );
};

const ViewStationTraitsPage = (props) => {
  const { act, data } = useBackend<StationTraitsData>();

  return data.current_traits.length > 0 ? (
    <Stack vertical fill>
      {data.current_traits.map((stationTrait) => (
        <Stack.Item key={stationTrait.ref}>
          <Stack fill>
            <Stack.Item grow>{stationTrait.name}</Stack.Item>

            <Stack.Item>
              <Button.Confirm
                content="Отменить"
                color="red"
                disabled={data.too_late_to_revert || !stationTrait.can_revert}
                tooltip={
                  (!stationTrait.can_revert &&
                    'Этот трейт нельзя отменить.') ||
                  (data.too_late_to_revert &&
                    "Слишком поздно отменять станционные трейты, раунд уже начался.")
                }
                icon="times"
                onClick={() =>
                  act('revert', {
                    ref: stationTrait.ref,
                  })
                }
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      ))}
    </Stack>
  ) : (
    <Box>Нет активных станционных трейтов.</Box>
  );
};

export const StationTraitsPanel = (props) => {
  const [currentTab, setCurrentTab] = useState(Tab.ViewStationTraits);

  let currentPage;

  switch (currentTab) {
    case Tab.SetupFutureStationTraits:
      currentPage = <FutureStationTraitsPage />;
      break;
    case Tab.ViewStationTraits:
      currentPage = <ViewStationTraitsPage />;
      break;
    default:
      exhaustiveCheck(currentTab);
  }

  return (
    <Window title="Изменить Станционные Трейты" height={500} width={500}>
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            icon="eye"
            selected={currentTab === Tab.ViewStationTraits}
            onClick={() => setCurrentTab(Tab.ViewStationTraits)}
          >
            Просмотреть
          </Tabs.Tab>

          <Tabs.Tab
            icon="edit"
            selected={currentTab === Tab.SetupFutureStationTraits}
            onClick={() => setCurrentTab(Tab.SetupFutureStationTraits)}
          >
            Редактировать
          </Tabs.Tab>
        </Tabs>

        <Divider />

        {currentPage}
      </Window.Content>
    </Window>
  );
};
