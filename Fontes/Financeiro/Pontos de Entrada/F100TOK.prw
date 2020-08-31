#include 'totvs.ch'

/*/{Protheus.doc} F100TOK
Validar daros da movimentação bancária
@type user function (Ponto de Entrada)
@version 12.1.27
@author elton.alves@totvs.com.br
@since 15/08/2020
@return lógico, retorna indicando se o movimento é válido ou não
/*/
user function F100TOK()

    if ( IsInCallStack( 'FA100PAG' ) .And. Empty( M->E5_ITEMD ) );
            .Or. ( IsInCallStack( 'FA100REC' ) .And. Empty( M->E5_ITEMC ) )

        ApMsgStop( 'Informe o Item contábil para gravar a Movimentação Bancária' )

        return .F.

    end if

return .T.
