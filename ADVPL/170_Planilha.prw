//----------------------------------------------------------------------------//
// Integracao com o Excel:
//
// Esta funcao deve ser chamada a partir da planilha Excel. O dados contidos
// no array serao distribuidos nas celulas.
//
// Na planilha, digitar na celula A1 o comando:
// =MSGetArray(A1,Siga("U_PLANMOV"))
//
// Ou, escrever a seguinte macro e associa-la a um botao:
//
// Sub Atualiza()
//   
//   Range("A1").FormulaR1C1 = "=MSGetArray(RC,Siga(""U_PLANMOV""))"
//
//  ou
//
//   aMovimentos = MSExecArray(siga("U_PLANMOV"))
//
// End Sub
//
//----------------------------------------------------------------------------//

User Function PlanMOV()

Local aMovim := {}

dbSelectArea("SZ2")
dbOrderNickName("NOME_NR_IT")     // Filial + Nome + Nro.Trans. + Item
dbGoTop()

While !SZ2->(Eof())
   AAdd(aMovim, {SZ2->Z2_Nome, SZ2->Z2_Numero, SZ2->Z2_Item, SZ2->Z2_Data, SZ2->Z2_Tipo, SZ2->Z2_Hist, SZ2->Z2_Valor, SZ2->Z2_Aprov})
   SZ2->(dbSkip())
End

Return aMovim

//----------------------------------------------------------------------------//
User Function PlanCAD()

Local aCad := {}

dbSelectArea("SZ1")
dbOrderNickName("NOME")
dbGoTop()

While !SZ1->(Eof())
   AAdd(aCad, {SZ1->Z1_Nome, SZ1->Z1_EMail, SZ1->Z1_Saldo})
   SZ1->(dbSkip())
End

Return aCad
