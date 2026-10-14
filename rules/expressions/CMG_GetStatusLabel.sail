/*
 * CMG_GetStatusLabel
 * Rule input: status (Text)
 * Etichetta italiana per lo stato del case.
 */
a!match(
  value: ri!status,
  equals: cons!CMG_CASE_STATUS_NEW,              then: "Nuovo",
  equals: cons!CMG_CASE_STATUS_TRIAGE,           then: "In triage",
  equals: cons!CMG_CASE_STATUS_IN_PROGRESS,      then: "In lavorazione",
  equals: cons!CMG_CASE_STATUS_WAITING_CUSTOMER, then: "In attesa del cliente",
  equals: cons!CMG_CASE_STATUS_IN_REVIEW,        then: "In verifica",
  equals: cons!CMG_CASE_STATUS_RESOLVED,         then: "Risolto",
  equals: cons!CMG_CASE_STATUS_CLOSED,           then: "Chiuso",
  equals: cons!CMG_CASE_STATUS_CANCELLED,        then: "Annullato",
  default: rule!CMG_FormatValue(ri!status)
)
