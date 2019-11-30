#Include "RWMAKE.CH"

User Function TranM1()

Private cNomAnt, cTipAnt, nValAnt
Private cAlias    := "SZ2"
Private aRotina   := {}
Private lRefresh  := .T.
Private cCadastro := "Transação de Depósito ou Saque"

AAdd( aRotina, {"Pesquisar" , "AxPesqui", 0, 1} )
AAdd( aRotina, {"Visualizar", "AxVisual", 0, 2} )
AAdd( aRotina, {"Incluir"   , "u_Inclui", 0, 3} )
AAdd( aRotina, {"Alterar"   , "u_Altera", 0, 4} )
AAdd( aRotina, {"Excluir"   , "u_Deleta", 0, 5} )

dbSelectArea(cAlias)
dbOrderNickName("NR_IT")

mBrowse(,,,,cAlias)

Return Nil

//----------------------------------------------------------------------------//
User Function Inclui(cAlias, nRegistro, nOpcao)

Local nConfirmou

nConfirmou := AxInclui(cAlias, nRegistro, nOpcao)

If nConfirmou == 1      // Confirmou a inclusao.

   Begin Transaction

      // Atualiza o saldo.
      dbSelectArea("SZ1")
      dbOrderNickName("NOME")
      dbSeek(xFilial("SZ1") + SZ2->Z2_Nome)
      RecLock("SZ1", .F.)
      If SZ2->Z2_Tipo == "D"
         SZ1->Z1_Saldo := SZ1->Z1_Saldo + SZ2->Z2_Valor
       Else
         SZ1->Z1_Saldo := SZ1->Z1_Saldo - SZ2->Z2_Valor
      EndIf
      MSUnLock()

      If SZ1->Z1_Saldo < 0
         If ExistBlock("WFSalNeg")     // Ponto de Entrada.
            // O saldo ficou negativo. Envia um WorkFlow para o aprovador.
            // A resposta do aprovador (SIM ou NAO) sera gravada no campo Z2_Aprov.
            u_WFSalNeg(SZ1->Z1_Nome, SZ1->Z1_EMail, SZ2->Z2_Numero, SZ2->Z2_Item, SZ2->Z2_Data, SZ2->Z2_Hist, SZ2->Z2_Valor, SZ1->Z1_Saldo)
         EndIf
      EndIf

      // Confirma o numero obtido por GetSXENum() no inic.-padrao do campo Z2_NUMERO.
      ConfirmSX8()

   End Transaction

EndIf

Return

//----------------------------------------------------------------------------//
User Function Altera(cAlias, nRegistro, nOpcao)

Local nConfirmou

cNomAnt := SZ2->Z2_Nome
cTipAnt := SZ2->Z2_Tipo
nValAnt := SZ2->Z2_Valor

nConfirmou := AxAltera(cAlias, nRegistro, nOpcao)

If nConfirmou == 1      // Confirmou a alteracao.

   Begin Transaction

      If (SZ2->Z2_Nome  <> cNomAnt .Or.;
          SZ2->Z2_Tipo  <> cTipAnt .Or.;
          SZ2->Z2_Valor <> nValAnt)

         // Desatualiza o movimento anterior.
         dbSelectArea("SZ1")
         dbOrderNickName("NOME")
         dbSeek(xFilial("SZ1") + cNomAnt)
         RecLock("SZ1", .F.)
         If cTipAnt == "D"
            SZ1->Z1_Saldo := SZ1->Z1_Saldo - nValAnt
          Else
            SZ1->Z1_Saldo := SZ1->Z1_Saldo + nValAnt
         EndIf
         MSUnLock()

         // Atualiza o novo movimento.
         dbSelectArea("SZ1")
         dbOrderNickName("NOME")
         dbSeek(xFilial("SZ1") + SZ2->Z2_Nome)
         RecLock("SZ1", .F.)
         If SZ2->Z2_Tipo == "D"
            SZ1->Z1_Saldo := SZ1->Z1_Saldo + SZ2->Z2_Valor
          Else
            SZ1->Z1_Saldo := SZ1->Z1_Saldo - SZ2->Z2_Valor
         EndIf
         MSUnLock()

      EndIf

   End Transaction

EndIf

Return

//----------------------------------------------------------------------------//
User Function Deleta(cAlias, nRegistro, nOpcao)

Local nConfirmou

// Chama a rotina de visualizacao para mostrar o movimento a ser excluido.
nConfirmou := AxVisual(cAlias, nRegistro, 2)

If nConfirmou == 1      // Confirmou a exclusao.

   Begin Transaction

      // Desatualiza o saldo.
      dbSelectArea("SZ1")
      dbOrderNickName("NOME")
      dbSeek(xFilial() + SZ2->Z2_Nome)
      RecLock("SZ1", .F.)
      If SZ2->Z2_Tipo == "D"
         SZ1->Z1_Saldo := SZ1->Z1_Saldo - SZ2->Z2_Valor
       Else
         SZ1->Z1_Saldo := SZ1->Z1_Saldo + SZ2->Z2_Valor
      EndIf
      MSUnLock()
		
      // Exclui o movimento.
      dbSelectArea(cAlias)
      RecLock(cAlias, .F.)
      dbDelete()
      MSUnLock()

   End Transaction

EndIf

Return
