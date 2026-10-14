/*
 * CMG_ListOpenCaseStatuses
 * Rule input: nessuno
 * Stati in cui il case non è ancora completato.
 */
reject(
  contains(
    {
      cons!CMG_CASE_STATUS_RESOLVED,
      cons!CMG_CASE_STATUS_CLOSED,
      cons!CMG_CASE_STATUS_CANCELLED
    },
    _
  ),
  rule!CMG_ListCaseStatuses()
)
