//----------------------------------------------------------------------------------------------------------------// 
// Teste de Comandos Definidos pelo Usuario.
//----------------------------------------------------------------------------------------------------------------// 

// Sem o uso de constantes #define.
User Function TstUDC1()

Local i
Local aArray := {{"Joao",25,.T.,"4567-9876",2}, {"Maria",30,.F.,"9517-6541",0}, {"Jose",18,.T.,"6348-7537",3}}

For i := 1 To Len(aArray)

    MsgAlert(aArray[i, 1])
    MsgAlert(aArray[i, 4])
    MsgAlert(aArray[i, 2])
    MsgAlert(aArray[i, 3])
    MsgAlert(aArray[i, 5])

Next

Return

//----------------------------------------------------------------------------------------------------------------// 
// A mesma rotina, mas com o uso das constantes #define.
//----------------------------------------------------------------------------------------------------------------// 
#define __NOME     1
#define __IDADE    2
#define __ESTCIVIL 3
#define __FONE     4
#define __NRDEPEND 5

User Function TstUDC2()

Local i
Local aArray := {{"Joao",25,.T.,"4567-9876",2}, {"Maria",30,.F.,"9517-6541",0}, {"Jose",18,.T.,"6348-7537",3}}

For i := 1 To Len(aArray)

                                       // O pre-processador substitui o nome da
                                       // constante pelo seu valor, resultando
                                       // no seguinte programa-fonte:
    MsgAlert(aArray[i, __NOME    ])    // MsgAlert(aArray[i, 1 ])
    MsgAlert(aArray[i, __FONE    ])    // MsgAlert(aArray[i, 4 ])
    MsgAlert(aArray[i, __IDADE   ])    // MsgAlert(aArray[i, 2 ])
    MsgAlert(aArray[i, __ESTCIVIL])    // MsgAlert(aArray[i, 3 ])
    MsgAlert(aArray[i, __NRDEPEND])    // MsgAlert(aArray[i, 5 ])

Next

Return

//----------------------------------------------------------------------------------------------------------------// 
// Substituicao de comandos por constantes #define.
//----------------------------------------------------------------------------------------------------------------// 
#define Para    For
#define Ate     To
#define Proximo Next
#define Mostre  MsgAlert

User Function TstUDC3()

Para i := 1 Ate 5
     Mostre(i)
Proximo

Return

//----------------------------------------------------------------------------------------------------------------// 
// Demonstracao do #IfDef.
//----------------------------------------------------------------------------------------------------------------// 
#define BRASIL                   // Programa-fonte resultante com    // e sem a constante:               //
                                 // a constante BRASIL definida:     //                                  //
                                 //                                  //                                  //
User Function TstUDC4()          // User Function TstUDC4()          // User Function TstUDC4()          //
                                 //                                  //                                  //
#IfDef BRASIL                    //                                  //                                  //
   Local cPais                   //    Local cPais                   //                                  //
   Local cLingua                 //    Local cLingua                 //                                  //
   cPais   := "Brasil"           //    cPais   := "Brasil"           //                                  //
   cLingua := "Portugues"        //    cLingua := "Portugues"        //                                  //
 #Else                           //                                  //                                  //
   Local cPais                   //                                  //    Local cPais                   //
   cPais := "Argentina"          //                                  //    cPais := "Argentina"          //
#EndIf                           //                                  //                                  //
                                 //                                  //                                  //
MsgAlert(cPais + "/" + cLingua)  // MsgAlert(cPais + "/" + cLingua)  // MsgAlert(cPais + "/" + cLingua)  //
                                 //                                  //                                  //
Return Nil                       // Return Nil                       // Return Nil                       //

//----------------------------------------------------------------------------------------------------------------// 
// Demonstracao do #Include.
//----------------------------------------------------------------------------------------------------------------// 
#Include "080_UDC.CH"

User Function TstUDC5()

MsgAlert(STR0001 + "Jose")
MsgAlert(STR0002 + "Rua das Flores, 100")
MsgAlert(STR0003 + "9999-8888")

Return

//----------------------------------------------------------------------------------------------------------------// 
// Demonstracao do #Command.
// Para testar:
//   -coloque um break-point na linha do Return.
//   -em Comandos, chame a funcao, ora passando um parametro, ora sem passar paramentro.
//
// No PROTHEUS.CH:
//
//   #command DEFAULT <uVar1> := <uVal1>                        ;
//          =>                                                  ;
//            <uVar1> := If( <uVar1> == Nil, <uVal1>, <uVar1> )
//----------------------------------------------------------------------------------------------------------------// 

User Function TstUDC6(xParam)

DEFAULT xParam := "Teste"    //==>  xParam := If(xParam == Nil, "Teste", xParam)

MsgAlert(xParam)

Return
