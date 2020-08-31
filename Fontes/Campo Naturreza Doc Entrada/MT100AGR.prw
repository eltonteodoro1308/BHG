#include 'totvs.ch'

/*/{Protheus.doc} MT100AGR
Após toda gravação das tabelas correspondentes a Nota de Entrada,
grava no cabeçalho na tabela SF1 a natureza no campo F1_XNATURE
para que no lançamento padrão de estorno de documento de entrada
posso ser verificado se a nota tem ou não ISS retido  
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
