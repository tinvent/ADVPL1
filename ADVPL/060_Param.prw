// Passagem de parametros por Valor e por Referencia.

User Function Param1()

Local x := 1
Local y := 2

u_Param2(x, y)
MsgAlert(x+y)

u_Param2(@x, y)
MsgAlert(x+y)

Return



User Function Param2(x, y)

x := 50
y := 100

Return
