///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | MarkBrowse.prw        											|//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | Funcao - u_MarkBrw()                                            |//
//|           | Fonte utilizado no curso oficina de programacao.                |//
//|           | Demonstra a utilizacao da funcao MarkBrow()                     |//
//+-----------------------------------------------------------------------------+//
//| MANUTENCAO DESDE SUA CRIACAO                                                |//
//+-----------------------------------------------------------------------------+//
//| DATA     | AUTOR                | DESCRICAO                                 |//
//+-----------------------------------------------------------------------------+//
//|          |                      |                                           |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////

/*
+----------------------------------------------------------------------------
| Parâmetros do MarkBrow()
+----------------------------------------------------------------------------
| MarkBrow( cAlias, cCampo, cCpo, aCampos, lInverte, cMarca, cCtrlM, uPar, 
|            cExpIni, cExpFim, cAval )
+----------------------------------------------------------------------------
| cAlias...: Alias do arquivo a ser exibido no browse 
| cCampo...: Campo do arquivo onde será feito o controle (gravação) da marca
| cCpo.....: Campo onde será feita a validação para marcação e exibição do bitmap de status
| aCampos..: Colunas a serem exibidas
| lInverte.: Inverte a marcação
| cMarca...: String a ser gravada no campo especificado para marcação
| cCtrlM...: Função a ser executada caso deseje marcar todos elementos
| uPar.....: Parâmetro reservado
| cExpIni..: Função que retorna o conteúdo inicial do filtro baseada na chave de índice selecionada
| cExpFim..: Função que retorna o conteúdo final do filtro baseada na chave de índice selecionada
| cAval....: Função a ser executada no duplo clique em um elemento no browse
+----------------------------------------------------------------------------
*/

#Include "Protheus.Ch"

User Function MarkBrw()
//+----------------------------------------------------------------------------
//| Atribuicao de variaveis
//+----------------------------------------------------------------------------
Local aArea   := {}
Local cFiltro := ""
Local cKey    := ""
Local cArq    := ""
Local nIndex  := 0
Local aSay    := {}
Local aButton := {}
Local nOpcao  := 0
Local cDesc1  := "Este programa tem o objetivo de transferir de almoxarifado os itens da nota"
Local cDesc2  := "fiscal de entrada, conforme parâmetros fornecido pelo usuário, sendo que o "
Local cDesc3  := "mesmo será efetuado com a data base do sistema."
Local aCpos   := {}
Local aCampos := {}
Local cMsg    := ""

Private aRotina     := {}
Private cMarca      := ""
Private cCadastro   := OemToAnsi("Transferˆncias de Almoxarifado")
Private cPerg       := "MARK01"
Private nTotal      := 0
Private cArquivo    := ""

//+----------------------------------------------------------------------------
//| Monta tela de interacao com usuario
//+----------------------------------------------------------------------------
aAdd(aSay,cDesc1)
aAdd(aSay,cDesc2)
aAdd(aSay,cDesc3)

aAdd(aButton, { 1,.T.,{|| nOpcao := 1, FechaBatch() }})
aAdd(aButton, { 2,.T.,{|| FechaBatch()              }})

//FormBatch(<cTitulo>,<aMensagem>,<aBotoes>,<bValid>,nAltura,nLargura)
FormBatch(cCadastro,aSay,aButton)

//+----------------------------------------------------------------------------
//| Se cancelar sair
//+----------------------------------------------------------------------------
If nOpcao <> 1
   Return Nil
Endif

//+--------------------------------------------------------+
//| Parametros utilizado no programa                       |
//+--------------------------------------------------------+
//| mv_par01 - Data Emissao de    ? 99/99/99               |
//| mv_par02 - Data Emissao ate   ? 99/99/99               |
//| mv_par03 - Forncedor de       ? 999999                 |
//| mv_par04 - Fornecedor ate     ? 999999                 |
//| mv_par05 - Filtrar            ? Todos/Manutenção       |
//+--------------------------------------------------------+
//+----------------------------------------------------------------------------
//| Cria as perguntas em SX1
//+----------------------------------------------------------------------------
CriaSX1()

//+----------------------------------------------------------------------------
//| Monta tela de paramentos para usuario, se cancelar sair
//+----------------------------------------------------------------------------
If !Pergunte(cPerg,.T.)
   Return Nil
Endif

//+----------------------------------------------------------------------------
//| Atribui as variaveis de funcionalidades
//+----------------------------------------------------------------------------
aAdd( aRotina ,{"Pesquisar" ,"AxPesqui()"   ,0,1})
aAdd( aRotina ,{"Transfere" ,"u_Transfere()",0,3})
aAdd( aRotina ,{"Legenda"   ,"u_Legenda()"  ,0,4})
             
//+----------------------------------------------------------------------------
//| Atribui as variaveis os campos que aparecerao no mBrowse()
//+----------------------------------------------------------------------------
aCpos := {"F1_OK","F1_DOC","F1_SERIE","F1_FORNECE","F1_LOJA","F1_EMISSAO","F1_VALBRUT","F1_TIPO"}

dbSelectArea("SX3")
dbSetOrder(2)
For nI := 1 To Len(aCpos)
   dbSeek(aCpos[nI])
   aAdd(aCampos,{X3_CAMPO,"",Iif(nI==1,"",Trim(X3_TITULO)),Trim(X3_PICTURE)})
Next

//+----------------------------------------------------------------------------
//| Monta o filtro especifico para MarkBrow()
//+----------------------------------------------------------------------------
dbSelectArea("SF1")
aArea := GetArea()
cKey  := IndexKey()
cFiltro := "Dtos(F1_EMISSAO) >= '"+Dtos(mv_par01)+"' .And. "
cFiltro += "Dtos(F1_EMISSAO) <= '"+Dtos(mv_par02)+"' .And. "
cFiltro += "F1_FORNECE >= '"+mv_par03+"' .And. "
cFiltro += "F1_FORNECE <= '"+mv_par04+"' "
If mv_par05 == 2
   cFiltro += ".And. Empty(F1_REMITO)"
Endif
cArq := CriaTrab( Nil, .F. )
IndRegua("SF1",cArq,cKey,,cFiltro)
nIndex := RetIndex("SF1")
nIndex := nIndex + 1
dbSelectArea("SF1")
#IFNDEF TOP
   dbSetIndex(cArq+OrdBagExt())
#ENDIF
dbSetOrder(nIndex)
dbGoTop()

//+----------------------------------------------------------------------------
//| Apresenta o MarkBrowse para o usuario
//+----------------------------------------------------------------------------
cMarca := GetMark()
MarkBrow("SF1","F1_OK","SF1->F1_REMITO",aCampos,,cMarca,,,,,"u_MarcaBox()")

//+----------------------------------------------------------------------------
//| Desfaz o indice e filtro temporario
//+----------------------------------------------------------------------------
dbSelectArea("SF1")
RetIndex("SF1")
Set Filter To
cArq += OrdBagExt()
FErase( cArq )
RestArea( aArea )
Return Nil

///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | MarkBrowse.prw       											|//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | Funcao - u_MarcaBox()                                           |//
//|           | Fonte utilizado no curso oficina de programacao.                |//
//|           | Marca ou desmarca o registro para processamento                 |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
User Function MarcaBox()
If IsMark("F1_OK",cMarca )
   RecLock("SF1",.F.)
   SF1->F1_OK := Space(2)
   MsUnLock()
Else
   If Empty(SF1->F1_REMITO)
      RecLock("SF1",.F.)
      SF1->F1_OK := cMarca
      MsUnLock()
   Endif
Endif
Return .T.

///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | MarkBrowse.prw       											|//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | Funcao - u_Transfere()                                          |//
//|           | Fonte utilizado no curso oficina de programacao.                |//
//|           | Transfere os registros marcados                                 |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
User Function Transfere()
Local cMsg   := "Nota fiscal marcada:"+Chr(10)+Chr(13)+"Pre/Número"+Chr(10)+Chr(13)
Local aNotas := {} 
Private aNF  := {}

//+----------------------------------------------------------------------------
//| Guarda os dados chave de todas as nota fiscais marcadas
//+----------------------------------------------------------------------------
dbSelectArea("SF1")
dbGoTop()
While !Eof()
   If SF1->F1_OK <> cMarca
      dbSkip()
      Loop
   Endif
   aAdd( aNotas, SF1->F1_SERIE+"/"+SF1->F1_DOC )
   aAdd( aNF, SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
   dbSkip()
End

For nI := 1 To Len(aNotas)
   cMsg += aNotas[nI]+Chr(10)+Chr(13)
Next 

cMsg += Chr(10)+Chr(13)+OemToAnsi("Confirma a(s) nota(s) marcada(s) para manutencao ?")

//+----------------------------------------------------------------------------
//| Solicita a confirmacao das notas fiscais
//+----------------------------------------------------------------------------
If Len(aNotas)>0
   If MsgYesNo(cMsg,"Confirmação")
      Ok_Transfere( aNF )
   Endif
Endif
Return 

///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | MarkBrowse.prw      											|//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | Funcao - u_Legenda()                                            |//
//|           | Fonte utilizado no curso oficina de programacao.                |//
//|           | Cria legenda para usuario identificar os registros              |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
User Function Legenda()
Local aCor := {}

aAdd(aCor,{"BR_VERDE"   ,"NF Não Transferida"})
aAdd(aCor,{"BR_VERMELHO","NF Transferida"    })

BrwLegenda(cCadastro,OemToAnsi("Registros"),aCor)

Return

///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | MarkBrowse.prw       											|//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | Funcao - Ok_Transfere()                                         |//
//|           | Fonte utilizado no curso oficina de programacao.                |//
//|           | Se usuario confirmar a transferencia sera executada             |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function Ok_Transfere( aNF )
Local aNFs := {} 
Local nI := 0
Local cFilSD1 := xFilial("SD1")
Local cFilSF1 := xFilial("SF1")
Local cMsg := ""
Local nGrv := 0
Local nItem := 0

aNFs := aClone( aNF )

// Busca item a item para o devido tratamento de transferencia
dbSelectArea("SD1")
dbSetOrder(1)
For nI := 1 To Len( aNFs )
   dbSeek(cFilSD1+aNFs[nI])

   While !Eof() .And. SD1->D1_FILIAL + ;
                      SD1->D1_DOC + ;
                      SD1->D1_SERIE + ;
                      SD1->D1_FORNECE + ;
                      SD1->D1_LOJA == cFilSD1+aNFs[nI]

      If !Empty(SD1->D1_REMITO)
         dbSkip()
         Loop
      Endif      

      RecLock("SD1",.F.)
         SD1->D1_REMITO := "S"
      MsUnLock("SD1")
      nGrv++
      
      dbSkip()
   End
   
   dbSelectArea("SF1")
   dbSeek(cFilSF1+aNFs[nI])
   RecLock("SF1",.F.)
      SF1->F1_REMITO := "S"
   MsUnLock()
   dbSelectArea("SD1")
Next nI 
Return

///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | MarkBrowse.prw       											\|//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | Funcao - CriaSX1()                                              |//
//|           | Fonte utilizado no curso oficina de programacao.                |//
//|           | Cria o grupo de perguntas se caso nao existir                   |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function CriaSx1()
Local nX := 0
Local nY := 0
Local aAreaAnt := GetArea()
Local aAreaSX1 := SX1->(GetArea())
Local aReg := {}

aAdd(aReg,{cPerg,"01","Emissao de ?        ","mv_ch1","D", 8,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
aAdd(aReg,{cPerg,"02","Emissao ate ?       ","mv_ch2","D", 8,0,0,"G","(mv_par02>=mv_par01)","mv_par02","","","","","","","","","","","","","","",""})
aAdd(aReg,{cPerg,"03","Codigo de ?         ","mv_ch3","C", 6,0,0,"G","","mv_par03","","","","","","","","","","","","","","","SA2"})
aAdd(aReg,{cPerg,"04","Codigo ate ?        ","mv_ch4","C", 6,0,0,"G","(mv_par04>=mv_par03)","mv_par04","","","","","","","","","","","","","","","SA2"})
aAdd(aReg,{cPerg,"05","Mostrar Todos ?     ","mv_ch5","N", 1,0,0,"C","","mv_par05","Sim","","","Nao","","","","","","","","","","",""})
aAdd(aReg,{"X1_GRUPO","X1_ORDEM","X1_PERGUNT","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID","X1_VAR01","X1_DEF01","X1_CNT01","X1_VAR02","X1_DEF02","X1_CNT02","X1_VAR03","X1_DEF03","X1_CNT03","X1_VAR04","X1_DEF04","X1_CNT04","X1_VAR05","X1_DEF05","X1_CNT05","X1_F3"})

dbSelectArea("SX1")
dbSetOrder(1)
For ny:=1 to Len(aReg)-1
	If !dbSeek(aReg[ny,1]+aReg[ny,2])
		RecLock("SX1",.T.)
		For j:=1 to Len(aReg[ny])
			FieldPut(FieldPos(aReg[Len(aReg)][j]),aReg[ny,j])
		Next j
		MsUnlock()
	EndIf
Next ny
RestArea(aAreaSX1)
RestArea(aAreaAnt)
Return Nil