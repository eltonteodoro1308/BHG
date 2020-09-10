#include "totvs.ch"

/*/{Protheus.doc} Fa473Cta
Ponto de entrada que ajusta o banco, agencia e conta de busca que s�o diferentes do que � retornado da leitura do arquivo.
Foi implementado para diferenciar no banco it�u o que � de conta de aplica��o e o que � conta de movimento
O layout 'itau.rec' l� o que corresponde a Conta Banc�ria da posi��o 33 a 70
O Ponto de Entrada na vari�vel PARAMAMIXB[3] verifica da posi��o 1 a 4 se est� em branco que indica que a conta � de livre movimento e
se vier preenchido indica que � uma conta de investimento e busca no campo A6_XCTAPLC a conta de aplica��o correspondente.
@type user function
@version 12.1.25
@author elton.alves@totvs.com.br
@since 16/07/2020
@return array, Array composto por { banco, agencia, conta } que ser�o utilizadas para incluir os dados do extrato
/*/
user function FA473CTA()

    Local cBanco   := PadR( PARAMIXB[ 1 ], TamSx3( 'A6_COD'     )[ 1 ] )
    Local cAgencia := PadR( PARAMIXB[ 2 ], TamSx3( 'A6_AGENCIA' )[ 1 ] )
    Local cConta   := PadR( SubStr( PARAMIXB[ 3 ], 034, 005 ), TamSx3( 'A6_NUMCON' )[ 1 ] )
    Local cTpConta := SubStr( PARAMIXB[ 3 ], 001, 004 )
    Local aRet     := {}

    if ! Empty( cTpConta )

        cConta := Posicione('SA6', 1, cFilAnt + cBanco + cAgencia + cConta, 'A6_XCTAPLC' )

    end if

    aRet := { cBanco, cAgencia, cConta }

return aRet
