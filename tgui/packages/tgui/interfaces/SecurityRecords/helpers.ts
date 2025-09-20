import { useBackend, useLocalState } from 'tgui/backend';

import {
  PRINTOUT,
  type SecurityRecord,
  type SecurityRecordsData,
} from './types';

/** We need an active reference and this a pain to rewrite */
export const getSecurityRecord = () => {
  const [selectedRecord] = useLocalState<SecurityRecord | undefined>(
    'securityRecord',
    undefined,
  );
  if (!selectedRecord) return;
  const { data } = useBackend<SecurityRecordsData>();
  const { records = [] } = data;
  const foundRecord = records.find(
    (record) => record.crew_ref === selectedRecord.crew_ref,
  );
  if (!foundRecord) return;

  return foundRecord;
};

// Lazy type union
type GenericRecord = {
  name: string;
  rank: string;
  fingerprint?: string;
  dna?: string;
};

/** Matches search by fingerprint, dna, job, or name */
export const isRecordMatch = (record: GenericRecord, search: string) => {
  if (!search) return true;
  const { name, rank, fingerprint, dna } = record;

  switch (true) {
    case name?.toLowerCase().includes(search?.toLowerCase()):
    case rank?.toLowerCase().includes(search?.toLowerCase()):
    case fingerprint?.toLowerCase().includes(search?.toLowerCase()):
    case dna?.toLowerCase().includes(search?.toLowerCase()):
      return true;

    default:
      return false;
  }
};

/** Возвращает строку заголовка на основе типа печати */
export const getDefaultPrintHeader = (printType: PRINTOUT) => {
  switch (printType) {
    case PRINTOUT.Rapsheet:
      return 'Досье';
    case PRINTOUT.Wanted:
      return 'РАЗЫСКИВАЕТСЯ';
    case PRINTOUT.Missing:
      return 'ПРОПАВШИЙ БЕЗ ВЕСТИ';
  }
};

/** Возвращает строку описания на основе типа печати */
export const getDefaultPrintDescription = (
  name: string,
  printType: PRINTOUT,
) => {
  switch (printType) {
    case PRINTOUT.Rapsheet:
      return `Стандартный учётный лист СБ на ${name}.`;
    case PRINTOUT.Wanted:
      return `Постер, объявляющий ${name} разыскиваемым преступником. Немедленно сообщайте о любых случаях обнаружения в службу безопасности.`;
    case PRINTOUT.Missing:
      return `Постер, объявляющий ${name} пропавшим без вести. Немедленно сообщайте о любых случаях обнаружения в службу безопасности.`;
  }
};
