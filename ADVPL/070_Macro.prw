//----------------------------------------------------------------------------------------------------------------//
// Demonstracao de macro.
//----------------------------------------------------------------------------------------------------------------//

User Function TstMacro()

Local cCampo
Local cFormula


dbSelectArea("SA1")

cCampo := "A1_Nome"

MsgAlert(cCampo)
MsgAlert(&cCampo)


cFormula := "2*2"

MsgAlert(cFormula)
MsgAlert(&cFormula)
             

Return Nil

//---------------------------------------------------------------------//
User Function TstMacr1()

Local cOla
Local cVar
Local cVar1

cOla := "Ola Pessoal!"
cVar := "cOla"

cVar1 := &cVar       // Nao funciona. Da erro de "variavel nao existe".
                     // Variavel cOla NAO pode ser LOCAL.

//MsgAlert(&cVar)  // Assim tambem nao funciona.
MsgAlert(cVar1)

Return                

//---------------------------------------------------------------------//
// Uso de macro para executar uma formula cadastrada no SM4.
// Para testar: cadastrar a formula: SB1->B1_PRV1 * 1.2
//---------------------------------------------------------------------//
User Function TstMacr2()

Local cFormula

dbSelectArea("SM4")
dbSeek(xFilial("SM4") + "001")
cFormula := SM4->M4_Formula

dbSelectArea("SB1")
dbGoTop()
While !SB1->(Eof())
   RecLock("SB1")
   SB1->B1_Prv1 := &cFormula
   MSUnlock()
   SB1->(dbSkip())
End

MsgInfo("Terminou!")

Return
