//--------------------------------------------------------------------//
// Demostracao de Matrizes (ou Array).
//**********************************************************************
//** TstMatr1, TstMatr3 e TstMatr4: executar em modo DEBUG, abrindo a **
//** janela Watchs e inserindo o array para ver o seu conteudo.       **
//--------------------------------------------------------------------//

User Function TstMatriz()

Local aMatriz := {"Joao", "Alberto", "Pedro", "Maria"}
Local i

For i := 1 To Len(aMatriz)
    MsgAlert(aMatriz[i])
Next

MsgAlert("O mesmo efeito, usando AEval()")

// A funcao AEval() percorre automaticamente todos os elementos da matriz,
// passando cada elemento como parametro para o bloco de codigo.
AEval( aMatriz, {|cNome| MsgAlert(cNome)} )

Return Nil

//--------------------------------------------------------------------//
User Function TstMatr1()

Local i
Local aX

// Inicializa um array vazio --> para os casos em que o numero
//                               de elementos é desconhecido.
aX := {}

For i := 1 To 5
    AAdd(aX, i*10)      // Adiciona elementos ao final do array.
Next

// Exclui o terceiro elemento. Os elementos subsequentes sobem
// uma posiçao e o ultimo elemento fica com valor NIL.
ADel(aX, 3)

// Insere um elemento no segundo elemento. Os elementos subse-
// quentes descem uma posicao e o ultimo elemento é descartado.
AIns(aX, 2)

// Redimensiona o array. Se o novo numero de elementos for maior
// que o atual, serao inseridos elementos com valor NIL no final.
// Caso contrario, os elementos do final serao eliminados.
ASize(aX, 10)

// Reinicializa o array. Volta a ser vazio.
aX := {}

// Inicializa com 3 elementos vazios.
aX := Array(3)

For i := 1 To Len(aX)
    aX[i] := i*2   // Atribue valor aos elementos do array.
Next

Return Nil

//--------------------------------------------------------------------//
// Ordenação de arrays.
//--------------------------------------------------------------------//
User Function TstMatr2()

Local aMatriz := {"Joao", "Alberto", "Pedro", "Maria"}

ASort(aMatriz)

AEval( aMatriz, {|cNome| MsgAlert(cNome)} )

Return Nil

//--------------------------------------------------------------------//
// Ordenação de arrays multi-dimensionais.
//--------------------------------------------------------------------//
User Function TstMatr3()

Local aMatriz := {{"Joao",15}, {"Alberto",20}, {"Pedro",10}, {"Maria",30}}

//=== Ver PPT ===//
ASort(aMatriz,,,{|aX,aY| aX[2] < aY[2]})

Return Nil

//--------------------------------------------------------------------//
// Ordenação de arrays multi-dimensionais.
//--------------------------------------------------------------------//
User Function TstMatr4()

Local aMatriz := {{"Joao",15}, {"Alberto",20}, {"Pedro",10}, {"Beatriz",30}, {"Antonio",15}, {"Maria",30}, {"Carlos",10}, {"Ana",30}, {"Roberto",15}, {"Maria",30}}

// Em ordem de idade+nome.
ASort(aMatriz,,,{|aX,aY| Str(aX[2])+aX[1] < Str(aY[2])+aY[1]})

Return Nil

//--------------------------------------------------------------------//
// Procura de um elemento dentro do array.
//--------------------------------------------------------------------//
User Function TstMatr5()

Local nItem
Local aMatriz := {"Joao", "Alberto", "Pedro", "Maria"}

nItem := AScan(aMatriz, "Pedro")

MsgAlert(nItem)

Return Nil

//--------------------------------------------------------------------//
// Procura de um elemento dentro de um array multi-dimensional.
//--------------------------------------------------------------------//
User Function TstMatr6()

Local aMatriz := {{"Joao",15}, {"Alberto",20}, {"Pedro",10}, {"Maria",30}}

nItem := AScan(aMatriz, {|aX| aX[1] == "Alberto"})
//nItem := AScan(aMatriz, {|aX| Upper(aX[1]) == Upper("Alberto")})

MsgAlert(nItem)

Return Nil

//--------------------------------------------------------------------//
// Cópia de um array para outro.
//--------------------------------------------------------------------//
User Function TstClone()

Local aMatriz := {"Joao", "Alberto", "Pedro", "Maria"}
Local aCopia

aCopia := aMatriz

aCopia[1] := "AAAA"
aCopia[2] := "BBBB"
aCopia[3] := "CCCC"
aCopia[4] := "DDDD"

aMatriz := {"Joao", "Alberto", "Pedro", "Maria"}

aCopia := AClone(aMatriz)

aCopia[1] := "AAAA"
aCopia[2] := "BBBB"
aCopia[3] := "CCCC"
aCopia[4] := "DDDD"

Return Nil

//--------------------------------------------------------------------//
User Function Classifica()

Local aZ := {"Joao", "Alberto", "Pedro", "Maria", "Ana", "Ricardo"}
Local lMudou
Local cManobra
Local i

While .T.

   lMudou := .F.
   i := 1

   While i < Len(aZ)

      If aZ[i] > aZ[i+1]

         cManobra := aZ[i]
         aZ[i]    := aZ[i+1]
         aZ[i+1]  := cManobra
         lMudou   := .T.

      EndIf

      i := i + 1

   End

   If !lMudou
      Exit
   Else
      Loop
   EndIf

End

Define MSDialog oDlg Title "Array classificado" From 0,0 To 400,400 Pixel 

@10,20 Say aZ[1] Pixel Of oDlg
@20,20 Say aZ[2] Pixel Of oDlg
@30,20 Say aZ[3] Pixel Of oDlg
@40,20 Say aZ[4] Pixel Of oDlg
@50,20 Say aZ[5] Pixel Of oDlg
@60,20 Say aZ[6] Pixel Of oDlg

Activate Dialog oDlg Centered

Return Nil
