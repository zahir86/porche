/*
 * CMG_GetNextFollowUpAt
 * Rule input: startAt (Date and Time, opzionale)
 * Data del prossimo follow-up: N giorni lavorativi (costante gestibile).
 */
a!addDateTime(
  startDateTime: a!defaultValue(ri!startAt, now()),
  days: cons!CMG_FOLLOW_UP_DEFAULT_DAYS,
  useProcessCalendar: true
)
