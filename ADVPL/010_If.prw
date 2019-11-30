//----------------------------------------------------------------------------------------------------------------//
// Demonstracao do If...Else...EndIf.
//----------------------------------------------------------------------------------------------------------------//

User Function TstIf()

Local nX := 10

If nX > 5
   MsgAlert("Maior")
EndIf

Return

//----------------------------------------------------------------------------------------------------------------//
User Function TstElse()

Local nX := 10
Local cMsg

If nX < 5
   cMsg := "nX é menor que 5"
 Else
   cMsg := "nX é maior que 5"
EndIf

MsgAlert(cMsg)

Return

//----------------------------------------------------------------------------------------------------------------//
// Avalia a partir do IF e depois os ElseIf. Ao encontrar a primeira
// condiçao verdadeira, executa vai para o EndIf.
//----------------------------------------------------------------------------------------------------------------//
User Function TstElseIf()

Local cRegiao := "NE"
Local nICMS

If cRegiao == "SE"
   nICMS := 18
 ElseIf cRegiao == "NE"
   nICMS := 7
 Else
   nICMS := 12
EndIf

MsgAlert(nICMS)

Return

//----------------------------------------------------------------------------------------------------------------//
// Demonstracao do .OR. --> Antes de liberar uma venda, verifica o estoque.
//----------------------------------------------------------------------------------------------------------------//
User Function TstOr()

Local cEstNeg
Local nQtdVenda
Local nSaldo

/*
,----------------------------------------,
| cEstNeg == "S" .Or. nQtdVenda < nSaldo |
|========================================|
|    V                        V          |  ==> V
|----------------------------------------|
|    V                        F          |  ==> V
|----------------------------------------|
|    F                        V          |  ==> V
|----------------------------------------|
|    F                        F          |  ==> F
'----------------------------------------'
*/

cEstNeg   := "S"
nQtdVenda := 100
nSaldo    := 200

//cEstNeg   := "S"
//nQtdVenda := 201
//nSaldo    := 200

//cEstNeg   := "N"
//nQtdVenda := 100
//nSaldo    := 200

//cEstNeg   := "N"
//nQtdVenda := 201
//nSaldo    := 200

If cEstNeg == "S" .Or. nQtdVenda < nSaldo
   MsgAlert("OK, pode faturar!")
 Else
   MsgAlert("Estoque insuficiente!")
EndIf

Return

//----------------------------------------------------------------------------------------------------------------//
// Demonstracao do .AND. + .OR.--> Antes de liberar uma venda, verifica o credito e o estoque.
//----------------------------------------------------------------------------------------------------------------//
User Function TstAndOr()

Local cCredito
Local cEstNeg
Local nQtdVenda
Local nSaldo

/* If cCredito == "OK" .And. (cEstNeg == "S" .Or. nQtdVenda < nSaldo)
,------------------,       ,------------------------------------------,
| cCredito == "OK" | .And. | (cEstNeg == "S" .Or. nQtdVenda < nSaldo) |
|==================|       |==========================================|===,
|         V        |       |       V                      V           | V |  ==> V
|------------------|       |------------------------------------------|---|
|         V        |       |       V                      F           | V |  ==> V
|------------------|       |==========================================|===|
|         V        |       |       F                      V           | V |  ==> V
|------------------|       |------------------------------------------|---|
|         V        |       |       F                      F           | F |  ==> F
|==================|       |==========================================|===|
|         F        |       |       V                      V           | V |  ==> F
|------------------|       |------------------------------------------|---|
|         F        |       |       V                      F           | V |  ==> F
|------------------|       |==========================================|===|
|         F        |       |       F                      V           | V |  ==> F
|------------------|       |------------------------------------------|---|
|         F        |       |       F                      F           | F |  ==> F
'------------------'       '------------------------------------------'---'
*/

cCredito  := "OK"
cEstNeg   := "S"
nQtdVenda := 100
nSaldo    := 200

//cCredito  := "OK"
//cEstNeg   := "S"
//nQtdVenda := 201
//nSaldo    := 200

//cCredito  := "NAO OK"
//cEstNeg   := "S"
//nQtdVenda := 100
//nSaldo    := 200

//cCredito  := "OK"
//cEstNeg   := "N"
//nQtdVenda := 201
//nSaldo    := 200

If cCredito == "OK" .And. (cEstNeg == "S" .Or. nQtdVenda < nSaldo)
   MsgAlert("OK, pode faturar!")
 Else
   If cCredito <> "OK"
      MsgAlert("Sem Credito!")
    Else
      MsgAlert("Estoque insuficiente!")
   EndIf
EndIf

Return
