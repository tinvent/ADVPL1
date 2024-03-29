#INCLUDE "REPORT.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "JPEG.CH"
#INCLUDE "TOPCONN.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �GerQuery  � Autor �  � Data �01/03/2009���
�������������������������������������������������������������������������Ĵ��
���Descricao �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Analista Resp.�  Data  � Bops � Manutencao Efetuada                    ���
�������������������������������������������������������������������������Ĵ��
���              �  /  /  �      �                                        ���
���              �  /  /  �      �                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function GERQUERY()
//Variaveis Locais da Funcao
	Local _cSql	 := ""
	Local oMemo
	Local aButtons := {{"BMPTRG", {||Iif(ValidaQuery(_cSql),;
						MsAguarde({|| fVisQry(_cSql)},"Aguarde...","Gerando Visualiza��o..."),;
						MsgAlert("Existe um erro na query digitada"))},"Run (F5)"},;
						{"MDIEXCEL", {||Processa({|| fGeraExcel(aStruct)},"Excel", "Exporta��o Excel, aguarde...")},"Excel (F8)"},;
						{"S4WB005N", {||Iif(ValidaQuery(_cSql),fRelat(_cSql, fMontaRes(_cSql)),MsgAlert("Existe um erro na query digitada"))},"Relat�rio"}}
	// Variaveis Private da Funcao
	Private _oDlg				// Dialog Principal
	Private aStruct := {}
	Private oGetDados1
	
//	aStruct := fMontaRes(_cSql)
	
	DEFINE MSDIALOG _oDlg TITLE OemtoAnsi("Contrutor de Query - Release 1.2") FROM C(178),C(181) TO C(650),C(1050) PIXEL
	
		// Cria Componentes Padroes do Sistema
		@ C(014),C(004) GET oMemo Var _cSql MEMO Size C(430),C(80) PIXEL OF _oDlg
		
		fGetDados1()
		
	    SetKey(VK_F5, {||Iif(ValidaQuery(_cSql),;
						MsAguarde({|| fVisQry(_cSql)},"Aguarde...","Gerando Visualiza��o..."),;
						MsgAlert("Existe um erro na query digitada"))} )

	    SetKey(VK_F8, {||Processa({|| fGeraExcel(aStruct)},"Excel", "Exporta��o Excel, aguarde...")} )
	
	ACTIVATE MSDIALOG _oDlg ON INIT EnchoiceBar(_oDlg,{|| _oDlg:End()},{|| _oDlg:End()},,aButtons) CENTERED 

	SetKey(VK_F5, Nil)
	SetKey(VK_F8, Nil)
	
Return(.T.)

/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa   �fGetDados1  � Autor �  � Data �01/03/2009���
����������������������������������������������������������������������������Ĵ��
���Descricao  � Montagem da GetDados                                         ���
����������������������������������������������������������������������������Ĵ��
���Observacao � O Objeto oGet1  foi criado como Private no inicio do Fonte   ���
���           � desta forma voce podera trata-lo em qualquer parte do        ���
���           � seu programa:                                                ���
���           �                                                              ���
���           � Para acessar o aCols desta MsNewGetDados: oGet1 :aCols[nX,nY]���
���           � Para acessar o aHeader: oGet1 :aHeader[nX,nY]                ���
���           � Para acessar o "n"    : oGet1 :nAT                           ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function fGetDados1(aStruct)
	// Variaveis deste Form                                                                                                         
	Local nX			:= 0                                                                                                              
	//�����������������������������������Ŀ
	//� Variaveis da MsNewGetDados()      �
	//�������������������������������������
	// Vetor responsavel pela montagem da aHeader
	Local aCpoGDa       	:= {}
	// Vetor com os campos que poderao ser alterados                                                                                
	Local aAlter       	:= {""}
	Local nSuperior    	:= C(100)           // Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
	Local nEsquerda    	:= C(004)           // Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
	Local nInferior    	:= C(232)           // Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
	Local nDireita     	:= C(434)           // Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
	// Posicao do elemento do vetor aRotina que a MsNewGetDados usara como referencia  
	Local nOpc         	:= 0//GD_INSERT+GD_DELETE+GD_UPDATE                                                                            
	Local cLinhaOk     	:= "AllwaysTrue"    // Funcao executada para validar o contexto da linha atual do aCols                  
	Local cTudoOk      	:= "AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)      
	Local cIniCpos     	:= ""               // Nome dos campos do tipo caracter que utilizarao incremento automatico.            
	                                         // Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do            
	                                         // segundo campo>+..."                                                               
	Local nFreeze      	:= 000              // Campos estaticos na GetDados.                                                               
	Local nMax         	:= 000              // Numero maximo de linhas permitidas. Valor padrao 99                           
	Local cCampoOk     	:= "AllwaysTrue"    // Funcao executada na validacao do campo                                           
	Local cSuperApagar 	:= ""               // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    
	Local cApagaOk     	:= "AllwaysTrue"    // Funcao executada para validar a exclusao de uma linha do aCols                   
	// Objeto no qual a MsNewGetDados sera criada                                      
	Local oWnd          	:= _oDlg                                                                                                  
	Local aHead        	:= {}               // Array a ser tratado internamente na MsNewGetDados como aHeader                    
	Local aCol         	:= {}               // Array a ser tratado internamente na MsNewGetDados como aCols                      
	_aTipo := {}
	_aTam := {}
	_aDec := {}
	If ValType(aStruct) == "A"
		For nX:=1 to Len(aStruct)
			Aadd(aCpoGDa,aStruct[nX,1])
			Aadd(_aTipo,aStruct[nX,2])
			Aadd(_aTam,aStruct[nX,3])
			Aadd(_aDec,aStruct[nX,4])
		Next	                                                                                                                                
	EndIf
	// Carrega aHead                                                                                                                
	DbSelectArea("SX3")                                                                                                             
	SX3->(DbSetOrder(2)) // Campo                                                                                                   
	For nX := 1 to Len(aCpoGDa)                                                                                                     
		If SX3->(DbSeek(aCpoGDa[nX]))                                                                                                 
			Aadd(aHead,{ AllTrim(X3Titulo()),;                                                                                         
				SX3->X3_CAMPO	,;                                                                                                       
				SX3->X3_PICTURE,;                                                                                                       
				SX3->X3_TAMANHO,;                                                                                                       
				SX3->X3_DECIMAL,;                                                                                                       
				""	,;                                                                                                       
				SX3->X3_USADO	,;                                                                                                       
				SX3->X3_TIPO	,;                                                                                                       
				SX3->X3_F3 		,;                                                                                                       
				SX3->X3_CONTEXT,;                                                                                                       
				""	,;                                                                                                       
				""})                                                                                                       
		Else
			Aadd(aHead,{ aCpoGDa[nX],;                                                                                         
				aCpoGDa[nX]	,;                                                                                                       
				"",;                                                                                                       
				_aTam[nX],;                                                                                                       
				_aDec[nX],;                                                                                                       
				""	,;                                                                                                       
				""	,;                                                                                                       
				_aTipo[nX]	,;                                                                                                       
				"" 		,;                                                                                                       
				"",;                                                                                                       
				""	,;                                                                                                       
				""})                                                                                                       
		Endif                                                                                                                         
	Next nX                                                                                                                         
	// Carregue aqui a Montagem da sua aCol                                                                                         
	aAux := {}                                                                                                                      
	For nX := 1 to Len(aCpoGDa)                                                                                                     
		If DbSeek(aCpoGDa[nX])                                                                                                        
			Aadd(aAux,CriaVar(SX3->X3_CAMPO))                                                                                          
		Endif                                                                                                                         
	Next nX                                                                                                                         
	Aadd(aAux,.F.)                                                                                                                  
	Aadd(aCol,aAux)                                                                                                                 
	
	oGetDados1 := MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinhaOk,cTudoOk,cIniCpos,;                               
	                             aAlter,nFreeze,nMax,cCampoOk,cSuperApagar,cApagaOk,oWnd,aHead,aCol)                                   
Return Nil

/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa   �   C()      � Autor �  � Data �10/05/2005���
����������������������������������������������������������������������������Ĵ��
���Descricao  � Funcao responsavel por manter o Layout independente da       ���
���           � resolu��o horizontal do Monitor do Usuario.                  ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function C(nTam)                                                         
	Local nHRes	:=	oMainWnd:nClientWidth	//Resolucao horizontal do monitor      
	Do Case                                                                         
		Case nHRes == 640	//Resolucao 640x480                                         
			nTam *= 0.8                                                                
		Case nHRes == 800	//Resolucao 800x600                                         
			nTam *= 1                                                                  
		OtherWise			//Resolucao 1024x768 e acima                                
			nTam *= 1.28                                                               
	EndCase                                                                         
	If "MP8" $ oApp:cVersion                                                        
	  //���������������������������Ŀ                                               
	  //�Tratamento para tema "Flat"�                                               
	  //�����������������������������                                               
	  If (Alltrim(GetTheme()) == "FLAT").Or. SetMdiChild()                          
	       	nTam *= 0.90                                                            
	  EndIf                                                                         
	EndIf                                                                           
Return Int(nTam)                                                                

/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa   � fExecQry   � Autor �  � Data �01/03/2009���
����������������������������������������������������������������������������Ĵ��
���Descricao  � Funcao responsavel por executar a query e criar o arquivo de ���
���           � trabalho                                                     ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function fVisQry(_cSql)

	aStruct := fMontaRes(_cSql)
	fResult(aStruct)
	
Return()

/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa   � fResult    � Autor �  � Data �01/03/2009���
����������������������������������������������������������������������������Ĵ��
���Descricao  �                                                              ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function fResult(aStruct)

	fGetDados1(aStruct)

	oGetDados1:aCols := {}
	
	TRBREL->(DbGoTop())
	While !TRBREL->(Eof())
		_aResult := {}
		For nG:=1 To Len(aStruct)
			Aadd(_aResult,TRBREL->&(aStruct[nG,1]))
		Next
		Aadd(_aResult,.F.)
		Aadd(oGetDados1:aCols,_aResult)
		TRBREL->(DbSkip())
	EndDo

	oGetDados1:oBrowse:Refresh()
	_oDlg:Refresh()
Return(aStruct)

/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa   � fMontaRes  � Autor �  � Data �01/03/2009���
����������������������������������������������������������������������������Ĵ��
���Descricao  �                                                              ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function fMontaRes(_cSql)

    If Select("TRBREL") > 1
    	TRBREL->(DbCloseArea())
    EndIf

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cSql),"TRBREL",.T.,.T.)

	aStruct  := TRBREL->(dbStruct())

Return(aStruct)

/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa   � fGeraExcel � Autor �  � Data �01/03/2009���
����������������������������������������������������������������������������Ĵ��
���Descricao  �                                                              ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function fGeraExcel(aStruct)
	Local cDirDocs   := MsDocPath() 
	Local cArquivo := CriaTrab(,.F.)
	Local cCrLf 	:= Chr(13) + Chr(10)
	Local cPath		:= AllTrim(GetTempPath())

	If Len(aStruct) == 0
		Alert("Favor executar a query.")
		Return()
	EndIf
	aStru := {}
	For nG:=1 To Len(aStruct)
		Aadd(aStru,{aStruct[nG,1],aStruct[nG,2],aStruct[nG,3],aStruct[nG,4]})
	Next
	
	ProcRegua(Len(oGetDados1:aCols)+2)

	nHandle := MsfCreate(cDirDocs+"\"+cArquivo+".CSV",0)

	If nHandle > 0
		
		// Grava o cabecalho do arquivo
		IncProc("Aguarde! Gerando arquivo de integra��o com Excel...")
		aEval(aStru, {|e, nX| fWrite(nHandle, e[1] + If(nX < Len(aStru), ";", "") ) } )
		fWrite(nHandle, cCrLf ) // Pula linha
		
		For nX := 1 to Len(oGetDados1:aCols)
			IncProc("Aguarde! Gerando arquivo de integra��o com Excel...")
			nG := 0
			For nG:=1 To Len(aStruct)
				If aStruct[nG,2] == "C"
					fWrite(nHandle, oGetDados1:aCols[nX,nG] + ";" )
				ElseIf aStruct[nG,2] == "N"
					fWrite(nHandle, Transform(oGetDados1:aCols[nX,nG],"@E 999,999,999.99") + ";" )
				ElseIf aStruct[nG,2] == "D"
					fWrite(nHandle, Transform(oGetDados1:aCols[nX,nG],"") + ";" )
				Else
					fWrite(nHandle, Iif(oGetDados1:aCols[nX,nG],"VERDADEIRO","FALSO") + ";" )
				EndIf
			Next nG

			fWrite(nHandle, cCrLf ) // Pula linha
		Next nX
		
		IncProc("Aguarde! Abrindo o arquivo...")
		
		fClose(nHandle)
		CpyS2T( cDirDocs+"\"+cArquivo+".CSV" , cPath, .T. )
		
		If ! ApOleClient( 'MsExcel' ) 
			MsgAlert("MsExcel nao instalado")
			Return
		EndIf
		
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open( cPath+cArquivo+".CSV" ) // Abre uma planilha
		oExcelApp:SetVisible(.T.)
	Else
		MsgAlert("Falha na cria��o do arquivo")
	Endif	

Return()

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �fRelat      �Autor  �       � Data �  06-08-08   ���
���������������������������������������������������������������������������͹��
���Desc.     � Relatorio                                                    ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       � CRM                                                          ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function fRelat(_cSql, aStruct)
Local oReport	//Objeto relatorio TReport (Release 4)

	oReport := CUSRRELDEF(_cSql, aStruct)
	oReport:PrintDialog()

Return(.T.)   

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �CUSRRELDEF  �Autor  �       � Data �  06-08-08   ���
���������������������������������������������������������������������������͹��
���Desc.     �                                                              ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       � CRM                                                          ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function CUSRRELDEF(_cSql, aStruct)
Local oReport				//Objeto relatorio TReport (Release 4)
Local oSection1 			//Objeto secao 1 do relatorio 

DEFINE REPORT oReport NAME "RELD" TITLE "Relatorio" ACTION {|oReport| CUSRRELIMP( oReport, _cSql, aStruct)} DESCRIPTION "Relat�rio"

oReport:SetPortrait()

DEFINE SECTION oSection1 OF oReport TITLE "Relat�rio" TABLES "SA1"      // "ORIGEM"

For nX:=1 To Len(aStruct)
	DEFINE CELL NAME aStruct[nX,1]		OF oSection1 ALIAS "" TITLE aStruct[nX,1]
Next

Return oReport

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �CUSRRELIMP  �Autor  �       � Data �  06-08-08   ���
���������������������������������������������������������������������������͹��
���Desc.     �                                                              ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       � CRM                                                          ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function CUSRRELIMP(oReport, _cSql, aStruct)
Local oSection1 := oReport:Section(1)		//Objeto secao 1 do relatorio (Cabecalho, campos da tabela SU7) 

TRBREL->(DbGoTop())
//oReport:SetMeter(RecCount())
oSection1:Init()
While !TRBREL->(Eof())
	If oReport:Cancel()
		Exit
	EndIf

	nX := 1
	For nX:=1 To Len(aStruct)
		oSection1:Cell(aStruct[nX,1]):SetValue(TRBREL->&(aStruct[nX,1]))
	Next	

	oSection1:PrintLine()

//	oReport:IncMeter()
	TRBREL->(DbSkip())
EndDo

oSection1:Finish()
	
Return(.T.)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �CUSRRELIMP  �Autor  �       � Data �  06-08-08   ���
���������������������������������������������������������������������������͹��
���Desc.     �                                                              ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       � CRM                                                          ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function ValidaQuery(_cSql)
	Local _lRet := .T.
	
	If TcSqlExec(_cSql) <> 0
		_lRet := .F.
	EndIf
	
Return(_lRet)