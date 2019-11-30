//----------------------------------------------------------------------------------------------------------------//
// Demonstracao de funcoes usadas no TranM2.PRW (Modelo2):
// CriaVar(), FCount(), FieldName(), FieldPos(), FieldGet() e FieldPut().
//----------------------------------------------------------------------------------------------------------------//

User Function FuncMod2()

Local i

/////////////////////////////////////////////////////////////////////
// Funcao CriaVar()                                                //
/////////////////////////////////////////////////////////////////////

// Criacao de uma variavel qualquer.
// A variavel é criada como Private, pois nao esta sendo declarada.
cNome := "Joao da Silva"

// Cria a variavel 'Z2_Data' privada, com conteudo vazio e tipo igual ao campo SZ2->Z2_DATA.
M->Z2_Data := CriaVar("Z2_DATA", .F.)

MsgAlert(M->Z2_Data, "Sem inicializador-padrão")

// Recria a mesma variavel, inicializando com conteudo carregado a partir do inicializador-padrao (X3_RELACAO).
M->Z2_Data := CriaVar("Z2_DATA", .T.)    // O inicializador-padrao deste campo é 'dDataBase'.

MsgAlert(M->Z2_DATA, "Usando inicializador-padrão")

/////////////////////////////////////////////////////////////////////
// Funcao FCount()    - retorna a quantidade de campos num arquivo //
//        FieldName() - retorna o nome de um campo do arquivo      //
//        FieldPos()  - retorna a posicao fisica de um campo       //
/////////////////////////////////////////////////////////////////////

/* Campos do SZ2:
  ,-----------,----------,------,-------------------------------,
  |   Campo   |   Tipo   | Tam. |     Inicializador padrao      |
  |-----------|----------|------|-------------------------------|
1 | Z2_Filial | Caracter |   2  |                               |
2 | Z2_Nome   | Caracter |  20  |                               |
3 | Z2_Numero | Caracter |   4  | GetSXENum(“SZ2”, “Z2_NUMERO”) |
4 | Z2_Item   | Caracter |   2  |                               |
5 | Z2_Data   | Data     |   8  | dDataBase                     |
6 | Z2_Tipo   | Caracter |   1  | “D”                           |
7 | Z2_Hist   | Caracter |  20  |                               |
8 | Z2_Valor  | Numerico | 12,2 |                               |
9 | Z2_Aprov  | Caracter |   3  |                               |
  '-----------'----------'------'-------------------------------'*/

dbSelectArea("SZ2")     // Seleciona o arquivo SZ2.

MsgAlert("O arq. SZ2 tem " + Str(FCount()) + " campos!")

For i := 1 To FCount()                      // i      -->      1           2           3      ...     9

    MsgAlert(Str(i) + ": " + FieldName(i))  //        --> "Z2_FILIAL"  "Z2_NOME"  "Z2_NUMERO" ... "Z2_APROV"
    cCampo := FieldName(i)
    M->&(cCampo) := CriaVar(cCampo, .T.)

 // M->&("Z2_NOME")   := CriaVar("Z2_NOME"  , .T.)    ---,
 //                                                      |
 // M->Z2_NOME        := "                    "       <--'

Next

/* Variaveis criadas e seus conteudos:

   Z2_FILIAL   "  "
   Z2_NOME     "                    "
   Z2_NUMERO   "NNNN"   --> ultimo num.+1
   Z2_ITEM     "  "
   Z2_DATA     99/99/99 --> data-base do sistema
   Z2_TIPO     "D"
   Z2_HIST     "                    "
   Z2_VALOR    0.00
   Z2_APROV    "   "
*/

MsgAlert("A posição do campo Z2_FILIAL é " + Str(FieldPos("Z2_FILIAL")))
MsgAlert("A posição do campo Z2_NUMERO é " + Str(FieldPos("Z2_NUMERO")))
MsgAlert("A posição do campo Z2_DATA é "   + Str(FieldPos("Z2_DATA")))

/////////////////////////////////////////////////////////////////////
// Existem duas maneiras de ler e gravar conteudos em campos de    //
// arquivos:                                                       //
//                                                                 //
// 1 - Com os nomes dos campos explicitos no programa.             //
//                                                                 //
//     Ex.: cNumero := SZ2->Z2_Numero --> le o conteudo do campo   //
//                                        e atribue a uma variavel.//
//                                                                 //
//          SZ2->Z2_Numero := cNumero --> grava o conteudo da var. //
//                                        no campo.                //
//                                                                 //
//     Usando-se esta forma, o programa torna-se específico, ou se-//
//     ja, so serve para este arquivo, pois os nomes do campos es- //
//     tao fixados no programa.                                    //
//                                                                 //
// 2 - Com o uso das funcoes FieldPos(), FieldGet() e FieldPut().  //
//                                                                 //
//     Ex.: cNumero := FieldGet(2) --> le o conteudo do campo nume-//
//                                     ro 2 e atribue 'a variavel. //
//                                                                 //
//          cNumero := FieldGet(FieldPos("Z2_Numero")) --> le o    //
//                                     conteudo do campo, obtendo  //
//                                     a sua posicao pela funcao   //
//                                     FieldPos.                   //
//                                                                 //
//          FieldPut(2, "123456")  --> grava o conteudo no campo   //
//                                     numero 2.                   //
//                                                                 //
//     Desta forma, é possivel escrever programas genericos, que   //
//     funcionam com qualquer arquivo, pois os nomes dos campos    //
//     poderiam estar num dicionario de dados.                     //
/////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////
// Le e grava conteudos nos campos com os nomes dos campos         //
/////////////////////////////////////////////////////////////////////

dbSelectArea("SZ2")
cNumero := SZ2->Z2_Numero
dData   := SZ2->Z2_Data
nValor  := SZ2->Z2_Valor

RecLock("SZ2", .T.)     // Inclui um registro.
SZ2->Z2_Numero := GetSX8Num("SZ2", "Z2_NUMERO")
SZ2->Z2_Data   := Date()
SZ2->Z2_Valor  := 1000
ConfirmSX8()

/////////////////////////////////////////////////////////////////////
// Le e grava conteudos nos campos usando as funcoes:              //
// FieldGet() e FieldPut()                                         //
/////////////////////////////////////////////////////////////////////

dbSelectArea("SZ2")

// Leitura dos campos usando FieldGet().
cNumero := FieldGet(3) // Campo Z2_Numero
dData   := FieldGet(5) // Campo Z2_Data
nValor  := FieldGet(8) // Campo Z2_Valor

// Leitura dos campos usando FieldGet() e FieldPos().
cNumero := FieldGet(FieldPos("Z2_Numero"))
dData   := FieldGet(FieldPos("Z2_Data"))
nValor  := FieldGet(FieldPos("Z2_Valor"))

// Gravacao dos campos usando FieldPut() e FieldPos().
RecLock("SZ2", .T.)     // Inclui um registro.
FieldPut(FieldPos("Z2_Numero"), GetSX8Num("SZ2", "Z2_NUMERO"))
FieldPut(FieldPos("Z2_Data"), Date())
FieldPut(FieldPos("Z2_Valor"), 1200)
ConfirmSX8()

Return
