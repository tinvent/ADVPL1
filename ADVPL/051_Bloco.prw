//-----------------------------------------------------------------------------//
// Demonstracao de Bloco de Codigo.
//-----------------------------------------------------------------------------//

User Function TstBloco()

Local bBloco := {|| 2 * 10}
Local nResult

nResult := EVal(bBloco)           // Poderia ser tambem: EVal( {|| 2 * 10} )

Alert(nResult)

Return Nil

//-----------------------------------------------------------------------------//
User Function TstBloc1()

Local bBloco := {|x| x * 2}       // Bloco de Codigo que recebe um parametro.
Local nResult
Local i

For i := 1 To 10

    nResult := EVal(bBloco, i)    // Executa o bloco de codigo, passando um parametro.

    Alert(nResult)

Next

Return Nil

//-----------------------------------------------------------------------------//
User Function TstBloc2()

Local bBloco := {|x,y|If(x>y,"Maior","Menor")}

MsgAlert(EVal(bBloco, 2, 4))
MsgAlert(EVal(bBloco, 5, 3))

Return Nil

//-----------------------------------------------------------------------------//
User Function TstBloc3()

Local x
Local y
Local bBloco := {|| x := 10, y := 20}

// Executa uma lista de expressao e retorna o resultado
// da ultima expressao executada.
MsgAlert(EVal(bBloco))

Return Nil

//-----------------------------------------------------------------------------//
// Bloco de Codigo em forma de string, armazenado numa variavel de tipo caracter,
// e convertido para bloco de codigo por meio de Macro.
//-----------------------------------------------------------------------------//
User Function TstBloc4()

Local x
Local y
Local cBloco := "{|| x := 10, y := 20}"
Local bBloco

bBloco := &cBloco

MsgAlert(EVal(bBloco))

Return Nil

//-----------------------------------------------------------------------------//
User Function TstBloc5()

Local x := 1
Local y := 2
Local bBloco

bBloco := {|| x + y}

MsgAlert(EVal(bBloco))

u_TstBloc6(bBloco)

Return

User Function TstBloc6(bBloco)

Local x := 10
Local y := 20

MsgAlert(EVal(bBloco))

Return
