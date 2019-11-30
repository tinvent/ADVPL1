#Include "PROTHEUS.CH"

User Function TranM3()

Private aRotina := {}
Private cCadastro := "Transações Modelo 3"
Private cAlias1 := "SC5"                    // Alias da Enchoice.
Private cAlias2 := "SC6"                    // Alias da GetDados.

AAdd(aRotina, {"Pesquisar" , "AxPesqui"  , 0, 1})
AAdd(aRotina, {"Visualizar", "u_TM3Manut", 0, 2})
AAdd(aRotina, {"Incluir"   , "u_TM3Manut", 0, 3})
AAdd(aRotina, {"Alterar"   , "u_TM3Manut", 0, 4})
AAdd(aRotina, {"Excluir"   , "u_TM3Manut", 0, 5})
                                               
dbSelectArea(cAlias1)
debsetorder(1)//dbOrderNickName("NOME")
dbGoTop()

mBrowse(,,,,cAlias1)

Return Nil

//----------------------------------------------------------------------------------------------------------------//
// Modelo 3.
//----------------------------------------------------------------------------------------------------------------//

User Function TM3Manut(cAlias, nRecno, nOpc)

Local i        := 0
Local cLinOK   := "AllwaysTrue"
Local cTudoOK  := "u_TM3TudOK"
Local nOpcE    := nOpc
Local nOpcG    := nOpc
Local cFieldOK := "AllwaysTrue"
Local lVirtual := .T.
Local nLinhas  := 99
Local nFreeze  := 0
Local lRet     := .T.

Private aCols        := {}
Private aHeader      := {}
Private aCpoEnchoice := {}
Private aAltEnchoice := {}
Private aAlt         := {}      

// Cria variaveis de memoria dos campos da tabela Pai.
// 1o. parametro: Alias do arquivo --> é case-sensitive, ou seja precisa ser como está no Dic.Dados.
// 2o. parametro: .T.              --> cria variaveis em branco, preenchendo com o inicializador-padrao.
//                .F.              --> preenche com o conteudo dos campos.
RegToMemory(cAlias1, (nOpc==3))

// Cria variaveis de memoria dos campos da tabela Filho.
RegToMemory(cAlias2, (nOpc==3))

CriaHeader()

CriaCols(nOpc)

lRet := Modelo3(cCadastro, cAlias1, cAlias2, aCpoEnchoice, cLinOK, cTudoOK, nOpcE, nOpcG, cFieldOK, lVirtual, nLinhas, aAltEnchoice, nFreeze)

If lRet
   If      nOpc == 3
           If MsgYesNo("Confirma a gravação dos dados?", cCadastro)
              Processa({||GrvDados()}, cCadastro, "Gravando os dados, aguarde...")
           EndIf
    ElseIf nOpc == 4
           If MsgYesNo("Confirma a alteração dos dados?", cCadastro)
              Processa({||AltDados()}, cCadastro, "Alterando os dados, aguarde...")
           EndIf
    ElseIf nOpc == 5
           If MsgYesNo("Confirma a exclusão dos dados?", cCadastro)
              Processa({||ExcDados()}, cCadastro, "Excluindo os dados, aguarde...")
           EndIf

   EndIf
 Else
   RollBackSX8()
EndIf

Return Nil

//----------------------------------------------------------------------------------------------------------------//
Static Function CriaHeader()

aHeader      := {}
aCpoEnchoice := {}
aAltEnchoice := {}

// aHeader é igual ao do Modelo2.

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek(cAlias2)

While !SX3->(EOF()) .And. SX3->X3_Arquivo == cAlias2

   If X3Uso(SX3->X3_Usado)    .And.;                  // O Campo é usado.
      cNivel >= SX3->X3_Nivel //.And.;                  // Nivel do Usuario é maior que o Nivel do Campo.
      //Trim(SX3->X3_Campo) $ "Z2_NUMERO/Z2_ITEM/Z2_DATA/Z2_TIPO/Z2_HIST/Z2_VALOR"

      AAdd(aHeader, {Trim(SX3->X3_Titulo),;
                     SX3->X3_Campo       ,;
                     SX3->X3_Picture     ,;
                     SX3->X3_Tamanho     ,;
                     SX3->X3_Decimal     ,;
                     SX3->X3_Valid       ,;
                     SX3->X3_Usado       ,;
                     SX3->X3_Tipo        ,;
                     SX3->X3_Arquivo     ,;
                     SX3->X3_Context})

   EndIf

   SX3->(dbSkip())

End

// Campos da Enchoice.

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek(cAlias1)

While !SX3->(EOF()) .And. SX3->X3_Arquivo == cAlias1

   If X3Uso(SX3->X3_Usado)    .And.;                  // O Campo é usado.
      cNivel >= SX3->X3_Nivel                         // Nivel do Usuario é maior que o Nivel do Campo.

      // Campos da Enchoice.
      AAdd(aCpoEnchoice, X3_Campo)

      // Campos da Enchoice que podem ser editadas.
      // Se tiver algum campo que nao deve ser editado, nao incluir aqui.
      AAdd(aAltEnchoice, X3_Campo)

   EndIf

   SX3->(dbSkip())

End

Return Nil

//----------------------------------------------------------------------------------------------------------------//
Static Function CriaCols(nOpc)

Local nQtdCpo := 0
Local i       := 0
Local nCols   := 0

nQtdCpo := Len(aHeader)
aCols   := {}
aAlt    := {}

If nOpc == 3       // Inclusao.

   AAdd(aCols, Array(nQtdCpo+1))

   For i := 1 To nQtdCpo
       aCols[1][i] := CriaVar(aHeader[i][2])
   Next

   aCols[1][nQtdCpo+1] := .F.

 Else

   dbSelectArea(cAlias2)
   dbSETORDER(1)//OrderNickName("NOME_NR_IT")  // Z2_Filial + Z2_Nome + Z2_Numero + Z2_Item
   dbSeek(xFilial(cAlias2) + (cAlias1)->C5_NUM)

   While !EOF() .And. (cAlias2)->C6_Filial == xFilial(cAlias2) .And. (cAlias2)->C6_NUM== (cAlias1)->C5_NUM

      AAdd(aCols, Array(nQtdCpo+1))
      nCols++

      For i := 1 To nQtdCpo
          If aHeader[i][10] <> "V"
             aCols[nCols][i] := &(cAlias2 +"->" + aHeader[i][2]) //FieldGet(FieldPos(aHeader[i][2]))
           Else
             aCols[nCols][i] := CriaVar(aHeader[i][2], .T.)
          EndIf
      Next

      aCols[nCols][nQtdCpo+1] := .F.

      AAdd(aAlt, Recno())

      dbSelectArea(cAlias2)
      dbSkip()

   End

EndIf
 
Return Nil
 
//----------------------------------------------------------------------------------------------------------------//
Static Function GrvDados()

Local bCampo := {|nField| Field(nField)}
Local i      := 0
Local y      := 0
Local nItem  := 0

ProcRegua(Len(aCols) + FCount())

// Grava o registro da tabela Pai, obtendo o valor de cada campo
// a partir da var. de memoria correspondente.

dbSelectArea(cAlias1)
RecLock(cAlias1, .T.)
For i := 1 To FCount()
    IncProc()
    If "FILIAL" $ FieldName(i)
       FieldPut(i, xFilial(cAlias1))
     Else
       FieldPut(i, M->&(Eval(bCampo,i)))
    EndIf
Next
MSUnlock()

// Grava os registros da tabela Filho.

dbSelectArea(cAlias2)
dbSETORDER(1)//OrderNickName("NR_IT")

For i := 1 To Len(aCols)

    IncProc()

    If !aCols[i][Len(aHeader)+1]       // A linha nao esta deletada, logo, pode gravar.

       RecLock(cAlias2, .T.)

       SC6->C6_Filial := xFilial("SC6")
       SC6->C6_NUM   := SC5->C5_NUM

       For y := 1 To Len(aHeader)
           FieldPut(FieldPos(Trim(aHeader[y][2])), aCols[i][y])
       Next

       MSUnlock()

    EndIf

Next

Return Nil

//----------------------------------------------------------------------------------------------------------------//
Static Function AltDados()

Local i      := 0
Local y      := 0
Local nItem  := 0

ProcRegua(Len(aCols) + FCount())

dbSelectArea(cAlias1)
RecLock(cAlias1, .F.)

For i := 1 To FCount()
    IncProc()
    If "FILIAL" $ FieldName(i)
       FieldPut(i, xFilial(cAlias1))
     Else
       FieldPut(i, M->&(fieldname(i)))
    EndIf
Next
MSUnlock()
    
dbSelectArea(cAlias2)
DBSETORDER(1)//dbOrderNickName("NR_IT")

nItem := Len(aAlt) + 1

For i := 1 To Len(aCols)

    If i <= Len(aAlt)

       dbGoTo(aAlt[i])
       RecLock(cAlias2, .F.)

       If aCols[i][Len(aHeader)+1]
          dbDelete()
        Else
          For y := 1 To Len(aHeader)
              FieldPut(FieldPos(Trim(aHeader[y][2])), aCols[i][y])
          Next
       EndIf

       MSUnlock()

     Else

       If !aCols[i][Len(aHeader)+1]
          RecLock(cAlias2, .T.)
          For y := 1 To Len(aHeader)
              FieldPut(FieldPos(Trim(aHeader[y][2])), aCols[i][y])
          Next
          (cAlias2)->C6_Filial := xFilial(cAlias2)
          (cAlias2)->C6_NUM := (cAlias1)->C6_NUM
          (cAlias2)->C6_ITEM   := StrZero(nItem, 2, 0)
          MSUnlock()
          nItem++
       EndIf

    EndIf

Next

Return Nil

//----------------------------------------------------------------------------------------------------------------//
Static Function ExcDados()

ProcRegua(Len(aCols)+1)   // +1 é por causa da exclusao do arq. de cabeçalho.

dbSelectArea(cAlias2)
dbOrderNickName("NOME_NR_IT")
dbSeek(xFilial(cAlias2) + (cAlias1)->Z1_Nome)

While !EOF() .And. (cAlias2)->Z3_Filial == xFilial(cAlias2) .And. (cAlias2)->Z2_Nome == (cAlias1)->Z1_Nome
   IncProc()
   RecLock(cAlias2, .F.)
   dbDelete()
   MSUnlock()
   dbSkip()
End

dbSelectArea(cAlias1)
dbOrderNickName("NOME")
IndProc()
RecLock(cAlias1, .F.)
dbDelete()
MSUnlock()

Return Nil

//----------------------------------------------------------------------------------------------------------------//
User Function TM3TudOK()

Local lRet := .T.
Local i    := 0
Local nDel := 0

For i := 1 To Len(aCols)
    If aCols[i][Len(aHeader)+1]
       nDel++
    EndIf
Next

If nDel == Len(aCols)
   MsgInfo("Para excluir todos os itens, utilize a opção EXCLUIR", cCadastro)
   lRet := .F.
EndIf

// ***EXERCICIO*** Reescreva esta validaçao para nao aceitar produtos repetidos dentro da GetDados.

Return lRet
