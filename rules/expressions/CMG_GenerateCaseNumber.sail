/*
 * CMG_GenerateCaseNumber
 * Rule input: caseId (Integer), createdAt (Date and Time)
 * Numero leggibile derivato dall'id interno: CMG-2026-000123.
 * Il numero non sostituisce l'id: è solo per le persone.
 */
concat(
  cons!CMG_CASE_NUMBER_PREFIX,
  "-",
  year(a!defaultValue(ri!createdAt, now())),
  "-",
  text(ri!caseId, "000000")
)
