/*
 * CMG_D_Monitoring  –  pagina "Monitoring" del site (supervisor / team leader)
 * Rule input: nessuno
 * Domanda: "Il processo gira?" – carico attuale, SLA a rischio, distribuzione.
 * Dati live dal record CMG Case. Click sul grafico per stato → filtra la grid.
 */
a!localVariables(
  local!openFilter: a!queryFilter(
    field: recordType!CMG Case.fields.isCompleted,
    operator: "=",
    value: false
  ),
  local!countOf: a!refreshVariable(
    value: a!map(
      open: a!queryRecordType(
        recordType: recordType!CMG Case,
        fields: recordType!CMG Case.fields.id,
        filters: local!openFilter,
        pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
        fetchTotalCount: true
      ).totalCount,
      overdue: a!queryRecordType(
        recordType: recordType!CMG Case,
        fields: recordType!CMG Case.fields.id,
        filters: {
          local!openFilter,
          a!queryFilter(field: recordType!CMG Case.fields.dueAt, operator: "<", value: now())
        },
        pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
        fetchTotalCount: true
      ).totalCount,
      atRisk: rule!CMG_Q_GetCasesAtRisk(
        includeOverdue: false,
        pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1)
      ).totalCount,
      waiting: a!queryRecordType(
        recordType: recordType!CMG Case,
        fields: recordType!CMG Case.fields.id,
        filters: a!queryFilter(
          field: recordType!CMG Case.fields.status,
          operator: "=",
          value: cons!CMG_CASE_STATUS_WAITING_CUSTOMER
        ),
        pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
        fetchTotalCount: true
      ).totalCount
    ),
    refreshInterval: 5
  ),
  local!selectedStatus,
  {
    a!columnsLayout(
      columns: {
        a!columnLayout(
          contents: a!billboardLayout(
            backgroundColor: "#1D4ED8",
            height: "SHORT",
            overlay: a!barOverlay(
              contents: a!richTextDisplayField(
                labelPosition: "COLLAPSED",
                align: "CENTER",
                value: {
                  a!richTextItem(text: local!countOf.open, size: "LARGE", style: "STRONG"),
                  char(10),
                  "Case aperti"
                }
              )
            )
          )
        ),
        a!columnLayout(
          contents: a!billboardLayout(
            backgroundColor: "#B42318",
            height: "SHORT",
            overlay: a!barOverlay(
              contents: a!richTextDisplayField(
                labelPosition: "COLLAPSED",
                align: "CENTER",
                value: {
                  a!richTextItem(text: local!countOf.overdue, size: "LARGE", style: "STRONG"),
                  char(10),
                  "SLA scaduto"
                }
              )
            )
          )
        ),
        a!columnLayout(
          contents: a!billboardLayout(
            backgroundColor: "#DC6803",
            height: "SHORT",
            overlay: a!barOverlay(
              contents: a!richTextDisplayField(
                labelPosition: "COLLAPSED",
                align: "CENTER",
                value: {
                  a!richTextItem(text: local!countOf.atRisk, size: "LARGE", style: "STRONG"),
                  char(10),
                  "A rischio (< " & cons!CMG_AT_RISK_HOURS & " h)"
                }
              )
            )
          )
        ),
        a!columnLayout(
          contents: a!billboardLayout(
            backgroundColor: "#475467",
            height: "SHORT",
            overlay: a!barOverlay(
              contents: a!richTextDisplayField(
                labelPosition: "COLLAPSED",
                align: "CENTER",
                value: {
                  a!richTextItem(text: local!countOf.waiting, size: "LARGE", style: "STRONG"),
                  char(10),
                  "In attesa del cliente"
                }
              )
            )
          )
        )
      }
    ),
    a!columnsLayout(
      columns: {
        a!columnLayout(
          contents: a!sectionLayout(
            label: "Case aperti per stato",
            contents: a!columnChartField(
              data: a!recordData(recordType: recordType!CMG Case, filters: local!openFilter),
              config: a!columnChartConfig(
                primaryGrouping: a!grouping(field: recordType!CMG Case.fields.status, alias: "status"),
                measures: a!measure(function: "COUNT", field: recordType!CMG Case.fields.id, alias: "count"),
                link: a!dynamicLink(value: fv!selection.status, saveInto: local!selectedStatus)
              ),
              label: "Clicca una colonna per filtrare la lista",
              labelPosition: "ABOVE",
              showLegend: false,
              refreshAfter: "RECORD_ACTION"
            )
          )
        ),
        a!columnLayout(
          contents: a!sectionLayout(
            label: "Carico per team e priorità",
            contents: a!barChartField(
              data: a!recordData(recordType: recordType!CMG Case, filters: local!openFilter),
              config: a!barChartConfig(
                primaryGrouping: a!grouping(
                  field: recordType!CMG Case.relationships.team.fields.name,
                  alias: "team"
                ),
                secondaryGrouping: a!grouping(field: recordType!CMG Case.fields.priority, alias: "priority"),
                measures: a!measure(function: "COUNT", field: recordType!CMG Case.fields.id, alias: "count")
              ),
              stacking: "NORMAL",
              refreshAfter: "RECORD_ACTION"
            )
          )
        )
      }
    ),
    a!sectionLayout(
      label: if(
        a!isNullOrEmpty(local!selectedStatus),
        "Case aperti per scadenza",
        "Case in stato: " & rule!CMG_GetStatusLabel(local!selectedStatus)
      ),
      contents: {
        a!buttonArrayLayout(
          showWhen: a!isNotNullOrEmpty(local!selectedStatus),
          buttons: a!buttonWidget(
            label: "Rimuovi filtro",
            style: "LINK",
            value: null,
            saveInto: local!selectedStatus
          )
        ),
        a!gridField(
          labelPosition: "COLLAPSED",
          data: a!recordData(
            recordType: recordType!CMG Case,
            filters: a!queryLogicalExpression(
              operator: "AND",
              filters: {
                local!openFilter,
                a!queryFilter(
                  field: recordType!CMG Case.fields.status,
                  operator: "=",
                  value: local!selectedStatus,
                  applyWhen: a!isNotNullOrEmpty(local!selectedStatus)
                )
              }
            )
          ),
          columns: {
            a!gridColumn(
              label: "Case",
              sortField: recordType!CMG Case.fields.caseNumber,
              value: a!linkField(
                links: a!recordLink(
                  label: fv!row[recordType!CMG Case.fields.caseNumber],
                  recordType: recordType!CMG Case,
                  identifier: fv!identifier
                )
              )
            ),
            a!gridColumn(label: "Oggetto", value: fv!row[recordType!CMG Case.fields.subject]),
            a!gridColumn(
              label: "Cliente",
              value: fv!row[recordType!CMG Case.relationships.customer.fields.name]
            ),
            a!gridColumn(
              label: "Stato",
              sortField: recordType!CMG Case.fields.status,
              value: rule!CMG_GetStatusLabel(fv!row[recordType!CMG Case.fields.status])
            ),
            a!gridColumn(
              label: "Priorità",
              sortField: recordType!CMG Case.fields.priority,
              value: a!tagField(
                labelPosition: "COLLAPSED",
                tags: a!tagItem(
                  text: rule!CMG_FormatValue(fv!row[recordType!CMG Case.fields.priority]),
                  backgroundColor: rule!CMG_GetPriorityColor(fv!row[recordType!CMG Case.fields.priority])
                )
              )
            ),
            a!gridColumn(
              label: "Team",
              value: fv!row[recordType!CMG Case.relationships.team.fields.name]
            ),
            a!gridColumn(
              label: "Owner",
              value: a!linkField(
                links: a!userRecordLink(user: fv!row[recordType!CMG Case.fields.owner]),
                showWhen: a!isNotNullOrEmpty(fv!row[recordType!CMG Case.fields.owner])
              )
            ),
            a!gridColumn(
              label: "Scadenza",
              sortField: recordType!CMG Case.fields.dueAt,
              value: a!richTextDisplayField(
                value: a!richTextItem(
                  text: text(fv!row[recordType!CMG Case.fields.dueAt], "dd/mm hh:mm"),
                  color: if(fv!row[recordType!CMG Case.fields.dueAt] < now(), "NEGATIVE", "STANDARD")
                )
              )
            )
          },
          initialSorts: a!sortInfo(field: recordType!CMG Case.fields.dueAt, ascending: true),
          pageSize: 20,
          refreshAfter: "RECORD_ACTION"
        )
      }
    )
  }
)
