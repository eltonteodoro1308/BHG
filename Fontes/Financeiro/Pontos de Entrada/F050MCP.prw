#include 'totvs.ch'

/*/{Protheus.doc} F050MCP
O ponto de entrada F050MCP permite incluir novos campos na opção Alterar da rotina FINA050.
Será executado ao exibir a tela após clicar no botão Alterar da rotina FINA050.
Desta forma, os campos que forem incluídos por este Ponto de Entrada também poderão ser editados na opção Alterar.
@type user function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 09/09/2020
@return array, Array contendo os campos que serão permitidos alterar
/*/
user function F050MCP()

    local aRet := {}

    aAdd( aRet, 'E2_ITEMCTA' )
    aAdd( aRet, 'E2_CCUSTO'  )

return aRet
