/*
 * CMG_GetTeamForCategory
 * Rule input: categoryId (Integer)
 * Restituisce il record CMG Team responsabile della categoria (configurato a DB,
 * modificabile dagli amministratori senza toccare i process model).
 */
if(
  a!isNullOrEmpty(ri!categoryId),
  null,
  a!queryRecordByIdentifier(
    recordType: recordType!CMG Category,
    identifier: ri!categoryId,
    fields: {
      recordType!CMG Category.fields.teamId,
      recordType!CMG Category.relationships.team
    }
  )[recordType!CMG Category.relationships.team]
)
