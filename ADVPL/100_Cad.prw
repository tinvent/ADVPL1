// Função de manutenção do Cadastro de Contas.
// Utiliza a função pre-definida AxCadastro(), que contem todas as funcionalidades: inclusão, alteração, exclusão e pesquisa.
// Parametros que devem ser passados:
//    1) Alias do arquivo a ser editado.
//    2) Titulo da janela.
//    3) Nome da função a ser executada para validar uma exclusao.
//    4) Nome da função a ser executada para validar uma inclusao ou alteração.

User Function Cad()

Local cVldAlt := ".T."        // Validacao da inclusao/alteracao.
Local cVldExc := "u_VldExc()" // Validacao da exclusao.

AxCadastro("SZ1", "Cadastro de Contas", cVldExc, cVldAlt)

Return Nil                            

//----------------------------------------------------------------------------//
// Validacao da exclusao. Verifica se existe alguma transação desta
// conta no arq. SZ2. Caso exista, nao permite excluir a conta.
//----------------------------------------------------------------------------//
User Function VldExc()

dbSelectArea("SZ2")
dbOrderNickName("NOME_NR_IT")
If dbSeek(xFilial("SZ2") + SZ1->Z1_Nome)
   MsgAlert("Esta conta nao pode ser excluida!")
   Return .F.
EndIf

Return .T.
