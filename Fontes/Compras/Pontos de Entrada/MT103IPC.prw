#include 'totvs.ch'

/*/{Protheus.doc} MT103IPC
Este Ponto de Entrada tem por objetivo atualizar os campos customizados no Documento de Entrada e na Pré Nota de Entrada após a importação dos itens do Pedido de Compras (SC7).
@type user function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 31/08/2020
@return logico, Fixo .F. para que a TES seja substituida pela TES informada no Pedido de Compras
/*/
user function MT103IPC()

    Local nPos := PARAMIXB[1]

    aCols[nPos][GDFieldPos('D1_XDESCRI')] := Posicione('SB1',1,xFilial('SB1')+aCols[nPos][GDFieldPos('D1_COD')],'B1_DESC')

return .F.
