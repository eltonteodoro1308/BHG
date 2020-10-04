/*/{Protheus.doc} MT120BRW
Adiciona bot�es � rotina de Pedido de Compras
@type User Function (Ponto de Entrada) 
@version 12.1.27
@author elton.alves
@since 10/08/2020
/*/
User Function MT120BRW()

    Local aMenuSienge := {}

    // Rotina de Importa��o de Pedidos de Compras do SIENGE (Fonte SIENGE.prw)
    aAdd( aMenuSienge, { 'Pedido de Compras', 'U_SIENGEPC()', 0, 3 } )
   
    // Rotina de Importa��o de Servi�os do SIENGE (Fonte SIENGE.prw)
    aAdd( aMenuSienge, { 'Servi�os'         , 'U_SIENGESV()', 0, 3 } )

    AAdd( aRotina, { 'Integra�ao Sienge', aMenuSienge, 0, 3 } )

Return
