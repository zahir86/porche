/*
 * CMG_C_CaseInformation  –  sezione INFORMATION di ogni task
 * Rule input:
 *   case             (CMG Case)  case con relazioni customer, category, team
 *   showActivities   (Boolean)   mostra le ultime attività
 * Mostra informazioni già "preparate" (es. "SLA scaduto da 3 ore", non solo la data).
 */
a!localVariables(
  local!dueAt: ri!case[recordType!CMG Case.fields.dueAt],
  local!isOverdue: and(a!isNotNullOrEmpty(local!dueAt), local!dueAt < now()),
  /* ore lavorative (calendario di processo), coerenti con lo SLA */
  local!workHours: if(
    a!isNullOrEmpty(local!dueAt),
    null,
    if(
      local!isOverdue,
      calworkhours(local!dueAt, now()),
      calworkhours(now(), local!dueAt)
    )
  ),
  local!activities: if(
    a!defaultValue(ri!showActivities, true),
    rule!CMG_Q_GetCaseActivities(
      caseId: ri!case[recordType!CMG Case.fields.id],
      pagingInfo: a!pagingInfo(
        startIndex: 1,
        batchSize: 5,
        sort: a!sortInfo(field: recordType!CMG Activity.fields.performedAt, ascending: false)
      )
    ).data,
    {}
  ),
  {
    a!sectionLayout(
      label: "Informazioni",
      contents: {
        a!columnsLayout(
          columns: {
            a!columnLayout(
              contents: {
                a!textField(
                  label: "Cliente",
                  labelPosition: "JUSTIFIED",
                  readOnly: true,
                  value: ri!case[recordType!CMG Case.relationships.customer.fields.name] &
                    if(ri!case[recordType!CMG Case.relationships.customer.fields.isVip], "  ★ VIP", "")
                ),
                a!textField(
                  label: "Categoria",
                  labelPosition: "JUSTIFIED",
                  readOnly: true,
                  value: ri!case[recordType!CMG Case.relationships.category.fields.name]
                ),
                a!textField(
                  label: "Canale",
                  labelPosition: "JUSTIFIED",
                  readOnly: true,
                  value: rule!CMG_FormatValue(ri!case[recordType!CMG Case.fields.channel])
                ),
                a!textField(
                  label: "Impatto",
                  labelPosition: "JUSTIFIED",
                  readOnly: true,
                  value: rule!CMG_FormatValue(ri!case[recordType!CMG Case.fields.impact])
                )
              }
            ),
            a!columnLayout(
              contents: {
                a!textField(
                  label: "Stato",
                  labelPosition: "JUSTIFIED",
                  readOnly: true,
                  value: rule!CMG_GetStatusLabel(ri!case[recordType!CMG Case.fields.status])
                ),
                a!textField(
                  label: "Team",
                  labelPosition: "JUSTIFIED",
                  readOnly: true,
                  value: ri!case[recordType!CMG Case.relationships.team.fields.name]
                ),
                a!richTextDisplayField(
                  label: "SLA",
                  labelPosition: "JUSTIFIED",
                  value: if(
                    a!isNullOrEmpty(local!dueAt),
                    "–",
                    a!richTextItem(
                      text: if(
                        local!isOverdue,
                        "Scaduto da " & local!workHours & " ore lavorative",
                        "Scade tra " & local!workHours & " ore lavorative (" & text(local!dueAt, "dd/mm/yyyy hh:mm") & ")"
                      ),
                      color: if(local!isOverdue, "NEGATIVE", "STANDARD"),
                      style: if(local!isOverdue, "STRONG", "PLAIN")
                    )
                  )
                ),
                a!textField(
                  label: "Follow-up eseguiti",
                  labelPosition: "JUSTIFIED",
                  readOnly: true,
                  value: ri!case[recordType!CMG Case.fields.followUpCount],
                  showWhen: ri!case[recordType!CMG Case.fields.followUpCount] > 0
                )
              }
            )
          }
        ),
        a!paragraphField(
          label: "Descrizione",
          labelPosition: "ABOVE",
          readOnly: true,
          value: ri!case[recordType!CMG Case.fields.description]
        )
      }
    ),
    a!sectionLayout(
      label: "Ultime attività",
      labelSize: "SMALL",
      isCollapsible: true,
      isInitiallyCollapsed: true,
      showWhen: a!isNotNullOrEmpty(local!activities),
      contents: {
        a!gridField(
          labelPosition: "COLLAPSED",
          data: local!activities,
          columns: {
            a!gridColumn(
              label: "Quando",
              value: text(fv!row[recordType!CMG Activity.fields.performedAt], "dd/mm/yyyy hh:mm")
            ),
            a!gridColumn(
              label: "Attività",
              value: rule!CMG_FormatValue(fv!row[recordType!CMG Activity.fields.type])
            ),
            a!gridColumn(
              label: "Chi",
              value: a!linkField(
                links: a!userRecordLink(user: fv!row[recordType!CMG Activity.fields.performedBy])
              )
            ),
            a!gridColumn(
              label: "Dettaglio",
              value: fv!row[recordType!CMG Activity.fields.description]
            )
          },
          pageSize: 5
        )
      }
    )
  }
)
