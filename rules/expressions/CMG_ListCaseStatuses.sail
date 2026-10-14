/*
 * CMG_ListCaseStatuses
 * Rule input: nessuno
 * Restituisce gli stati del case nell'ordine del ciclo di vita.
 * Collezione di costanti: una costante per stato, nessun indice posizionale.
 */
{
  cons!CMG_CASE_STATUS_NEW,
  cons!CMG_CASE_STATUS_TRIAGE,
  cons!CMG_CASE_STATUS_IN_PROGRESS,
  cons!CMG_CASE_STATUS_WAITING_CUSTOMER,
  cons!CMG_CASE_STATUS_IN_REVIEW,
  cons!CMG_CASE_STATUS_RESOLVED,
  cons!CMG_CASE_STATUS_CLOSED,
  cons!CMG_CASE_STATUS_CANCELLED
}
