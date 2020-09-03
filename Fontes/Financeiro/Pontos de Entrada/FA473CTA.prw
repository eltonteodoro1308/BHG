#include "totvs.ch"

/*/{Protheus.doc} Fa473Cta
Ponto de entrada que ajusta o banco, agencia e conta de busca que s�o diferentes do que � retornado da leitura do arquivo.
Foi implementado para diferenciar no banco it�u o que � de conta de aplica��o e o que � conta de movimento
O layout 'itau.rec' l� o que corresponde a Conta Banc�ria da posi��o 33 a 70
O Ponto de Entrada na vari�vel PARAMAMIXB[3] verifica da posi��o 1 a 4 se est� em branco que indica que a conta � de livre movimento e
se vier preenchido indica que � uma conta de investimento e assim define para qual conta banc�ria ir� os registros do arquivo.
@type user function
@version 12.1.25
@author elton.alves@totvs.com.br
@since 16/07/2020
@return array, Array composto por { banco, agencia, conta } que ser�o utilizadas para incluir os dados do extrato
/*/
user function Fa473Cta()

    Local cBanco   := PARAMIXB[ 1 ]
    Local cAgencia := PARAMIXB[ 2 ]
    Local cConta   := PARAMIXB[ 3 ]
    Local aRet     := {}

    if cBanco == '341'

        if ! Empty( SubStr( cConta, 1, 4 ) )

            cConta := SubStr( cConta, 34, 5 ) + 'APLFI'

        else

            cConta := SubStr( cConta, 34, 5 )

        end if

    end if

    aRet := { cBanco, cAgencia, cConta }

return aRet
