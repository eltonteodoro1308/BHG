#include 'totvs.ch'

user function TstRest()

    Local cUser := 'bhg-api'
    Local cKey := 'KkJ3THNPk2h8'
    Local cBasic := Encode64(cUser + ':' +cKey)
    Local oFwRest := FWRest():New( 'https://api.sienge.com.br' )
    Local aHeader := {}

    aadd(aHeader,'Authorization: Basic ' + cBasic)

    oFwRest:SetPath( '/bhg/public/api/v1/purchase-orders' )

    If oFwRest:Get( aHeader, '?limit=200&offset=5000' )
        autogrlog( oFwRest:GetResult() )
    Else
        autogrlog( oFwRest:GetLastError() )
    End If

    MostraErro()

return

// #include 'totvs.ch'
// 
// user function TstRest()
// 
//     oFwRest := FWRest():New( 'https://api.sienge.com.br' )
// 
//     oFwRest:SetPath( '/bhg/public/api/v1/purchase-orders' )
// 
//     aHeaders := {}
// 
//     aAdd( aHeaders, { 'Accept-Encoding: gzip, deflate, br' } )
//     aAdd( aHeaders, { 'Accept-Language: pt-BR,pt;q=0.8,en-US;q=0.5,en;q=0.3' } )
//     aAdd( aHeaders, { 'Connection: keep-alive' } )
//     aAdd( aHeaders, { 'Upgrade-Insecure-Requests: 1' } )
//     aAdd( aHeaders, { 'Cache-Control: no-cache' } )
//     aAdd( aHeaders, { 'Host: api.sienge.com.br' } )
//     aAdd( aHeaders, { 'Accept: */*' } )
//     aAdd( aHeaders, { 'Authorization: Basic ' + Encode64('bhg-api:KkJ3THNPk2h8') } )
// 
//     If oFwRest:Get( aHeaders )
// 
//         AutoGrLog( oFwRest:GetResult() )
// 
//     Else
// 
//         AutoGrLog( oFwRest:GetLastError() )
// 
//     End If
// 
//     MostraErro()
// 
// return
