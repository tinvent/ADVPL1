#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"

//----------------------------------------------------------------------------//
// Geracao de um arquivo XML.
//----------------------------------------------------------------------------//
User Function GeraXML()

Local cEstrutura
Local nXMLStatus
Local oXML
Local cXML
Local nCli
Local nTran

// Cria a estrutura do XML.
cEstrutura := "<?xml version='1.0'?>"
cEstrutura += "<Contas>"
cEstrutura +=    "<Conta>"
cEstrutura +=       "<Nome></Nome>"
cEstrutura +=       "<Saldo></Saldo>"
cEstrutura +=       "<Transacao>"
cEstrutura +=          "<Data></Data>"
cEstrutura +=          "<Tipo></Tipo>"
cEstrutura +=          "<Hist></Hist>"
cEstrutura +=          "<Valor></Valor>"
cEstrutura +=       "</Transacao>"
cEstrutura +=    "</Conta>"
cEstrutura += "</Contas>"

// Cria o objeto XML, definindo a Conta e a Transacao como arrays.
CREATE oXML XMLSTRING cEstrutura SETASARRAY _Contas:_Conta, _Contas:_Conta:_Transacao

nXMLStatus := XMLError()

If nXMLStatus == XERROR_SUCCESS

   // Se nao houver nenhum erro na criação do objeto, calcula o total de livros
   // e percorre os elementos do array para criar os nodes dos livros no XML.

   dbSelectArea("SZ1")
   dbOrderNickName("NOME")
   dbGoTop()

   nCli := 1
   
   While !SZ1->(Eof())

      If nCli > 1
         // Apenas acrescenta nodes novos caso já tenha realizado a primeira volta
         // do loop, que irá atribuir os valores da primeira Conta ao node já existente no objeto Xml.
         ADDNODE oXML:_Contas:_Conta NODE "_Conta" ON oXML
      EndIf

      // Atriblui os dados da Conta ao objeto Xml.
      oXML:_Contas:_Conta[nCli]:_Nome:TEXT  := SZ1->Z1_Nome
      oXML:_Contas:_Conta[nCli]:_Saldo:TEXT := SZ1->Z1_Saldo

      dbSelectArea("SZ2")
      dbOrderNickName("NOME_NR_IT")         // Filial + Nome + Numero + Item.
      dbSeek(xFilial("SZ2") + SZ1->Z1_Nome)

      nTran := 1

      While SZ2->Z2_Nome == SZ1->Z1_Nome

         If nTran > 1
            ADDNODE oXML:_Contas:_Conta[nCli]:_Transacao NODE "_Transacao" ON oXML
         EndIf

         oXML:_Contas:_Conta[nCli]:_Transacao[nTran]:_Data:TEXT  := SZ2->Z2_Data
         oXML:_Contas:_Conta[nCli]:_Transacao[nTran]:_Tipo:TEXT  := SZ2->Z2_Tipo
         oXML:_Contas:_Conta[nCli]:_Transacao[nTran]:_Hist:TEXT  := SZ2->Z2_Hist
         oXML:_Contas:_Conta[nCli]:_Transacao[nTran]:_Valor:TEXT := SZ2->Z2_Valor

         dbSelectArea("SZ2")
         SZ2->(dbSkip())

         nTran++

      End

      dbSelectArea("SZ1")
      SZ1->(dbSkip())
      
      nCli++

   End

   // Gera o XML para um string.
   // SAVE oXML XMLSTRING cXML
   // MsgStop(cXML)

   // Gera o XML para um arquivo.
   SAVE oXML XMLFILE "\TXT\CONTAS.XML"
   MsgInfo("XML gerado: " + LTrim(Str(nCli-1)) + " Contas")

 Else

   MsgStop("Erro ("+Str(nXMLStatus,3)+") na criação do XML.")

EndIf

////////////////////////////////////////////////////////////////////////////////
// Exercicio: incluir o EMail (Z1_EMail) no node Conta.                       //
//            incluir o Numero e Item (Z2_Numero, Z2_Item) no node Transacao. //
////////////////////////////////////////////////////////////////////////////////

Return 

//----------------------------------------------------------------------------//
// Leitura de um arquivo XML.
//----------------------------------------------------------------------------//
User Function LeXML()

Local oDlg, oFont
Local cError   := ""
Local cWarning := ""
Local oXML
Local cArq
Local nCli
Local nTran
Local cTexto   := ""
	        
// A partir do rootpath do ambiente.
cArq := "\TXT\CONTAS.XML"
	
// Obtem o objeto XML.
oXML := XmlParserFile(cArq, "_", @cError, @cWarning)

If Empty(cError + cWarning)  // Nao ocorreu erro na abertura do arq. XML.

   // Le cada node da Conta.
   For nCli := 1 To Len(oXML:_Contas:_Conta)

       cTexto += "Nome:  " + oXML:_Contas:_Conta[nCli]:_Nome:TEXT  + Chr(13) + Chr(10)
       cTexto += "Saldo: " + oXML:_Contas:_Conta[nCli]:_Saldo:TEXT + Chr(13) + Chr(10)

       cTexto += "--------------------------------------------------" + Chr(13) + Chr(10)

       // De cada Conta, le os nodes de Transacao.
       If ValType(oXML:_Contas:_Conta[nCli]:_Transacao) == "A"

          // Se tiver mais que 1 transacao, o nodo Transacao sera um array.
          // Se tiver so uma unica transacao, o nodo Transacao sera um nodo comum.

          For nTran := 1 To Len(oXML:_Contas:_Conta[nCli]:_Transacao)

              cTexto += "Data:   " + oXML:_Contas:_Conta[nCli]:_Transacao[nTran]:_Data:TEXT  + Chr(13) + Chr(10)
              cTexto += "Tipo:   " + oXML:_Contas:_Conta[nCli]:_Transacao[nTran]:_Tipo:TEXT  + Chr(13) + Chr(10)
              cTexto += "Hist:   " + oXML:_Contas:_Conta[nCli]:_Transacao[nTran]:_Hist:TEXT  + Chr(13) + Chr(10)
              cTexto += "Valor:  " + oXML:_Contas:_Conta[nCli]:_Transacao[nTran]:_Valor:TEXT + Chr(13) + Chr(10) + Chr(13) + Chr(10)

          Next

        Else

          cTexto += "Data:   " + oXML:_Contas:_Conta[nCli]:_Transacao:_Data:TEXT  + Chr(13) + Chr(10)
          cTexto += "Tipo:   " + oXML:_Contas:_Conta[nCli]:_Transacao:_Tipo:TEXT  + Chr(13) + Chr(10)
          cTexto += "Hist:   " + oXML:_Contas:_Conta[nCli]:_Transacao:_Hist:TEXT  + Chr(13) + Chr(10)
          cTexto += "Valor:  " + oXML:_Contas:_Conta[nCli]:_Transacao:_Valor:TEXT + Chr(13) + Chr(10) + Chr(13) + Chr(10)

       EndIf

       cTexto += "==================================================" + Chr(13) + Chr(10)

   Next

   // Mostra na tela.

   Define Font oFont Name "Courier" Size 0,-12

   Define MSDialog oDlg Title "XML da Conta" From 0,0 To 400,500 Pixel

   @10,10 Get cTexto Multiline Size 230,180 Pixel Font oFont Of oDlg

   Activate MSDialog oDlg Centered

 Else    // Erro na abertura do arq. XML.

   MsgAlert(cError + cWarning)

EndIf

Return
