/*
 * CMG_D_CaseSummary  –  record view "Summary" del record CMG Case
 * Rule input: caseId (Integer)   → nel record type: rule!CMG_D_CaseSummary(caseId: rv!identifier)
 * È l'ultimo livello del drill-down, non il posto dove si lavora (si lavora nei task).
 * Gerarchia: identificazione nel titolo · performance a sinistra (fondo grigio) ·
 * contenuto al centro · stato e task a destra.
 * Tutte le query sono qui (una sola volta) e i dati sono passati ai componenti.
 */
a!localVariables(
  local!case: rule!CMG_Q_GetCaseById(caseId: ri!caseId),
  local!dueAt: local!case[recordType!CMG Case.fields.dueAt],
  local!isCompleted: a!defaultValue(local!case[recordType!CMG Case.fields.isCompleted], false),
  local!isOverdue: and(not(local!isCompleted), a!isNotNullOrEmpty(local!dueAt), local!dueAt < now()),
  local!openTasks: a!queryProcessAnalytics(
    report: cons!CMG_PR_CASE_TASKS,
    query: a!query(
      filter: a!queryFilter(field: "c5", operator: "=", value: ri!caseId),
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 10)
    )
  ).data,
  local!transitions: a!queryRecordType(
    recordType: recordType!CMG Status Transition,
    filters: a!queryFilter(
      field: recordType!CMG Status Transition.fields.caseId,
      operator: "=",
      value: ri!caseId
    ),
    pagingInfo: a!pagingInfo(
      startIndex: 1,
      batchSize: 50,
      sort: a!sortInfo(field: recordType!CMG Status Transition.fields.enteredAt, ascending: true)
    )
  ).data,
  local!comments: a!queryRecordType(
    recordType: recordType!CMG Comment,
    filters: a!queryFilter(
      field: recordType!CMG Comment.fields.caseId,
      operator: "=",
      value: ri!caseId
    ),
    pagingInfo: a!pagingInfo(
      startIndex: 1,
      batchSize: 20,
      sort: a!sortInfo(field: recordType!CMG Comment.fields.createdAt, ascending: false)
    )
  ).data,
  a!columnsLayout(
    columns: {
      /* PERFORMANCE */
      a!columnLayout(
        width: "MEDIUM",
        contents: a!cardLayout(
          style: "#F2F4F7",
          showBorder: false,
          contents: {
            a!richTextDisplayField(
              label: "Stato",
              labelPosition: "ABOVE",
              value: a!richTextItem(
                text: rule!CMG_GetStatusLabel(local!case[recordType!CMG Case.fields.status]),
                size: "MEDIUM",
                style: "STRONG"
              )
            ),
            a!tagField(
              label: "Priorità",
              labelPosition: "ABOVE",
              tags: a!tagItem(
                text: rule!CMG_FormatValue(local!case[recordType!CMG Case.fields.priority]),
                backgroundColor: rule!CMG_GetPriorityColor(local!case[recordType!CMG Case.fields.priority])
              )
            ),
            a!richTextDisplayField(
              label: "Scadenza SLA",
              labelPosition: "ABOVE",
              value: a!richTextItem(
                text: if(
                  a!isNullOrEmpty(local!dueAt),
                  "–",
                  text(local!dueAt, "dd/mm/yyyy hh:mm") & if(local!isOverdue, "  (scaduto)", "")
                ),
                color: if(local!isOverdue, "NEGATIVE", "STANDARD"),
                style: if(local!isOverdue, "STRONG", "PLAIN")
              )
            ),
            a!linkField(
              label: "Owner",
              labelPosition: "ABOVE",
              links: a!userRecordLink(user: local!case[recordType!CMG Case.fields.owner]),
              showWhen: a!isNotNullOrEmpty(local!case[recordType!CMG Case.fields.owner])
            ),
            a!textField(
              label: "Team",
              labelPosition: "ABOVE",
              readOnly: true,
              value: local!case[recordType!CMG Case.relationships.team.fields.name]
            ),
            a!textField(
              label: "Aperto il",
              labelPosition: "ABOVE",
              readOnly: true,
              value: text(local!case[recordType!CMG Case.fields.createdAt], "dd/mm/yyyy hh:mm")
            )
          }
        )
      ),
      /* CONTENUTO */
      a!columnLayout(
        contents: {
          a!sectionLayout(
            label: "Richiesta",
            contents: {
              a!linkField(
                label: "Cliente",
                labelPosition: "JUSTIFIED",
                links: a!recordLink(
                  label: local!case[recordType!CMG Case.relationships.customer.fields.name],
                  recordType: recordType!CMG Customer,
                  identifier: local!case[recordType!CMG Case.fields.customerId]
                )
              ),
              a!textField(
                label: "Categoria",
                labelPosition: "JUSTIFIED",
                readOnly: true,
                value: local!case[recordType!CMG Case.relationships.category.fields.name]
              ),
              a!textField(
                label: "Canale",
                labelPosition: "JUSTIFIED",
                readOnly: true,
                value: rule!CMG_FormatValue(local!case[recordType!CMG Case.fields.channel])
              ),
              a!linkField(
                label: "Case collegato",
                labelPosition: "JUSTIFIED",
                showWhen: a!isNotNullOrEmpty(local!case[recordType!CMG Case.fields.parentCaseId]),
                links: a!recordLink(
                  label: "Vai al case originale",
                  recordType: recordType!CMG Case,
                  identifier: local!case[recordType!CMG Case.fields.parentCaseId]
                )
              ),
              a!paragraphField(
                label: "Descrizione",
                labelPosition: "ABOVE",
                readOnly: true,
                value: local!case[recordType!CMG Case.fields.description]
              )
            }
          ),
          a!sectionLayout(
            label: "Commenti",
            contents: {
              a!richTextDisplayField(
                labelPosition: "COLLAPSED",
                value: a!richTextItem(text: "Nessun commento", color: "SECONDARY"),
                showWhen: a!isNullOrEmpty(local!comments)
              ),
              a!forEach(
                items: local!comments,
                expression: a!cardLayout(
                  showBorder: false,
                  style: if(fv!item[recordType!CMG Comment.fields.isInternal], "#FFFAEB", "NONE"),
                  contents: a!richTextDisplayField(
                    labelPosition: "COLLAPSED",
                    value: {
                      a!richTextItem(
                        text: user(fv!item[recordType!CMG Comment.fields.createdBy], "firstName") & " " &
                          user(fv!item[recordType!CMG Comment.fields.createdBy], "lastName") & " · " &
                          text(fv!item[recordType!CMG Comment.fields.createdAt], "dd/mm/yyyy hh:mm") &
                          if(fv!item[recordType!CMG Comment.fields.isInternal], " · interno", ""),
                        size: "SMALL",
                        color: "SECONDARY"
                      ),
                      char(10),
                      fv!item[recordType!CMG Comment.fields.text]
                    }
                  )
                )
              )
            }
          )
        }
      ),
      /* STATO E TASK */
      a!columnLayout(
        width: "MEDIUM",
        contents: {
          a!sectionLayout(
            label: "Task aperti",
            contents: {
              a!richTextDisplayField(
                labelPosition: "COLLAPSED",
                value: a!richTextItem(
                  text: if(local!isCompleted, "Case completato", "Nessun task aperto"),
                  color: "SECONDARY"
                ),
                showWhen: a!isNullOrEmpty(local!openTasks)
              ),
              a!forEach(
                items: local!openTasks,
                expression: a!richTextDisplayField(
                  labelPosition: "COLLAPSED",
                  value: {
                    a!richTextItem(
                      text: fv!item.c0,
                      link: a!processTaskLink(task: fv!item.dp0),
                      style: "STRONG"
                    ),
                    char(10),
                    a!richTextItem(text: "Assegnato a: " & fv!item.c3, size: "SMALL", color: "SECONDARY")
                  }
                )
              )
            }
          ),
          a!sectionLayout(
            label: "Storico stati",
            contents: a!gridField(
              labelPosition: "COLLAPSED",
              data: local!transitions,
              columns: {
                a!gridColumn(
                  label: "Stato",
                  value: rule!CMG_GetStatusLabel(fv!row[recordType!CMG Status Transition.fields.toStatus])
                ),
                a!gridColumn(
                  label: "Dal",
                  value: text(fv!row[recordType!CMG Status Transition.fields.enteredAt], "dd/mm hh:mm")
                ),
                a!gridColumn(
                  label: "Ore",
                  align: "END",
                  value: fv!row[recordType!CMG Status Transition.fields.durationHours]
                )
              },
              pageSize: 10,
              borderStyle: "LIGHT"
            )
          )
        }
      )
    }
  )
)
