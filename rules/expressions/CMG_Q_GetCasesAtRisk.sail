/*
 * CMG_Q_GetCasesAtRisk
 * Rule input: includeOverdue (Boolean), teamId (Integer, opzionale), pagingInfo (PagingInfo)
 * Case aperti con scadenza SLA entro CMG_AT_RISK_HOURS ore
 * (e, se includeOverdue, già scaduti). Filtro a query-time perché dipende da now().
 */
a!queryRecordType(
  recordType: recordType!CMG Case,
  filters: a!queryLogicalExpression(
    operator: "AND",
    filters: {
      a!queryFilter(
        field: recordType!CMG Case.fields.isCompleted,
        operator: "=",
        value: false
      ),
      a!queryFilter(
        field: recordType!CMG Case.fields.dueAt,
        operator: "<=",
        value: now() + intervalds(cons!CMG_AT_RISK_HOURS, 0, 0)
      ),
      a!queryFilter(
        field: recordType!CMG Case.fields.dueAt,
        operator: ">",
        value: now(),
        applyWhen: not(a!defaultValue(ri!includeOverdue, false))
      ),
      a!queryFilter(
        field: recordType!CMG Case.fields.teamId,
        operator: "=",
        value: ri!teamId,
        applyWhen: a!isNotNullOrEmpty(ri!teamId)
      )
    },
    ignoreFiltersWithEmptyValues: true
  ),
  pagingInfo: a!defaultValue(
    ri!pagingInfo,
    a!pagingInfo(
      startIndex: 1,
      batchSize: 50,
      sort: a!sortInfo(field: recordType!CMG Case.fields.dueAt, ascending: true)
    )
  )
)
