#include 'totvs.ch'

/*/{Protheus.doc} MA140BUT
Inclus�o de bot�es na EnchoiceBar da rotina de recebimento de Pr�-Nota
@type user function (Ponto de Entrada)
@version 12.1.27
@author elton.alves@totvs.com.br
@since 15/08/2020
@return array, Array com as rotinas a serem inclu�das
/*/
User Function MA140BUT()

    Local bBlock := { || U_140NMPRD() }

    // Define que a rotina pode ser chamada pela tecla F7
    SetKey( VK_F7, bBlock )

Return {{ "", bBlock, "Busca Nome dos Produtos" }}

/*/{Protheus.doc} 140NMPRD
Rotina que preenche o campo D1_XDESCRI com a descri��o do produto da linah posicionada.
@type user function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 15/08/2020
/*/
user function 140NMPRD()

    Local nX := 1

    // Verifica se a chamada da fun��o MATA140 e que a vari�vel aCols existe para buscar o nome dos produtos
    if IsInCallStack( 'MATA140' ) .and. Type('aCols') == 'A'

        For nX := 1 To Len( aCols )

            aCols[nX][GDFieldPos('D1_XDESCRI')] := Posicione('SB1',1,xFilial('SB1')+aCols[nX][GDFieldPos('D1_COD')],'B1_DESC')

        next nX

    end if

return
