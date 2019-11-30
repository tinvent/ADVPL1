//----------------------------------------------------------------------------------------------------------------//
// Demonstracao do Do Case...EndCase.
// Do Case...EndCase --> avalia a partir do primeiro Case.
//                       Ao encontrar o primeiro que satisfaça,
//                       a condiçao, executa e vai para o EndCase.
//----------------------------------------------------------------------------------------------------------------//

User Function TstCase()

Local nOpc := 2


Do Case
   Case nOpc == 1
        MsgAlert("Opção 1 selecionada")
   Case nOpc == 2
        MsgAlert("Opção 2 selecionada")
   Case nOpc == 3
        MsgAlert("Opção 3 selecionada")
   Otherwise
        // Otherwise é opcional.
        MsgAlert("Nenhuma opção selecionada")
EndCase

Return


/*

Do Case
   Case Clima == "CHUVOSO"
        LEVAR GUARDA-CHUVA
   Case Temperatura == "FRIO"
        LEVAR AGASALHO
EndCase

Se estiver chovendo e quente?
Se estiver ensolarado e frio?
Se estiver chovendo e frio?

*/