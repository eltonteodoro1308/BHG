#include 'totvs.ch'

/*/{Protheus.doc} F050MCP
O ponto de entrada F050MCP permite incluir novos campos na op��o Alterar da rotina FINA050.
Ser� executado ao exibir a tela ap�s clicar no bot�o Alterar da rotina FINA050.
Desta forma, os campos que forem inclu�dos por este Ponto de Entrada tamb�m poder�o ser editados na op��o Alterar.
@type user function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 09/09/2020
@return array, Array contendo os campos que ser�o permitidos alterar
/*/
user function F050MCP()

    local aRet := {}

    aAdd( aRet, 'E2_ITEMCTA' )
    aAdd( aRet, 'E2_CCUSTO'  )

return aRet
