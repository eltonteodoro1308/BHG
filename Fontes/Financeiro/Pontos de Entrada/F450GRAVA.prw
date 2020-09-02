#include 'totvs.ch'

/*/{Protheus.doc} F450GRAVA
O ponto de Entrada F450GRAVA permite manipular os dados da tabela temporária "TRB".
Na tabela "TRB" são armazenados os títulos que serão exibidos na tela de seleção da rotina Compensação entre Carteiras (FINA450).
Este PE foi implementado para que na coluna "Tìtulo" fosse identificado a Filial.
@type user function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 02/09/2020
/*/
user function F450GRAVA()

    Local cTabela := PARAMIXB[1]

    RecLock("TRB",.F.)

    if cTabela == 'SE1'

        TRB->TITULO := SE1->( E1_FILIAL + '-' + E1_PREFIXO + '-' + E1_NUM )

    elseif cTabela == 'SE2'

        TRB->TITULO := SE2->( E2_FILIAL + '-' + E2_PREFIXO + '-' + E2_NUM )

    end if

    TRB->( MsUnlock() )

Return
