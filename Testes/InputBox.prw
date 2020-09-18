#include "protheus.ch"

User function InputBox()
    Local oError := ErrorBlock({|e|ChecErro(e)}) //Para exibir um erro mais amigável
    Local cRetorno := ""
    Local nRetorno := 0

    cRetorno := FWInputBox("Informe o texto", "")

    MsgInfo(cRetorno)

    //ou

    Begin Sequence
        nRetorno := Val(FWInputBox("Escolha um numero [1-100]:", ""))    
        nRetorno += 10
        MsgInfo( cValToChar(nRetorno) ) //O retorno será o valor inserido mais 10
    End Sequence

    ErrorBlock(oError)

Return
