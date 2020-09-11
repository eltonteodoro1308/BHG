#include 'totvs.ch'

/*/{Protheus.doc} F070ACONT
Ponto de Entrada chamado antes da contabilização
Implementado para que a data da baixa seja a data da contabilização da Baixa. 
@type user function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 10/09/2020
/*/
user function F070ACONT()

    dDataBase := dBaixa

return
