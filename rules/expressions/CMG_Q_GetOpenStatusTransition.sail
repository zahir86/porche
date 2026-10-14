/*
 * CMG_Q_GetOpenStatusTransition
 * Rule input: caseId (Integer)
 * Restituisce la transizione di stato ancora aperta (exitedAt nullo) o null.
 * Usata da CMG Change Case Status per chiudere la fase precedente.
 */
index(
  a!queryRecordType(
    recordType: recordType!CMG Status Transition,
    filters: {
      a!queryFilter(
        field: recordType!CMG Status Transition.fields.caseId,
        operator: "=",
        value: ri!caseId
      ),
      a!queryFilter(
        field: recordType!CMG Status Transition.fields.exitedAt,
        operator: "is null"
      )
    },
    pagingInfo: a!pagingInfo(
      startIndex: 1,
      batchSize: 1,
      sort: a!sortInfo(
        field: recordType!CMG Status Transition.fields.enteredAt,
        ascending: false
      )
    )
  ).data,
  1,
  null
)
