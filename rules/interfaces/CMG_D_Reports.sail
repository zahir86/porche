/*
 * CMG_D_Reports  –  pagina "Report" del site (management)
 * Rule input: nessuno
 * Domanda: "Il processo è buono?" – trend, tempi per fase, rispetto SLA.
 * Trend da CMG_KpiSnapshot (scritto ogni notte da CMG Measure KPIs),
 * tempi per fase da CMG_StatusTransition.
 */
a!localVariables(
  local!days: 30,
  local!fromDate: today() - local!days,
  {
    a!dropdownField(
      label: "Periodo",
      labelPosition: "JUSTIFIED",
      choiceLabels: { "Ultimi 30 giorni", "Ultimi 90 giorni", "Ultimo anno" },
      choiceValues: { 30, 90, 365 },
      value: local!days,
      saveInto: local!days
    ),
    a!sectionLayout(
      label: "Case aperti, creati e chiusi",
      contents: a!lineChartField(
        data: a!recordData(
          recordType: recordType!CMG Kpi Snapshot,
          filters: a!queryFilter(
            field: recordType!CMG Kpi Snapshot.fields.snapshotDate,
            operator: ">=",
            value: local!fromDate
          )
        ),
        config: a!lineChartConfig(
          primaryGrouping: a!grouping(
            field: recordType!CMG Kpi Snapshot.fields.snapshotDate,
            alias: "date",
            interval: if(local!days > 90, "WEEK_TEXT", "DATE_TEXT")
          ),
          measures: {
            a!measure(label: "Aperti", function: "MAX", field: recordType!CMG Kpi Snapshot.fields.numOpen, alias: "open"),
            a!measure(label: "Creati", function: "SUM", field: recordType!CMG Kpi Snapshot.fields.numCreated, alias: "created"),
            a!measure(label: "Chiusi", function: "SUM", field: recordType!CMG Kpi Snapshot.fields.numCompleted, alias: "completed")
          }
        ),
        height: "MEDIUM"
      )
    ),
    a!columnsLayout(
      columns: {
        a!columnLayout(
          contents: a!sectionLayout(
            label: "Ore medie per fase",
            contents: a!barChartField(
              data: a!recordData(
                recordType: recordType!CMG Status Transition,
                filters: {
                  a!queryFilter(
                    field: recordType!CMG Status Transition.fields.enteredAt,
                    operator: ">=",
                    value: todatetime(local!fromDate)
                  ),
                  a!queryFilter(
                    field: recordType!CMG Status Transition.fields.exitedAt,
                    operator: "not null"
                  )
                }
              ),
              config: a!barChartConfig(
                primaryGrouping: a!grouping(
                  field: recordType!CMG Status Transition.fields.toStatus,
                  alias: "status"
                ),
                measures: a!measure(
                  label: "Ore medie",
                  function: "AVG",
                  field: recordType!CMG Status Transition.fields.durationHours,
                  alias: "avgHours"
                )
              ),
              showLegend: false
            )
          )
        ),
        a!columnLayout(
          contents: a!sectionLayout(
            label: "Rispetto SLA dei case chiusi",
            contents: a!pieChartField(
              data: a!recordData(
                recordType: recordType!CMG Case,
                filters: {
                  a!queryFilter(field: recordType!CMG Case.fields.isCompleted, operator: "=", value: true),
                  a!queryFilter(
                    field: recordType!CMG Case.fields.completedAt,
                    operator: ">=",
                    value: todatetime(local!fromDate)
                  )
                }
              ),
              config: a!pieChartConfig(
                primaryGrouping: a!grouping(field: recordType!CMG Case.fields.slaCompliance, alias: "sla"),
                measures: a!measure(function: "COUNT", field: recordType!CMG Case.fields.id, alias: "count")
              ),
              style: "DONUT",
              seriesLabelStyle: "LEGEND"
            )
          )
        )
      }
    ),
    a!sectionLayout(
      label: "Case per categoria e canale",
      contents: a!columnChartField(
        data: a!recordData(
          recordType: recordType!CMG Case,
          filters: a!queryFilter(
            field: recordType!CMG Case.fields.createdAt,
            operator: ">=",
            value: todatetime(local!fromDate)
          )
        ),
        config: a!columnChartConfig(
          primaryGrouping: a!grouping(
            field: recordType!CMG Case.relationships.category.fields.name,
            alias: "category"
          ),
          secondaryGrouping: a!grouping(field: recordType!CMG Case.fields.channel, alias: "channel"),
          measures: a!measure(function: "COUNT", field: recordType!CMG Case.fields.id, alias: "count")
        ),
        stacking: "NORMAL"
      )
    )
  }
)
