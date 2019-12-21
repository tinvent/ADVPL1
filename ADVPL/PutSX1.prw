#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} PutSX1
//TODO Rotina para manutenção do grupo de pergutas.
@author TI-011392
@since 23/07/2017
@version undefined
@param cGrupo, characters, descricao
@param cOrdem, characters, descricao
@param cPergunt, characters, descricao
@param cPerSpa, characters, descricao
@param cPerEng, characters, descricao
@param cVar, characters, descricao
@param cTipo, characters, descricao
@param nTamanho, numeric, descricao
@param nDecimal, numeric, descricao
@param nPresel, numeric, descricao
@param cGSC, characters, descricao
@param cValid, characters, descricao
@param cF3, characters, descricao
@param cGrpSxg, characters, descricao
@param cPyme, characters, descricao
@param cVar01, characters, descricao
@param cDef01, characters, descricao
@param cDefSpa1, characters, descricao
@param cDefEng1, characters, descricao
@param cCnt01, characters, descricao
@param cDef02, characters, descricao
@param cDefSpa2, characters, descricao
@param cDefEng2, characters, descricao
@param cDef03, characters, descricao
@param cDefSpa3, characters, descricao
@param cDefEng3, characters, descricao
@param cDef04, characters, descricao
@param cDefSpa4, characters, descricao
@param cDefEng4, characters, descricao
@param cDef05, characters, descricao
@param cDefSpa5, characters, descricao
@param cDefEng5, characters, descricao
@param aHelpPor, array, descricao
@param aHelpEng, array, descricao
@param aHelpSpa, array, descricao
@param cHelp, characters, descricao
@type function
/*/
User Function PutSX1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,; 
	cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,; 
	cF3, cGrpSxg,cPyme,; 
	cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,; 
	cDef02,cDefSpa2,cDefEng2,; 
	cDef03,cDefSpa3,cDefEng3,; 
	cDef04,cDefSpa4,cDefEng4,; 
	cDef05,cDefSpa5,cDefEng5,; 
	aHelpPor,aHelpEng,aHelpSpa,cHelp) 

	LOCAL aArea := GetArea() 
	Local cKey 
	Local lPort := .f. 
	Local lSpa := .f. 
	Local lIngl := .f. 

	cKey := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "." 

	cPyme    := Iif( cPyme           == Nil, " ", cPyme          ) 
	cF3      := Iif( cF3           == NIl, " ", cF3          ) 
	cGrpSxg  := Iif( cGrpSxg     == Nil, " ", cGrpSxg     ) 
	cCnt01   := Iif( cCnt01          == Nil, "" , cCnt01      ) 
	cHelp    := Iif( cHelp          == Nil, "" , cHelp          ) 

	dbSelectArea( "SX1" ) 
	dbSetOrder( 1 ) 

	// Ajusta o tamanho do grupo. Ajuste emergencial para validação dos fontes. 
	// RFC - 15/03/2007 
	cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " ) 

	If !( DbSeek( cGrupo + cOrdem )) 

		cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt) 
		cPerSpa     := If(! "?" $ cPerSpa .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa) 
		cPerEng     := If(! "?" $ cPerEng .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng) 

		Reclock( "SX1" , .T. ) 

		Replace X1_GRUPO   With cGrupo 
		Replace X1_ORDEM   With cOrdem 
		Replace X1_PERGUNT With cPergunt 
		Replace X1_PERSPA With cPerSpa 
		Replace X1_PERENG With cPerEng 
		Replace X1_VARIAVL With cVar 
		Replace X1_TIPO    With cTipo 
		Replace X1_TAMANHO With nTamanho 
		Replace X1_DECIMAL With nDecimal 
		Replace X1_PRESEL With nPresel 
		Replace X1_GSC     With cGSC 
		Replace X1_VALID   With cValid 

		Replace X1_VAR01   With cVar01 

		Replace X1_F3      With cF3 
		Replace X1_GRPSXG With cGrpSxg 

		If Fieldpos("X1_PYME") > 0 
			If cPyme != Nil 
				Replace X1_PYME With cPyme 
			Endif 
		Endif 

		Replace X1_CNT01   With cCnt01 
		If cGSC == "C"               // Mult Escolha 
			Replace X1_DEF01   With cDef01 
			Replace X1_DEFSPA1 With cDefSpa1 
			Replace X1_DEFENG1 With cDefEng1 

			Replace X1_DEF02   With cDef02 
			Replace X1_DEFSPA2 With cDefSpa2 
			Replace X1_DEFENG2 With cDefEng2 

			Replace X1_DEF03   With cDef03 
			Replace X1_DEFSPA3 With cDefSpa3 
			Replace X1_DEFENG3 With cDefEng3 

			Replace X1_DEF04   With cDef04 
			Replace X1_DEFSPA4 With cDefSpa4 
			Replace X1_DEFENG4 With cDefEng4 

			Replace X1_DEF05   With cDef05 
			Replace X1_DEFSPA5 With cDefSpa5 
			Replace X1_DEFENG5 With cDefEng5 
		Endif 

		Replace X1_HELP With cHelp 

		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa) 

		MsUnlock() 
	Else 

		lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT) 
		lSpa := ! "?" $ X1_PERSPA .And. ! Empty(SX1->X1_PERSPA) 
		lIngl := ! "?" $ X1_PERENG .And. ! Empty(SX1->X1_PERENG) 

		If lPort .Or. lSpa .Or. lIngl 
			RecLock("SX1",.F.) 
			If lPort 
				SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?" 
			EndIf 
			If lSpa 
				SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?" 
			EndIf 
			If lIngl 
				SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?" 
			EndIf 
			SX1->(MsUnLock()) 
		EndIf 
	Endif 

	RestArea( aArea ) 

Return