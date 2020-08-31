#include 'totvs.ch'

/*/{Protheus.doc} MT100AGR
Ap�s toda grava��o das tabelas correspondentes a Nota de Entrada,
grava no cabe�alho na tabela SF1 a natureza no campo F1_XNATURE
para que no lan�amento padr�o de estorno de documento de entrada
posso ser verificado se a nota tem ou n�o ISS retido  
@type user function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 28/08/2020
/*/
user function MT100AGR()

    if INCLUI .Or. ALTERA

        RecLock( 'SF1', .F.)

        SF1->F1_XNATURE := MaFisRet(,"NF_NATUREZA")

        SF1->( MsUnlock() )

    end if

return
