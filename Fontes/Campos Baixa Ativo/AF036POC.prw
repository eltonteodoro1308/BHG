#include 'totvs.ch'

/*/{Protheus.doc} AF036POC
Após gravação da baixa de ativo grava o conteúdo de campos customizados.
@type user function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 28/08/2020
/*/
user function AF036POC()

    Local oModel  := FWModelActive()
    Local cConta  := oModel:GetValue('FN6MASTER','FN6_XCONTA')
    Local cCCusto := oModel:GetValue('FN6MASTER','FN6_XCUSTO')
    Local cItemCt := oModel:GetValue('FN6MASTER','FN6_XITEM' )

    RecLock("FN6",.F.)

    FN6->FN6_XCONTA := cConta
    FN6->FN6_XCUSTO := cCCusto
    FN6->FN6_XITEM  := cItemCt

    FN6->( MsUnLock() )

return
