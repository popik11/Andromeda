import {
  AnimatedNumber,
  Box,
  Button,
  Flex,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';

export const MedicalKiosk = (props) => {
  const { act, data } = useBackend();
  const [scanIndex] = useSharedState('scanIndex');
  const { active_status_1, active_status_2, active_status_3, active_status_4 } =
    data;
  return (
    <Window width={575} height={420}>
      <Window.Content scrollable>
        <Flex mb={1}>
          <Flex.Item mr={1}>
            <Section minHeight="100%">
              <MedicalKioskScanButton
                index={1}
                icon="procedures"
                name="Общее сканирование здоровья"
                description={`
                  Показывает точные значения вашего общего сканирования здоровья.
                `}
              />
              <MedicalKioskScanButton
                index={2}
                icon="heartbeat"
                name="Проверка на основе симптомов"
                description={`
                  Предоставляет информацию на основе различных неочевидных симптомов,
                  таких как уровень крови или статус заболеваний.
                `}
              />
              <MedicalKioskScanButton
                index={3}
                icon="radiation-alt"
                name="Неврологическое/Радиологическое сканирование"
                description={`
                  Предоставляет информацию о черепно-мозговых травмах и радиации.
                `}
              />
              <MedicalKioskScanButton
                index={4}
                icon="mortar-pestle"
                name="Химическое и Психоактивное сканирование"
                description={`
                  Предоставляет список потребленных химических веществ, а также возможные
                  побочные эффекты.
                `}
              />
            </Section>
          </Flex.Item>
          <Flex.Item grow={1} basis={0}>
            <MedicalKioskInstructions />
          </Flex.Item>
        </Flex>
        {!!active_status_1 && scanIndex === 1 && <MedicalKioskScanResults1 />}
        {!!active_status_2 && scanIndex === 2 && <MedicalKioskScanResults2 />}
        {!!active_status_3 && scanIndex === 3 && <MedicalKioskScanResults3 />}
        {!!active_status_4 && scanIndex === 4 && <MedicalKioskScanResults4 />}
      </Window.Content>
    </Window>
  );
};

const MedicalKioskScanButton = (props) => {
  const { index, name, description, icon } = props;
  const { act, data } = useBackend();
  const [scanIndex, setScanIndex] = useSharedState('scanIndex');
  const paid = data[`active_status_${index}`];
  return (
    <Stack align="baseline">
      <Stack.Item width="16px" textAlign="center">
        <Icon
          name={paid ? 'check' : 'dollar-sign'}
          color={paid ? 'green' : 'grey'}
        />
      </Stack.Item>
      <Stack.Item grow basis="content">
        <Button
          fluid
          icon={icon}
          selected={paid && scanIndex === index}
          tooltip={description}
          tooltipPosition="right"
          content={name}
          onClick={() => {
            if (!paid) {
              act(`beginScan_${index}`);
            }
            setScanIndex(index);
          }}
        />
      </Stack.Item>
    </Stack>
  );
};

const MedicalKioskInstructions = (props) => {
  const { act, data } = useBackend();
  const { kiosk_cost, patient_name } = data;
  return (
    <Section minHeight="100%">
      <Box italic>
        Приветствуем, уважаемый сотрудник! Пожалуйста, выберите желаемую автоматическую проверку
        здоровья. Диагностика стоит <b>{kiosk_cost} кредитов.</b>
      </Box>
      <Box mt={1}>
        <Box inline color="label" mr={1}>
          Пациент:
        </Box>
        {patient_name}
      </Box>
      <Button
        mt={1}
        tooltip={`
          Сбрасывает текущую цель сканирования, отменяя текущие сканирования.
        `}
        icon="sync"
        color="average"
        onClick={() => act('clearTarget')}
        content="Сбросить сканер"
      />
    </Section>
  );
};

const MedicalKioskScanResults1 = (props) => {
  const { data } = useBackend();
  const {
    patient_health,
    brute_health,
    burn_health,
    suffocation_health,
    toxin_health,
  } = data;
  return (
    <Section title="Здоровье пациента">
      <LabeledList>
        <LabeledList.Item label="Общее здоровье">
          <ProgressBar value={patient_health / 100}>
            <AnimatedNumber value={patient_health} />%
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Divider />
        <LabeledList.Item label="Урон от ударов">
          <ProgressBar value={brute_health / 100} color="bad">
            <AnimatedNumber value={brute_health} />
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Урон от ожогов">
          <ProgressBar value={burn_health / 100} color="bad">
            <AnimatedNumber value={burn_health} />
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Урон от удушья">
          <ProgressBar value={suffocation_health / 100} color="bad">
            <AnimatedNumber value={suffocation_health} />
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Урон от токсинов">
          <ProgressBar value={toxin_health / 100} color="bad">
            <AnimatedNumber value={toxin_health} />
          </ProgressBar>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const MedicalKioskScanResults2 = (props) => {
  const { data } = useBackend();
  const {
    patient_status,
    patient_illness,
    illness_info,
    bleed_status,
    blood_levels,
    blood_name,
    blood_status,
  } = data;
  return (
    <Section title="Проверка на основе симптомов">
      <LabeledList>
        <LabeledList.Item label="Статус пациента" color="good">
          {patient_status}
        </LabeledList.Item>
        <LabeledList.Divider />
        <LabeledList.Item label="Статус заболеваний">
          {patient_illness}
        </LabeledList.Item>
        <LabeledList.Item label="Информация о заболевании">
          {illness_info}
        </LabeledList.Item>
        <LabeledList.Divider />
        <LabeledList.Item label={`Уровень ${blood_name}`}>
          <ProgressBar value={blood_levels / 100} color="bad">
            <AnimatedNumber value={blood_levels} />
          </ProgressBar>
          <Box mt={1} color="label">
            {bleed_status}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label={`Информация о ${blood_name}`}>
          {blood_status}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const MedicalKioskScanResults3 = (props) => {
  const { data } = useBackend();
  const { brain_damage, brain_health, trauma_status } = data;
  return (
    <Section title="Неврологическое здоровье пациента">
      <LabeledList>
        <LabeledList.Item label="Повреждение мозга">
          <ProgressBar value={brain_damage / 100} color="good">
            <AnimatedNumber value={brain_damage} />
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Состояние мозга" color="health-0">
          {brain_health}
        </LabeledList.Item>
        <LabeledList.Item label="Статус черепно-мозговых травм">
          {trauma_status}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const MedicalKioskScanResults4 = (props) => {
  const { data } = useBackend();
  const {
    chemical_list = [],
    overdose_list = [],
    addict_list = [],
    hallucinating_status,
    blood_alcohol,
  } = data;
  return (
    <Section title="Химический и психоактивный анализ">
      <LabeledList>
        <LabeledList.Item label="Химический состав">
          {chemical_list.length === 0 && (
            <Box color="average">Реагенты не обнаружены.</Box>
          )}
          {chemical_list.map((chem) => (
            <Box key={chem.id} color="good">
              {chem.volume} мл {chem.name}
            </Box>
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="Статус передозировки" color="bad">
          {overdose_list.length === 0 && (
            <Box color="good">Пациент не имеет передозировки.</Box>
          )}
          {overdose_list.map((chem) => (
            <Box key={chem.id}>Передозировка {chem.name}</Box>
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="Статус зависимости" color="bad">
          {addict_list.length === 0 && (
            <Box color="good">Пациент не имеет зависимостей.</Box>
          )}
          {addict_list.map((chem) => (
            <Box key={chem.id}>Зависимость от {chem.name}</Box>
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="Психоактивный статус">
          {hallucinating_status}
        </LabeledList.Item>
        <LabeledList.Item label="Содержание алкоголя в крови">
          <ProgressBar
            value={blood_alcohol}
            minValue={0}
            maxValue={0.3}
            ranges={{
              blue: [-Infinity, 0.23],
              bad: [0.23, Infinity],
            }}
          >
            <AnimatedNumber value={blood_alcohol} />
          </ProgressBar>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
