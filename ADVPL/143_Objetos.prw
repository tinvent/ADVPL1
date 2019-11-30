#Include "PROTHEUS.CH"

//----------------------------------------------------------------------------------------------------------------// 
CLASS Cabec

DATA nPag
DATA cTitle

METHOD New()
METHOD Imprime()
METHOD EndCabec()

ENDCLASS

//----------------------------------------------------------------------------------------------------------------// 
METHOD New(cTitle) CLASS Cabec

DEFAULT cTitle := "Relatorio"

::nPag   := 0
::cTitle := cTitle

Return Self

//----------------------------------------------------------------------------------------------------------------// 
METHOD Imprime() CLASS Cabec

@PRow()  , 000 PSay __PrtThinLine()
@PRow()+1, 000 PSay "Microsiga Software S/A"
@PRow()  , 115 PSay "Pagina : " + Str(++::nPag, 8)
@PRow()+1, 000 PSay ::cTitle
@PRow()  , 115 PSay "Emissao: " + DtoC(Date())
@PRow()+1, 000 PSay __PrtThinLine()

Return

//----------------------------------------------------------------------------------------------------------------// 
METHOD EndCabec() CLASS Cabec

Return FreeObj(Self)

//----------------------------------------------------------------------------------------------------------------// 
CLASS Obj1

   DATA cVar1

   METHOD New()
   METHOD MTObj1()

ENDCLASS

METHOD New() CLASS Obj1

   ::cVar1 := "Objeto 1"

Return

METHOD MTObj1() CLASS Obj1

   MsgAlert(::cVar1)

Return

//----------------------------------------------------------------------------------------------------------------// 
CLASS Obj2 OF Obj1

   DATA cVar2

   METHOD New()
   METHOD MTObj2()

ENDCLASS

METHOD New() CLASS Obj2

   ::cVar2 := "Objeto 2"

Return

METHOD MTObj2() CLASS Obj2

   MsgAlert(::cVar2)

Return
