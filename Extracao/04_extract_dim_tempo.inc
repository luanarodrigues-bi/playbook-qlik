// =============================================================================
// 04_extract_dim_tempo.inc
// Geração: Dimensão Tempo (calendário completo via script Qlik)
// Sem conexão com banco — gerada internamente no Qlik
// Campos: ID_Data, Data, Dia, Mes, Nome_Mes, Trimestre, Semestre,
//         Ano, Dia_Semana, Flag_Fim_Semana
// =============================================================================

$(Must_Include=[lib://DataFiles/Extracao/config/variaveis.inc]);

// -----------------------------------------------------------------------------
// Geração do calendário pelo período definido em variaveis.inc (24 meses)
// ID_Data no formato YYYYMMDD (ex: 20240315 = 8 dígitos, inteiro)
// -----------------------------------------------------------------------------
dim_tempo:
LOAD
    Date($(vDataInicio) + IterNo() - 1)                                         AS Data,
    Num(Date($(vDataInicio) + IterNo() - 1), 'YYYYMMDD')                        AS ID_Data,
    Day($(vDataInicio) + IterNo() - 1)                                          AS Dia,
    Month($(vDataInicio) + IterNo() - 1)                                        AS Mes,
    MonthName($(vDataInicio) + IterNo() - 1)                                    AS Nome_Mes,
    Ceil(Month($(vDataInicio) + IterNo() - 1) / 3)                              AS Trimestre,
    Ceil(Month($(vDataInicio) + IterNo() - 1) / 6)                              AS Semestre,
    Year($(vDataInicio) + IterNo() - 1)                                         AS Ano,
    WeekDay($(vDataInicio) + IterNo() - 1)                                      AS Dia_Semana,
    If(WeekDay($(vDataInicio) + IterNo() - 1) >= 5, -1, 0)                      AS Flag_Fim_Semana
AUTOGENERATE 1
WHILE ($(vDataInicio) + IterNo() - 1) <= $(vDataFim);

// -----------------------------------------------------------------------------
// Persistência em QVD
// -----------------------------------------------------------------------------
STORE dim_tempo INTO [$(vPathQVD)dim_tempo.qvd] (qvd);
DROP TABLE dim_tempo;
