//----------------------------------------------------------------------------------------------------------------// 
// Demonstracao da construcao de telas e seus componentes.
//----------------------------------------------------------------------------------------------------------------// 

#Include "PROTHEUS.CH"

User Function Tela()

Local oDlg
Local oBtnOk
Local oBtnCancel
Local aButtons
Local oSayConj
Local oGetConj
Local oSayCivil
Local oSaySal
Local oRadio, nRadio
Local oChk1, lChk1
Local oChk2, lChk2
Local cNome    := Space(20)
Local cConjuge := Space(20)
Local cCivil   := Space(1)
Local cEndRes  := Space(30)
Local cTelRes  := Space(11)
Local cEndCom  := Space(30)
Local cTelCom  := Space(11)
Local cEMail   := Space(50)
Local oFont
Local oFolder

Define Font oFont Name "Arial" Size 0,-12 Bold

aButtons := {{"BMPPERG", {||MsgInfo("Pergunte")}, "Pergunte"},;
             {"BMPCALEN", {||MsgInfo("Calendario")}, "Calendario"}}
             
Define MSDialog oDlg Title "Cadastro" From 0,0 To 425,450 Pixel

@20,10 Say "Nome:" Pixel Of oDlg
@20,50 Get cNome Size 50,10 Pixel Of oDlg

@40,10 Say "Estado Civil:" Pixel Of oDlg
@40,50 Get cCivil Size 10,10 Picture "@!" Valid cCivil$"S|C|D" .And. u_VldCivil(cCivil, oSayConj, oGetConj, oSayCivil) Pixel Of oDlg

@40,80 Say oSayCivil Var "" Size 20,10 Pixel Of oDlg
  
@60,10 Say oSayConj Var "Cônjuge:" Pixel Of oDlg
@60,50 Get oGetConj Var cConjuge Size 50,10 Pixel Of oDlg

@80,10 Say "Salário:" Pixel Font oFont Of oDlg

@80,40 Radio oRadio Var nRadio Items "1000", "2000", "3000" Size 50,9 On Change u_Salario(nRadio, oSaySal) Pixel Of oDlg

@80,80 Say oSaySal Var "" Size 20,10 Pixel Of oDlg

@105,10 To 122,220 Pixel Of oDlg
@110,15 CheckBox oChk1 Var lChk1 Prompt "Check Box 1" Size 60,9 On Change MsgAlert(If(lChk1,"Marcado","Desmarcado")) Pixel Of oDlg
@110,75 CheckBox oChk2 Var lChk2 Prompt "Check Box 2" Size 60,9 On Change MsgAlert(If(lChk2,"Marcado","Desmarcado")) Pixel Of oDlg

@127,10 Folder oFolder Prompts "Residencial","Comercial" Size 210,65 Pixel Of oDlg
oFolder:aDialogs[2]:oFont := oFont
//oFolder:bChange := {||MsgAlert("Mudando de pasta")}

@05,10 Say "Endereço:" Pixel                                 Of oFolder:aDialogs[1]
@05,50 Get cEndRes Size 100,10 Pixel                         Of oFolder:aDialogs[1]
@20,10 Say "Telefone:" Pixel                                 Of oFolder:aDialogs[1]
@20,50 Get cTelRes Picture "(999)9999-9999" Size 50,10 Pixel Of oFolder:aDialogs[1]

@05,10 Say "Endereço:" Pixel                                 Of oFolder:aDialogs[2]
@05,50 Get cEndCom Size 100,10 Pixel                         Of oFolder:aDialogs[2]
@20,10 Say "Telefone:" Pixel                                 Of oFolder:aDialogs[2]
@20,50 Get cTelCom Picture "(999)9999-9999" Size 50,10 Pixel Of oFolder:aDialogs[2]
@35,10 Say "E-Mail:" Pixel                                   Of oFolder:aDialogs[2]
@35,50 Get cEMail Size 100,10 Pixel                          Of oFolder:aDialogs[2]

@198,10 Say DtoC(Date()) + " - " + Time() Pixel Font oFont Color CLR_RED Of oDlg    // Tab.cores: COLORS.CH

@oDlg:nHeight/2-30,oDlg:nClientWidth/2-70 Button oBtnOk     Prompt "&Ok"       Size 30,15 Pixel Action u_Confirma()      Message "Clique aqui para Confirmar" Of oDlg
@oDlg:nHeight/2-30,oDlg:nClientWidth/2-35 Button oBtnCancel Prompt "&Cancelar" Size 30,15 Pixel Action oDlg:End() Cancel Message "Clique aqui para Cancelar"  Of oDlg

/* EnchoiceBar ( < oDlg > , < bOk > , < bCancel > , [ lMsgDel ] , [ aButtons ] , [ nRecno ] , [ cAlias ] ) --> Nil
     oDlg     Dialog onde irá criar a barra de botões
     bOk      Bloco de código a ser executado no botão Ok
     bCancel  Bloco de código a ser executado no botão Cancelar
     lMsgDel  Exibe dialog para confirmar a exclusão
     aButtons Array contendo botões adicionais. 
     nRecno   Registro a ser posicionado após a execução do botão Ok.
     cAlias   Alias do registro a ser posicionado após a execução do botão Ok. Se o parametro nRecno for informado, o cAlias passa ser obrigatório.
*/
Activate MSDialog oDlg Centered On Init EnchoiceBar(oDlg, {||u_OK(),oDlg:End()}, {||oDlg:End()},,aButtons) Valid MsgYesNo("Deseja mesmo fechar a janela?")

Return Nil

//----------------------------------------------------------------------------------------------------------------// 
User Function Confirma()

MsgAlert("Você clicou no botão OK!")

// Aqui poderia, por exemplo, gravar os dados num arquivo.

Return
                                                            
//----------------------------------------------------------------------------------------------------------------// 
User Function OK()

MsgAlert("Você clicou no botão OK da EnchoiceBar!")

// Aqui poderia, por exemplo, gravar os dados num arquivo.

Return
                                                            
//----------------------------------------------------------------------------------------------------------------// 
User Function VldCivil(cCivil, oSayConj, oGetConj, oSayCivil)

If cCivil <> "C"
   oSayConj:Hide()
   oGetConj:Hide()
   //oSayConj:Disable()
   //oGetConj:Disable()
 Else
   oSayConj:Show()
   oGetConj:Show()
   //oSayConj:Enable()
   //oGetConj:Enable()
EndIf

If       cCivil == "C"
         oSayCivil:SetText("Casado")
 ElseIf  cCivil == "S"
         oSayCivil:SetText("Solteiro")
 Else
         oSayCivil:SetText("Divorciado")
EndIf

Return .T.

//----------------------------------------------------------------------------------------------------------------// 
User Function Salario(nRadio, oSaySal) 

If nRadio == 1
   oSaySal:SetText("Hum mil")
 ElseIf nRadio == 2
   oSaySal:SetText("Dois mil")
 Else
   oSaySal:SetText("Tres mil")
EndIf

Return
