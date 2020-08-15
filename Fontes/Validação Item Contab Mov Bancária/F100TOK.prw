#include 'totvs.ch'

/*/{Protheus.doc} F100TOK
Validar daros da movimenta��o banc�ria
@type user function (Ponto de Entrada)
@version 12.1.27
@author elton.alves@totvs.com.br
@since 15/08/2020
@return l�gico, retorna indicando se o movimento � v�lido ou n�o
/*/
user function F100TOK()

    if ( IsInCallStack( 'FA100PAG' ) .And. Empty( M->E5_ITEMD ) );
            .Or. ( IsInCallStack( 'FA100REC' ) .And. Empty( M->E5_ITEMC ) )

        ApMsgStop( 'Informe o Item cont�bil para gravar a Movimenta��o Banc�ria' )

        return .F.

    end if

return .T.
