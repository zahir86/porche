/*
 * CMG_Q_GetCaseById
 * Rule input: caseId (Integer)
 * Restituisce sempre un singolo record CMG Case (o null), con le relazioni
 * necessarie a task e record view.
 */
if(
  a!isNullOrEmpty(ri!caseId),
  null,
  a!queryRecordByIdentifier(
    recordType: recordType!CMG Case,
    identifier: ri!caseId,
    fields: {
      recordType!CMG Case.fields.id,
      recordType!CMG Case.fields.caseNumber,
      recordType!CMG Case.fields.subject,
      recordType!CMG Case.fields.description,
      recordType!CMG Case.fields.status,
      recordType!CMG Case.fields.priority,
      recordType!CMG Case.fields.channel,
      recordType!CMG Case.fields.impact,
      recordType!CMG Case.fields.owner,
      recordType!CMG Case.fields.dueAt,
      recordType!CMG Case.fields.followUpAt,
      recordType!CMG Case.fields.followUpCount,
      recordType!CMG Case.fields.isCompleted,
      recordType!CMG Case.fields.customerId,
      recordType!CMG Case.fields.categoryId,
      recordType!CMG Case.fields.teamId,
      recordType!CMG Case.fields.parentCaseId,
      recordType!CMG Case.fields.createdAt,
      recordType!CMG Case.fields.createdBy,
      recordType!CMG Case.relationships.customer,
      recordType!CMG Case.relationships.category,
      recordType!CMG Case.relationships.team
    }
  )
)
