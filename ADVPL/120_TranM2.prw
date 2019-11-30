#INCLUDE "RWMAKE.CH"

User Function TranM2()

Private aRotina := {}
Private cCadastro := "Transações"

AAdd(aRotina, {"Pesquisar" , "AxPesqui"  , 0, 1})
AAdd(aRotina, {"Visualizar", "u_TM2Manut", 0, 2})
AAdd(aRotina, {"Incluir"   , "u_TM2Manut", 0, 3})
AAdd(aRotina, {"Alterar"   , "u_TM2Manut", 0, 4})
AAdd(aRotina, {"Excluir"   , "u_TM2Manut", 0, 5})

dbSelectArea("SZ2")
dbOrderNickName("NR_IT")
dbGoTop()

mBrowse(,,,,"SZ2")

Return Nil

//----------------------------------------------------------------------------------------------------------------//
User Function TM2Manut(cAlias, nReg, nOpc)

Local cChave := ""
Local nLin
Local i      := 0
Local lRet   := .F.

// Parametros da funcao Modelo2():
// Modelo2(cT, aC, aR, aCGD, nOp, cLinOk, cAllOK, aGetsGD, bF4, cIniCpos, nMax)

Private cT       := "Digitação de Depósitos" // Titulo.
Private aC       := {}                       // Campos do Enchoice.
Private aR       := {}                       // Campos do Rodape.
Private aCGD     := {}                       // Coordenadas do objeto GetDados.
Private cLinOK   := ""                       // Funcao para validacao de uma linha da GetDados.
Private cAllOK   := "u_TM2TudOK()"           // Funcao para validacao de tudo.
Private aGetsGD  := {}                       // Posição para edição dos itens (GetDados).
Private bF4      := {|| }                    // Bloco de Codigo para a tecla F4.
Private cIniCpos := "+Z2_ITEM"               // String com o nome dos campos que devem inicializados
                                             // ao pressionar a seta para baixo.
Private nMax     := 99                       // Nr. maximo de linhas na GetDados.
Private aHeader  := {}                       // Cabecalho das colunas da GetDados.
Private aCols    := {}                       // Colunas da GetDados.
Private nCount   := 0
Private bCampo   := {|nField| FieldName(nField)}
Private aAlt     := {}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Cria variaveis de memoria:                                                                     //
// Para cada campo da tabela, cria uma variavel de memoria com o mesmo nome.                      //
// Estas variaveis sao usadas em validacoes e gatilhos que existirem para este arquivo.           //
////////////////////////////////////////////////////////////////////////////////////////////////////
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

dbSelectArea(cAlias)

For i := 1 To FCount()       // i      -->      1           2           3      ...     9

    cCampo := FieldName(i)   // cCampo --> "Z2_FILIAL"  "Z2_NOME"  "Z2_NUMERO" ... "Z2_APROV"
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

////////////////////////////////////////////////////////////////////////////////////////////////////
// Cria vetor aHeader.                                                                            //
////////////////////////////////////////////////////////////////////////////////////////////////////

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek(cAlias)

While SX3->X3_Arquivo == cAlias .And. !SX3->(EOF())

   If X3Uso(SX3->X3_Usado)    .And.;                            // O Campo é usado.
      cNivel >= SX3->X3_Nivel .And.;                            // Nivel do Usuario >= Nivel do Campo.
      Trim(SX3->X3_Campo) $ "Z2_ITEM/Z2_TIPO/Z2_HIST/Z2_VALOR"  // Campos que ficarao na GetDados.

      AAdd(aHeader, {Trim(SX3->X3_Titulo),;
                     SX3->X3_Campo       ,;
                     SX3->X3_Picture     ,;
                     SX3->X3_Tamanho     ,;
                     SX3->X3_Decimal     ,;
                     SX3->X3_Valid       ,;
                     SX3->X3_Usado       ,;
                     SX3->X3_Tipo        ,;
                     SX3->X3_Arquivo     ,;
                     SX3->X3_Context})
		
   EndIf
	
   SX3->(dbSkip())
	
End

/* Estrutura do aHeader:
Cada elemento do aHeader é, por sua vez, um array contendo as
seguintes informacoes sobre cada campo que irá para a GetDados.
,--------,-------,---------,---------,---------,-------,-------,------,---------,---------,
|   1    |   2   |    3    |    4    |    5    |   6   |   7   |  8   |   9     |   10    |
| Titulo | Campo | Picture | Tamanho | Decimal | Valid | Usado | Tipo | Arquivo | Context |
'--------'-------'---------'---------'---------'-------'-------'------'---------'---------'
,=============================================================================================================================================================================================,
| ,-------------------------------------, ,-------------------------------------, ,-------------------------------------------, ,-----------------------------------------------------------, |
| |"Item","Z2_ITEM",,2,0,,,"C","SZ2","R"| |"Tipo","Z2_TIPO",,1,0,,,"C","SZ2","R"| |"Historico","Z2_HIST",,20,0,,,"C","SZ2","R"| |"Valor","Z2_VALOR","@E 999,999,999.99",12,2,,,"N","SZ2","R"| |
| '-------------------------------------' '-------------------------------------' '-------------------------------------------' '-----------------------------------------------------------' |
'============================================================================================================================================================================================='
*/

////////////////////////////////////////////////////////////////////////////////////////////////////
// Cria o vetor aCols: contem os dados dos campos da tabela.                                      //
// Cada linha de aCols é uma linha da GetDados e as colunas são as colunas da GetDados.           //
// Se a opcao for INCLUIR, cria o vetor aCols com as caracteristicas de cada campo.               //
// Caso contrario, atribui os dados ao vetor aCols.                                               //
////////////////////////////////////////////////////////////////////////////////////////////////////

If nOpc == 3            // A opcao selecionada é INCLUIR.

   /*         ,=============================================================,
     aHeader  |    1.elem.   2.elem.    3.elem.         4.elem.             |
              |  ,---------,---------,-----------,-------------------,      |
   Titulo   1 |  | Item    | Tipo    | Historico | Valor             |      |
   Campo    2 |  | Z2_ITEM | Z2_TIPO | Z2_HIST   | Z2_VALOR          |      |
   Picture  3 |  |         |         |           | @E 999,999,999.99 |      |
   Tamanho  4 |  | 2       | 1       | 20        | 12                |      |
   Decimal  5 |  | 0       | 0       | 0         | 2                 |      |
   Valid    6 |  |         |         |           |                   |      |
   Usado    7 |  |         |         |           |                   |      |
   Tipo     8 |  | C       | C       | C         | N                 |      |
   Arquivo  9 |  | SZ2     | SZ2     | SZ2       | SZ2               |      |
   Context 10 |  | R       | R       | R         | R                 |      |
              |  '---------'---------'-----------'-------------------'      |
              '============================================================='
              ,=============================================================,
              |    [1][1]    [1][2]     [1][3]          [1][4]       [1][5] |
              |  ,---------,---------,-----------,-------------------,---,  |
     aCols[1] |  |         |         |           |                   |   |  |
              |  '---------'---------'-----------'-------------------'---'  |
              '============================================================='*/

   // Como cada elemento de aCols sempre contera um elemento a mais que o aHeader,
   // adiciona em aCols um ARRAY com o "num.elementos de aHeader + 1", ou seja, 5 elementos.
   AAdd(aCols, Array(Len(aHeader)+1))  // aCols[1] --> { Nil, Nil, Nil, Nil, Nil }

   /* Preenche cada elemento desse array, de acordo com o Inicializador-Padrao do Dic.Dados.

   ,===(aCols)=======================================================================================================================================,
   |                                aCols[1]  (Na inclusao, so aCols[1])                                    aCols[2]                                 |
   |   ,---------------,---------------,---------------,---------------,---,   ,---------------,---------------,---------------,---------------,     |
   |   |           1   |           2   |           3   |           4   |   |   |           1   |           2   |           3   |           4   |     |
   |   |  aCols[1][i]  |  aCols[1][i]  |  aCols[1][i]  |  aCols[1][i]  |   |   |  aCols[2][i]  |  aCols[2][i]  |  aCols[2][i]  |  aCols[2][i]  | ... |
   |   '---------------'---------------'---------------'---------------'---'   '---------------'---------------'---------------'---------------'     |
   '================================================================================================================================================='
   ,===(aHeader)=============================================================,
   |             1               2               3               4           |
   |     aHeader[i][2]   aHeader[i][2]   aHeader[i][2]   aHeader[i][2]       |
   |                |               |               |               |        |
   |   ,------------|--,------------|--,------------|--,------------|--,     |
   |   | Item       |  | Tipo       |  | Historico  |  | Valor      |  |     |
   |   | Z2_ITEM <--'  | Z2_TIPO <--'  | Z2_HIST <--'  | Z2_VALOR <-'  |     |
   |   '---------------'---------------'---------------'---------------'     |
   '========================================================================='*/

   For i := 1 To Len(aHeader)
       aCols[1][i] := CriaVar(aHeader[i][2])
   Next
   //  aCols[1][1] := CriaVar("Z2_ITEM" )
   //  aCols[1][2] := CriaVar("Z2_TIPO" )
   //  aCols[1][3] := CriaVar("Z2_HIST" )
   //  aCols[1][4] := CriaVar("Z2_VALOR")

   // Inicializa a ultima coluna para o controle da GetDados: deletado ou nao.
   // aCols[1][5] := .F.
   aCols[1][Len(aHeader)+1] := .F.

   // Inicializa a coluna do ITEM com 01.
   // aCols[1][1] := "01"  <-- teria problema se o usuario alterasse a posicao do
   //                          campo Z2_ITEM no Dic. de Dados. 
   aCols[1][AScan(aHeader, {|x|Trim(x[2])=="Z2_ITEM"})] := "01"

 Else                   // Opcao ALTERAR ou EXCLUIR.

   M->Z2_Numero := (cAlias)->Z2_Numero
   M->Z2_Nome   := (cAlias)->Z2_Nome
   M->Z2_Data   := (cAlias)->Z2_Data

   dbSelectArea(cAlias)
   dbOrderNickName("NOME_NR_IT")  // Z2_Filial + Z2_Nome + Z2_Numero + Z2_Item
   dbSeek(xFilial(cAlias) + M->Z2_Nome + M->Z2_Numero)

   While !EOF() .And. (cAlias)->(Z2_Filial+Z2_Numero) == xFilial(cAlias) + M->Z2_Numero

   /*         ,==================================================================,
     aHeader  |    1.elem.   2.elem.    3.elem.         4.elem.                  |
              |  ,---------,---------,-----------,-------------------,           |
   Titulo   1 |  | Item    | Tipo    | Historico | Valor             |           |
   Campo    2 |  | Z2_ITEM | Z2_TIPO | Z2_HIST   | Z2_VALOR          |           |
   ...        /  /         /         /           /                   /           /
   Context 10 |  | R       | R       | R         | R                 |           |
              |  '---------'---------'-----------'-------------------'           |
              '=================================================================='     aAlt
              ,==================================================================,   ,-------,
              |  ,---------,---------,-----------,-------------------,--------,  |   |       |
     aCols[1] |  | [1][1]  | [1][2]  |  [1][3]   |      [1][4]       | [1][5] |  |   |Recno()| aAlt[1]
              |  '---------'---------'-----------'-------------------'--------'  |   |-------|
              |  ,---------,---------,-----------,-------------------,--------,  |   |       |
     aCols[2] |  | [2][1]  | [2][2]  |  [2][3]   |      [2][4]       | [2][5] |  |   |Recno()| aAlt[2]
              |  '---------'---------'-----------'-------------------'--------'  |   |-------|
              |  ,---------,---------,-----------,-------------------,--------,  |   |       |
     aCols[3] |  | [3][1]  | [3][2]  |  [3][3]   |      [3][4]       | [3][5] |  |   |Recno()| aAlt[3]
              |  '---------'---------'-----------'-------------------'--------'  |   '-------'
              '=================================================================='*/

      // Como cada elemento de aCols sempre contera um elemento a mais que o aHeader,
      // adiciona em aCols um ARRAY com o "num.elementos de aHeader + 1", ou seja, 5 elementos.
      AAdd(aCols, Array(Len(aHeader)+1))  // aCols[1] --> { Nil, Nil, Nil, Nil, Nil }

      nLin := Len(aCols)                  // Nr. da linha que foi criada.

      // Preenche a linha que foi criada com os dados contidos na tabela.
      For i := 1 To Len(aHeader)
          If aHeader[i][10] == "R"                                   // Campo é real.
             aCols[nLin][i] := FieldGet(FieldPos(aHeader[i][2]))     // Carrega o conteudo do campo.
           Else
             // A funcao CriaVar() le as definicoes do campo no dic.dados e carrega a variavel de acordo com
             // o Inicializador-Padrao, que, se nao foi definido, assume conteudo vazio.
             aCols[nLin][i] := CriaVar(aHeader[i][2], .T.)
          EndIf
      Next

      // Inicializa a ultima coluna para o controle da GetDados: deletado ou nao.
      aCols[nLin][Len(aHeader)+1] := .F.

      // Guarda o numero dos registros para controle da gravacao.
      AAdd(aAlt, Recno())

      dbSelectArea(cAlias)
      dbSkip()

   End

EndIf

////////////////////////////////////////////////////////////////////////////////////////////////////
// Cria o vetor Enchoice:                                                                         //
//                                                                                                //
// aC[n][1] = Nome da variavel. Ex.: "Z2_Numero"                                                  //
// aC[n][2] = Array com as coordenadas do Get [x,y], em Pixel.                                    //
// aC[n][3] = Titulo do campo                                                                     //
// aC[n][4] = Picture                                                                             //
// aC[n][5] = Validacao                                                                           //
// aC[n][6] = F3                                                                                  //
// aC[n][7] = Se o campo é editavel, .T., senao .F.                                               //
////////////////////////////////////////////////////////////////////////////////////////////////////

AAdd(aC, { "M->Z2_NUMERO", {20, 10}, "Número", "@!"      ,                              ,      , .F.       })
AAdd(aC, { "M->Z2_NOME"  , {35, 10}, "Nome"  , "@!"      , "ExistCpo('SZ1', Z2_Nome, 1)", "SZ1", (nOpc==3) })
AAdd(aC, { "M->Z2_DATA"  , {35,200}, "Data"  , "99/99/99",                              ,      , (nOpc==3) })

// Coordenadas do objeto GetDados.
aCGD := {75,5,128,280}

// Validacao na mudanca de linha quando clicar no botao OK.
cLinOK := "u_TM2LinOK()"

cTitulo := "Transações Modelo 2"

////////////////////////////////////////////////////////////////////////////////////////////////////
// Executa a funcao Modelo2().                                                                    //
//                                                                                                //
// Parametros da funcao:                                                                          //
// Modelo2(cT, aC, aR, aCGD, nOp, cLinOk, cAllOK, aGetsGD, bF4, cIniCpos, nMax)                   //
////////////////////////////////////////////////////////////////////////////////////////////////////

lRet := Modelo2(cTitulo, aC, aR, aCGD, nOpc, cLinOK, cAllOK, , , cIniCpos, nMax)

If lRet  // Confirmou (.T.)  Nao confirmou (.F.)

   If      nOpc == 3    // Inclusao
           If MsgYesNo("Confirma a gravacao dos dados?", cTitulo)
              // Cria um dialogo com uma regua de progressao.
              Processa({||TM2Inclu(cAlias)}, cTitulo, "Gravando os dados, aguarde...")
           EndIf
    ElseIf nOpc == 4    // Alteracao
           If MsgYesNo("Confirma a alteracao dos dados?", cTitulo)
              // Cria um dialogo com uma regua de progressao.
              Processa({||TM2Alter(cAlias)}, cTitulo, "Alterando os dados, aguarde...")
           EndIf
    ElseIf nOpc == 5    // Exclusao
           If MsgYesNo("Confirma a exclusao dos dados?", cTitulo)
              // Cria um dialogo com uma regua de progressao.
              Processa({||TM2Exclu(cAlias)}, cTitulo, "Excluindo os dados, aguarde...")
           EndIf
   EndIf

Else

   RollBackSX8()

EndIf

Return Nil

//----------------------------------------------------------------------------------------------------------------//
Static Function TM2Inclu(cAlias)

Local i
Local y
Local nNrCampo

ProcRegua(Len(aCols))

dbSelectArea(cAlias)
dbOrderNickName("NR_IT")

For i := 1 To Len(aCols)

    IncProc()

    If !aCols[i][Len(aHeader)+1]  // A linha nao esta deletada, logo, deve ser gravada.

       RecLock(cAlias, .T.)

       For y := 1 To Len(aHeader)
           nNrCampo := FieldPos(Trim(aHeader[y][2]))
           FieldPut(nNrCampo, aCols[i][y])
       Next

       (cAlias)->Z2_Filial := xFilial(cAlias)
       (cAlias)->Z2_Nome   := M->Z2_Nome
       (cAlias)->Z2_Numero := M->Z2_Numero
       (cAlias)->Z2_Data   := M->Z2_Data

       MSUnlock()

       // Atualiza saldo
       dbSelectArea("SZ1")
       dbOrderNickName("NOME")
       dbSeek(xFilial("SZ1")+SZ2->Z2_Nome)
       RecLock("SZ1", .F.)
       If SZ2->Z2_Tipo == "D"
          SZ1->Z1_Saldo := SZ1->Z1_Saldo + SZ2->Z2_Valor
       Else
          SZ1->Z1_Saldo := SZ1->Z1_Saldo - SZ2->Z2_Valor
       EndIf
       MSUnlock()

    EndIf

Next

ConfirmSX8()

Return Nil

//----------------------------------------------------------------------------------------------------------------//
Static Function TM2Alter(cAlias)

Local i
Local y
Local nNrCampo

ProcRegua(Len(aCols))

dbSelectArea(cAlias)
dbOrderNickName("NR_IT")

For i := 1 To Len(aCols)
	
    If i <= Len(aAlt)
		
       // aAlt contem os Recno() dos registros originais.
       // O usuario pode ter incluido mais registros na GetDados (aCols).
		
       dbSelectArea("SZ2")
       dbGoTo(aAlt[i])  // Posiciona no registro.

       If aCols[i][Len(aHeader)+1]     // A linha esta deletada.

          // Desatualiza
          dbSelectArea("SZ1")
          dbSeek(xFilial("SZ1")+SZ2->Z2_Nome)
          RecLock("SZ1", .F.)
          If SZ2->Z2_Tipo == "D"
             SZ1->Z1_Saldo := SZ1->Z1_Saldo - SZ2->Z2_Valor
          Else
             SZ1->Z1_Saldo := SZ1->Z1_Saldo + SZ2->Z2_Valor
          EndIf
          MSUnlock()

          // E depois deleta o registro correspondente.
          RecLock(cAlias, .F.)
          SZ2->(dbDelete())

       Else                            // A linha nao esta deletada.

          // Desatualiza
          dbSelectArea("SZ1")
          dbSeek(xFilial("SZ1")+SZ2->Z2_Nome)
          RecLock("SZ1", .F.)
          If SZ2->Z2_Tipo == "D"
             SZ1->Z1_Saldo := SZ1->Z1_Saldo - SZ2->Z2_Valor
           Else
             SZ1->Z1_Saldo := SZ1->Z1_Saldo + SZ2->Z2_Valor
          EndIf
          MSUnlock()
              
          // Regrava os dados.
          RecLock("SZ2", .F.)

          For y := 1 To Len(aHeader)
              nNrCampo := FieldPos(Trim(aHeader[y][2]))
              FieldPut(nNrCampo, aCols[i][y])
          Next

          SZ2->(MSUnlock())

          // Atualiza
          dbSelectArea("SZ1")
          dbSeek(xFilial("SZ1")+SZ2->Z2_Nome)
          RecLock("SZ1", .F.)
          If SZ2->Z2_Tipo == "D"
             SZ1->Z1_Saldo := SZ1->Z1_Saldo + SZ2->Z2_Valor
           Else
             SZ1->Z1_Saldo := SZ1->Z1_Saldo - SZ2->Z2_Valor
          EndIf
          MSUnlock()

       EndIf

    Else     // Foram incluidas mais linhas na GetDados (aCols), logo, precisam ser incluidas.

       If !aCols[i][Len(aHeader)+1]

          RecLock(cAlias, .T.)

          For y := 1 To Len(aHeader)
              nNrCampo := FieldPos(Trim(aHeader[y][2]))
              FieldPut(nNrCampo, aCols[i][y])
          Next

          (cAlias)->Z2_Filial := xFilial(cAlias)
          (cAlias)->Z2_Nome   := M->Z2_Nome
          (cAlias)->Z2_Numero := M->Z2_Numero
          (cAlias)->Z2_Data   := M->Z2_Data

          MSUnlock()

          // Atualiza saldo

          dbSelectArea("SZ1")
          dbOrderNickName("NOME")
          dbSeek(xFilial("SZ1")+SZ2->Z2_Nome)
          RecLock("SZ1", .F.)
          If SZ2->Z2_Tipo == "D"
             SZ1->Z1_Saldo := SZ1->Z1_Saldo + SZ2->Z2_Valor
          Else
             SZ1->Z1_Saldo := SZ1->Z1_Saldo - SZ2->Z2_Valor
          EndIf
          MSUnlock()

       EndIf

    EndIf

Next

Return Nil

//----------------------------------------------------------------------------------------------------------------//
Static Function TM2Exclu(cAlias)

ProcRegua(Len(aCols))

dbSelectArea(cAlias)
dbOrderNickName("NOME_NR_IT")
dbSeek(xFilial(cAlias) + M->Z2_Nome + M->Z2_Numero)

While !Eof() .And. (cAlias)->Z2_Filial == xFilial(cAlias) .And. (cAlias)->Z2_Numero == M->Z2_Numero

   // Nao precisa testar o nome pois numero e' chave primária.

   IncProc()

   // Desatualiza
   dbSelectArea("SZ1")
   dbSeek(xFilial()+SZ2->Z2_Nome)
   RecLock("SZ1", .F.)
   If SZ2->Z2_Tipo == "D"
      SZ1->Z1_Saldo := SZ1->Z1_Saldo - SZ2->Z2_Valor
   Else
      SZ1->Z1_Saldo := SZ1->Z1_Saldo + SZ2->Z2_Valor
   EndIf
   MSUnlock()

   RecLock(cAlias, .F.)
   dbDelete()
   MSUnlock()

   dbSelectArea("SZ2")
   dbSkip()

End

Return Nil

//----------------------------------------------------------------------------------------------------------------//
// Valida todas as linhas da GetDados ao confirmar a gravaçao.
//----------------------------------------------------------------------------------------------------------------//
User Function TM2TudOK()

Local lRet := .T.
Local i    := 0
Local nDel := 0

For i := 1 To Len(aCols)
    If aCols[i][Len(aHeader)+1]
       nDel++
    EndIf
Next

If nDel == Len(aCols)
   MsgInfo("Para excluir todos os itens, utilize a opção EXCLUIR", cTitulo)
   lRet := .F.
EndIf

Return lRet

//----------------------------------------------------------------------------------------------------------------//
// Valida a linha atual da GetDados ao teclar seta para baixo ou para cima para a mudança de linha.
//----------------------------------------------------------------------------------------------------------------//
User Function TM2LinOK()

// ***EXERCICIO*** Desenvolva uma rotina para nao aceitar valor acima do parametro MV_VRMAX.

Return .T.
