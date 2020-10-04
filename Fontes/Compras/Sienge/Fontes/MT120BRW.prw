/*/{Protheus.doc} MT120BRW
Adiciona botões à rotina de Pedido de Compras
@type User Function (Ponto de Entrada) 
@version 12.1.27
@author elton.alves
@since 10/08/2020
/*/
User Function MT120BRW()

    Local aMenuSienge := {}

    // Rotina de Importação de Pedidos de Compras do SIENGE (Fonte SIENGE.prw)
    aAdd( aMenuSienge, { 'Pedido de Compras', 'U_SIENGEPC()', 0, 3 } )
   
    // Rotina de Importação de Serviços do SIENGE (Fonte SIENGE.prw)
    aAdd( aMenuSienge, { 'Serviços'         , 'U_SIENGESV()', 0, 3 } )

    AAdd( aRotina, { 'Integraçao Sienge', aMenuSienge, 0, 3 } )

Return
