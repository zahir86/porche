/*
 * CMG_Q_GetCaseActivities
 * Rule input: caseId (Integer), pagingInfo (PagingInfo, opzionale)
 * Restituisce un DataSubset, quindi può alimentare direttamente una grid.
 */
a!queryRecordType(
  recordType: recordType!CMG Activity,
  filters: a!queryFilter(
    field: recordType!CMG Activity.fields.caseId,
    operator: "=",
    value: ri!caseId
  ),
  pagingInfo: a!defaultValue(
    ri!pagingInfo,
    a!pagingInfo(
      startIndex: 1,
      batchSize: 20,
      sort: a!sortInfo(
        field: recordType!CMG Activity.fields.performedAt,
        ascending: false
      )
    )
  )
)
