//-----------------------------------------------------------------------//
// Geração de arquivo texto.
//-----------------------------------------------------------------------//

#Include "PROTHEUS.CH"
#Include "RWMAKE.CH"

User Function GeraTXT()

Local oDlg, oBtnOk, oBtnCancel

Define MSDialog oDlg Title OemToAnsi("Geração de Arquivo Texto") From 0,0 To 160,380 Pixel

@05,10 To 50,180 Pixel

@15,20 Say "Este programa ira gerar um arquivo texto com registros dos" Pixel Of oDlg
@25,20 Say "arquivos SZ1 e SZ2."                                        Pixel Of oDlg

@oDlg:nHeight/2-35,oDlg:nClientWidth/2-80 Button oBtnOk     Prompt "&Ok"       Size 30,15 Pixel Action (u_OkGeraTXT(), Close(oDlg)) Of oDlg
@oDlg:nHeight/2-35,oDlg:nClientWidth/2-45 Button oBtnCancel Prompt "&Cancelar" Size 30,15 Pixel Action oDlg:End() Cancel Of oDlg

Activate MSDialog oDlg Centered

Return Nil

//-----------------------------------------------------------------------//
User Function OkGeraTXT()

Local cArq
Local nHdl
Local cLinha

// Se for especificado o drive no caminho do arquivo, sera criado no
// Client, caso contrario sera criado no Server, no diretorio RooPath.
cArq := "\TXT\CONTAS.TXT"
nHdl := FCreate(cArq)

If nHdl == -1
    MsgAlert("O arquivo " + cArq + " nao pode ser criado!", "Atencao!")
    Return
Endif

dbSelectArea("SZ1")
dbOrderNickName("NOME")
dbGoTop()

While !SZ1->(EOF())

   /*
   SZ1NNNNNNNNNNNNNNNNNNNN99999999999            Conta.....: Arq(3), Nome(20), Saldo(11), Espaços(9)
   SZ299/99/99THHHHHHHHHHHHHHHHHHHH99999999999   Transacoes: Arq(3), Data(8), Tipo(1), Historico(20), Valor(11)
   */

   // Conta.
   cLinha := "SZ1" + SZ1->Z1_Nome + StrZero(Int(SZ1->Z1_Saldo*100), 11) + Space(9) + Chr(13) + Chr(10)

   If FWrite(nHdl, cLinha, Len(cLinha)) <> Len(cLinha)
      If !MsgAlert("Ocorreu um erro na gravacao do arquivo.", "Atencao!")
         Exit
      EndIf
   EndIf

   dbSelectArea("SZ2")
   dbOrderNickName("NOME_NR_IT")            // Filial + Nome + Numero + Item.
   dbSeek(xFilial("SZ2") + SZ1->Z1_Nome)

   While SZ2->Z2_Nome == SZ1->Z1_Nome

      // Transacoes.
      cLinha := "SZ2" + DtoC(SZ2->Z2_Data) + SZ2->Z2_Tipo + SZ2->Z2_Hist + StrZero(Int(SZ2->Z2_Valor*100), 11) + Chr(13) + Chr(10)

      If FWrite(nHdl, cLinha, Len(cLinha)) <> Len(cLinha)
         If !MsgAlert("Ocorreu um erro na gravacao do arquivo.", "Atencao!")
            Exit
         EndIf
      EndIf

      dbSelectArea("SZ2")
      SZ2->(dbSkip())

   End

   dbSelectArea("SZ1")
   SZ1->(dbSkip())

End

FClose(nHdl)

MsgInfo("Arquivo TXT gerado!")

Return

//-----------------------------------------------------------------------//
// Leitura de arquivo texto.
//-----------------------------------------------------------------------//
User Function LeTXT()

Local oDlg, oFont
Local cArq
Local nHdl
Local nTamArq
Local nTamLin
Local nBytesLidos
Local cLinha
Local cTexto
Local cEOL

// Se for especificado o drive no caminha do arquivo, sera procurado no
// Client, caso contrario sera procurado no Server, no diretorio RooPath.
cArq := "\TXT\CONTAS.TXT"

// Veja no arquivo FILEIO.CH os codigos de acesso e compartilhamento.
nHdl := FOpen(cArq, 64)

// Caracteres de final de linha.
cEOL := Chr(13)+Chr(10)

If nHdl == -1
   MsgAlert("O arquivo de nome " + cArq + " nao pode ser aberto!", "Atencao!")
   Return
EndIf

nTamArq := FSeek(nHdl, 0, 2)                  // Posiciona o ponteiro no final do arquivo.
FSeek(nHdl, 0, 0)                             // Volta o ponteiro para o inicio do arquivo.
nTamLin     := 43 + Len(cEOL)                 // Tamanho da linha = 43 + 2 ref. ao Chr(13)+Chr(10)
cLinha      := Space(nTamLin)                 // Variavel que contera a linha lida.
nBytesLidos := FRead(nHdl, @cLinha, nTamLin)  // Le uma linha.
cTexto      := ""

While nBytesLidos >= nTamLin

   /*
   SZ1NNNNNNNNNNNNNNNNNNNN99999999999            Conta.....: Arq(3), Nome(20), Saldo(11), Espaços(9)
   SZ299/99/99THHHHHHHHHHHHHHHHHHHH99999999999   Transacoes: Arq(3), Data(8), Tipo(1), Historico(20), Valor(11)
   */

   If Left(cLinha, 3) == "SZ1"                // Conta.

      cTexto += "=================================================="                          + cEOL
      cTexto += "Nome:  " + Substr(cLinha, 04, 20)                                            + cEOL
      cTexto += "Saldo: " + Transform(Val(Substr(cLinha, 24, 11)) / 100, "@E 999,999,999.99") + cEOL
      cTexto += "--------------------------------------------------"                          + cEOL

    Else                                      // Transacoes.

      cTexto += "Data:  " + Substr(cLinha, 04, 08)                                            + cEOL
      cTexto += "Tipo:  " + Substr(cLinha, 12, 01)                                            + cEOL
      cTexto += "Hist:  " + Substr(cLinha, 13, 20)                                            + cEOL
      cTexto += "Valor: " + Transform(Val(Substr(cLinha, 33, 11)) / 100, "@E 999,999,999.99") + cEOL + cEOL

   EndIf

   nBytesLidos := FRead(nHdl, @cLinha, nTamLin)

End

FClose(nHdl)

// Mostra na tela.

Define Font oFont Name "Courier" Size 0,-12

Define MSDialog oDlg Title "TXT da Conta" From 0,0 To 400,500 Pixel

@10,10 Get cTexto Multiline Size 230,180 Pixel Font oFont Of oDlg

Activate MSDialog oDlg Centered

Return Nil
