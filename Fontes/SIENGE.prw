#include 'totvs.ch'

/*/{Protheus.doc} Sienge
Rotina a ser utilizada no schedule que ir� buscar no Web Service do SIENGE para buscar os dados dos pedidos de compras e
adiantamento a fornecedrores e ir� incluir estes dados no protheus, vinculando o adiantamento ao seu pedido de compras 
correspondenete.
@type user function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 07/07/2020
@param aParam, array, Parametros enviados pelo schedule
@obs O array de par�metros enviado pelo schedule tem a seguinte estrutura:
aParam[ 1 ] => Empresa associada ao agendamento da rotina
aParam[ 2 ] => Filial associada ao agendamento da rotina
aParam[ 3 ] => Usu�rio associado ao agendamento
aParam[ 4 ] => Id do agendamento
/*/
user function Sienge( aParam )

    Default aParam := { '01', '010001' }

    //If RpcSetEnv( '01', '010001' )
    if RpcSetEnv( aParam[ 1 ], aParam[ 2 ] )

        // Par�metros utilizados por todos os End Points dos Web Service do SIENGE
        Private cUrl       := 'https://api.sienge.com.br'
        Private cUser      := 'bhg-api'
        Private cPassWord  := 'KkJ3THNPk2h8'
        Private aHeader    := { 'Authorization: Basic ' + Encode64( cUser + ':' + cPassWord ) }
        Private cSubDomain := '/bhg/'
        Private cVersion   := '/v1/'
        Private cPrefix    := cSubDomain + 'public/api' + cVersion

        GetPedidos()

        GetAdiant()

        RpcClearEnv()

    else

        MyConOut( 'N�o Foi Poss�vel Logar na Empresa/Filial => ' + aParam[ 1 ] + '/' + aParam[ 2 ] )

    endif

return

/*/{Protheus.doc} GetPedidos
Busca no SIENGE os pedidos de compras 
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 07/07/2020
@obs Depend�ncia do par�metro SIE_PEDREF que define a data que ser� feita a consulta sendo incrementada at� o dia seguinte a data corrente
/*/
static function GetPedidos()

    Local cPath      := cPrefix + 'purchase-orders'
    Local oFwRest    := nil
    Local oJson      := nil
    Local cRet       := ''
    Local nX         := 0
    Local dDateRef   := GetMv( 'SIE_PEDREF' )
    Local cYearRef   := cValToChar( Year( dDateRef )  )
    Local cMonthRef  := StrZero( Month( dDateRef ), 2 )
    Local cDayRef    := StrZero( Day( dDateRef ), 2 )
    Local cStartDate := cYearRef + '-' + cMonthRef + '-' +cDayRef // formato yyyy-MM-dd
    Local cEndDate   := cStartDate // formato yyyy-MM-dd
    Local nLimit     := 200
    Local nOffSet    := 0
    Local nCount     := 0
    Local cGetParam  := ''
    Local aListaPC   := {}

    Do While .T.

        oFwRest := FWRest():New( cUrl )

        oFwRest:SetPath( cPath )

        cGetParam += '?limit='
        cGetParam += cValToChar( nLimit )
        cGetParam += '&offset='
        cGetParam += cValToChar( nLimit * nOffSet )
        cGetParam += '&startDate='
        cGetParam += cStartDate
        cGetParam += '&endDate='
        cGetParam += cEndDate

        if oFwRest:Get( aHeader, cGetParam )

            oJson := JsonObject():New()

            cRet := oJson:FromJSON( oFwRest:GetResult() )

            if Empty( cRet )

                iif( nCount == 0, nCount := oJson["resultSetMetadata"]["count"], nil )

                For nX := 1 to Len( oJson["results"] )

                    GetListaPC( @aListaPC, oJson["results"][nX] )

                Next nX

            else

                MyConOut( 'N�o Foi Poss�vel Montar o JSON da consulta de pedidos de compras Erro => ' + cRet )

                Exit

            endif

        else

            MyConOut( 'N�o Foi Poss�vel consultar os Pedidos de Compras Erro => ' + oFwRest:GetLastError() )

            Exit

        endif

        nOffSet++
        cGetParam := ''
        FreeObj( oJson   )
        FreeObj( oFwRest )

        If ( nLimit * nOffSet ) > Int( ( nCount / nLimit ) ) //+ If( Mod( nCount, nLimt ) > 0, 1, 0 )

            Exit

        End If

    End Do

    GravaPedidos( aListaPC )

return

/*/{Protheus.doc} GetListaPC
Monta o array com a lista de dados do cabe�alho e dos itens do pedido de compra adiciona na lista de pedidos a serem inclu�dos na base.
� verificado:
- Se o pedido j� n�o existe na base verificando o campos C7_XNUMSIE
- Se o fornecedor est� cadastrado verificando seu CNPJ
- Se a condi��o de pagamento est� cadastrada verificando o campo E4_XSIENGE
- Se os produtos s�o est�o cadastrados verificando o campo B1_XSIENGE
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 09/07/2020
@param aListaPC, array, Par�metro recebido por refer�ncia a ser populado com os dados de cabe�alho e lista itens do Pedido de Compras
@param oJsonCabec, object, Objeto Json com os dados do cabe�alho do Pedido de Compras
/*/
static function GetListaPC( aListaPC, oJsonCabec )

    Local aArea     := GetArea()
    Local cIdPedido := cValTochar( oJsonCabec['id'] )
    Local cIdCondic := cValtoChar( 1 ) 
    Local cIdFornec := cValTochar( oJsonCabec['supplierId'] )
    Local dEmissao  := StoD( StrTran( oJsonCabec['date'], '-', '' ) )
    Local cNum      := ''
    Local cTpFrete  := 'C' 
    Local nFrete    :=  oJsonCabec['increase']

    Private cCodForn := ''
    Private cCodLoja := ''
    Private cCondic  := ''
    // TODO Pedidos vindo do sienge com centros de custos nao cadastrados ou sinteticos
    Private cCC      := '99999' //cValTochar( oJsonCabec['costCenterId'] )
    // TODO Pedidos vindo do sienge com itens contabeis nao cadastrados ou sinteticos
    // TODO buildingId e equivalente a Item contabil ?
    Private cItCtb   := ''// cValTochar( oJsonCabec['buildingId'] )
    //Private aItens    := {}

    // Verifica se Pedido j� est� na cadastrado
    DbSelectArea( 'SC7' )
    SC7->( DBOrderNickname( 'NUMSIENGE' ) ) // C7_FILIAL+C7_XNUMSIE
    if ! SC7->( DbSeek( xFilial() + cIdPedido ) )

        // Verifica se Condi��o de Pagamento est� cadastrada
        DbSelectArea( 'SE4' )
        SE4->( DBOrderNickname( 'CODSIENGE' ) ) // E4_FILIAL+E4_XSIENGE
        if SE4->( DbSeek( xFilial() + cIdCondic ) )

            cCondic := SE4->E4_CODIGO

            // Verifica se fornecedor est� cadastrado e em caso positivo popula as vari�veis de C�digo e Loja
            if BuscaForn( cIdFornec )

                // Busca itens do pedido e se os mesmos exitirem no cadastro de produtos popula aListaPC com dados de Cabe�alho e Itens
                If GetItens( cIdPedido, @aListaPC )

                    cNum := NextNumero( 'SC7', 1, 'C7_NUM', .T. )

                    aadd( aTail( aListaPC )[ 1 ], { "C7_NUM"     , cNum      } )
                    aadd( aTail( aListaPC )[ 1 ], { "C7_EMISSAO" , dEmissao  } )
                    aAdd( aTail( aListaPC )[ 1 ], { "C7_FORNECE" , cCodForn  } )
                    aAdd( aTail( aListaPC )[ 1 ], { "C7_LOJA"    , cCodLoja  } )
                    aAdd( aTail( aListaPC )[ 1 ], { "C7_COND"    , cCondic   } )
                    aAdd( aTail( aListaPC )[ 1 ], { "C7_CONAPRO" , 'L'       } )
                    aAdd( aTail( aListaPC )[ 1 ], { "C7_XNUMSIE" , cIdPedido } )
                    aAdd( aTail( aListaPC )[ 1 ], { "C7_OBS"     , ''        } ) // TODO O item do pedido de compras ja tem Observacao e o cabecalhao nao, considera mesmo este item ?
                    aAdd( aTail( aListaPC )[ 1 ], { "C7_TPFRETE" , cTpFrete  } )
                    aAdd( aTail( aListaPC )[ 1 ], { "C7_FRETE"   , nFrete    } )

                end

            end if

        else

            MyConOut( 'Condi��o de Pagamento id: ' + cIdCondic +  ' n�o cadastrada')

        end if

    else

        MyConOut( 'Pedido de Compras id: ' + cIdPedido +  ' j� cadastrado')

    end if

    RestArea( aArea )

return

/*/{Protheus.doc} BuscaForn
Busca pelo id o CNPJ do fornecedor no End Point correspondenete e valida busca do CNPJ na base e
popula as var�veis de c�digo e loja do fornecedor 
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 09/07/2020
@param cIdFornec, character, Id de busca do fornecedor no End Point
@return logical, Retorna verdadeiro se o CNPJ do Fornecedor foi lacalizado e as vari�veis de c�diogo e loja foram populadas
/*/
static function BuscaForn( cIdFornec )

    Local cPath     := cPrefix + '/creditors/' + cIdFornec
    Local oFwRest   := nil
    Local oJson     := nil
    Local cCnpj     := ''
    Local cRet      := ''
    Local lRet      := .F.

    oFwRest := FWRest():New( cUrl )

    oFwRest:SetPath( cPath )

    if oFwRest:Get( aHeader )

        oJson := JsonObject():New()

        cRet := oJson:FromJSON( oFwRest:GetResult() )

        if Empty( cRet )

            DbSelectArea( 'SA2' )
            SA2->( DBSetOrder( 3 ) ) // A2_FILIAL+A2_CGC

            cCnpj := StrTran( oJson['cnpj'] , '.', '' )
            cCnpj := StrTran( cCnpj         , '/', '' )
            cCnpj := StrTran( cCnpj         , '-', '' )

            if SA2->( DbSeek( xFilial() + cCnpj ) )

                cCodForn := SA2->A2_COD
                cCodLoja := SA2->A2_LOJA
                lRet := .T.

            else

                MyConOut( 'N�o Foi Poss�vel localizar o CNPJ do fornecedor na base de dados : ' + cIdFornec )

            end if

        else

            MyConOut( 'N�o Foi Poss�vel Montar o JSON da consulta do cadastro do fornecedro id : ' + cIdFornec + ' Erro => ' + cRet )

        end if

    else

        MyConOut( 'N�o Foi Poss�vel consultar o Cadastro do Fornecedor id : ' + cIdFornec + ' Erro => ' + oFwRest:GetLastError() )

    end if

return lRet

/*/{Protheus.doc} GetItens
Busca no end point correspondente os itens do pedido de compra e popula o array para o execauto 
@type static function
@version 12.1.27
@author elton.alves@totvs.coml.br
@since 09/07/2020
@param cIdPedido, character, Id do pedido de compras
@param aListaPC, array, Lista de pedidos de compras recebida por refer�ncia para ser populada com os itens do pedido
@return logical, Retorna verdadeiro se conseguiu buscar no end point os itens do pedido de compras e tamb�m que todos estejam no cadastro de produtos
/*/
static function GetItens( cIdPedido, aListaPC )

    Local lRet       := .F.
    Local lContinue  := .T.
    Local cPath      := cPrefix + '/purchase-orders/' + cIdPedido + '/items'
    Local oFwRest    := nil
    Local oJson      := nil
    Local cRet       := ''
    Local nX         := 0
    Local nLimit     := 200
    Local nOffSet    := 0
    Local nCount     := 0
    Local cGetParam  := ''
    Local aItens     := {}
    Local aLinha     := {}
    Local nItem      := 1
    Local cIdItem    := ''
    Local cDescric   := ''
    Local nQuantid   := 0
    Local nPrecUnit  := 0
    Local cObsIt     := ''
    Local aArea      := GetArea()

    Do While .T.

        oFwRest := FWRest():New( cUrl )

        oFwRest:SetPath( cPath )

        cGetParam += '?limit='
        cGetParam += cValToChar( nLimit )
        cGetParam += '&offset='
        cGetParam += cValToChar( nLimit * nOffSet )

        if oFwRest:Get( aHeader, cGetParam )

            oJson := JsonObject():New()

            cRet := oJson:FromJSON( oFwRest:GetResult() )

            if Empty( cRet )

                iif( nCount == 0, nCount := oJson["resultSetMetadata"]["count"], nil )

                For nX := 1 to Len( oJson["results"] )

                    cIdItem := cValToChar( oJson["results"][nX]['resourceId'] )

                    // Verifica se o item do pedido de compra existe no cadastro de produtos
                    DbSelectArea( 'SB1' )
                    SB1->( DBOrderNickname( 'CODSIENGE' ) ) // B1_FILIAL+B1_XSIENGE

                    If SB1->( DbSeek( xFilial() + cIdItem ) )

                        cDescric  := oJson["results"][nX]['resourceDescription']
                        nQuantid  := oJson["results"][nX]['quantity']
                        nPrecUnit := oJson["results"][nX]['unitPrice']
                        cObsIt    := oJson["results"][nX]['notes']

                        aAdd( aLinha, { "C7_ITEM"     , StrZero( nItem, 4 )  , NIL } )
                        aAdd( aLinha, { "C7_PRODUTO"  , SB1->B1_COD          , nil } )
                        aAdd( aLinha, { "C7_DESCRI"   , cDescric             , nil } )
                        aAdd( aLinha, { "C7_QUANT"    , nQuantid             , nil } )
                        aAdd( aLinha, { "C7_PRECO"    , nPrecUnit            , nil } )
                        aAdd( aLinha, { "C7_TOTAL"    , nQuantid * nPrecUnit , nil } )
                        aAdd( aLinha, { "C7_OBSM"     , cObsIt               , nil } )
                        aAdd( aLinha, { "C7_LOCAL"    , '01'                 , nil } )
                        aAdd( aLinha, { "C7_CC"       , cCC                  , nil } ) // Equivalente Centro de Custo
                        aAdd( aLinha, { "C7_ITEMCTA"  , cItCtb               , nil } ) // Equivalente Projeto
                        aAdd( aLinha, { "C7_CONTA"    , SB1->B1_CONTA        , nil } )

                        aAdd( aItens, aClone( aLinha ) )

                        aSize( aLinha, 0 )

                        nItem++

                    else

                        MyConOut( 'N�o foi poss�vel localizar o item ' + cIdItem + ' do pedido de compras ' + cIdPedido )

                        // Como um item n�o foi localizado no cadastro de produtos todo o processo para este pedido de compras � abortado
                        lContinue := .F.

                        Exit

                    end if

                Next nX

                // Interrompe o la�o while caso um item n�o seja localizado no cadastro de produtos
                if ! lContinue

                    Exit

                end if

            else

                MyConOut( 'N�o Foi Poss�vel Montar o JSON da consulta de itens do pedido de compra id : ' + cIdPedido + ' Erro => ' + cRet )

                Exit

            endif

        else

            MyConOut( 'N�o Foi Poss�vel consultar os itens do Pedido de Compra id : ' + cIdPedido + ' Erro => ' + oFwRest:GetLastError() )

            Exit

        endif

        nOffSet++
        cGetParam := ''
        FreeObj( oJson   )
        FreeObj( oFwRest )

        If ( nLimit * nOffSet ) > Int( ( nCount / nLimit ) )

            Exit

        End If

    End Do

    // Se todos os itens foram localizado no cadastro de produtos ent�o o array com as linhas dos itens � adicionado ao array da lista de pedidos v�lidos
    if lContinue

        lRet := lContinue

        aAdd( aListaPC, { {}, aClone( aItens ) } )

    end if

    RestArea( aArea )

return lRet


/*/{Protheus.doc} GravaPedidos
L� a lista de array de dados dos pedidos de compras e executado o execauto mata120 de cada um
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 09/07/2020
@param aListaPC, array, Lista com dados de cabe�alho e itens dos pedidos de compras.
/*/
static function GravaPedidos( aListaPC )

    Local nX        := 0
    Local cIdSienge := ''

    Private lMsErroAuto    := .F.
    Private lMsHelpAuto    := .T.
    Private lAutoErrNoFile := .T.

    // Apresenta erro com a condi��o de pagamento no ExecAuto se a Tabela SE4 estiver na WorkArea
    SC7->( DbCloseArea() )
    SE4->( DbCloseArea() )
    SA2->( DbCloseArea() )
    SB1->( DbCloseArea() )

    for nX := 1 To Len( aListaPC )

        cIdSienge := aListaPC[nX][1][aScan( aListaPC[ nX, 1 ], { | X | X[1] == 'C7_XNUMSIE' } )][2]

        Begin Transaction

            MsExecAuto( { |a,b,c,d| MATA120(a,b,c,d) }, 1, aListaPC[ nX, 1 ], aListaPC[ nX, 2 ], 3 )

            If lMsErroAuto

                lMsErroAuto := .F.

                MyConOut( 'Erro na inclus�o do pedido de compra id: ' + cIdSienge )
                MyConout( MsgErro( GetAutoGRLog() ) )

                DisarmTransaction()

            else

                RecLock('SC7',.F.)

                SC7->C7_XNUMSIE := cIdSienge

                MsUnlock()


            End If

        End Transaction

    next nX

return

/*/{Protheus.doc} GetAdiant
Busca no Web Service do Sienge do adiantamentos 
@type static function
@version 12.1.27
@author elton.alves2totvs.com.br
@since 14/07/2020
/*/
static function GetAdiant()

    Local cPath      := cPrefix + 'bills'
    Local oFwRest    := nil
    Local oJson      := nil
    Local cRet       := ''
    Local nX         := 0
    Local dDateRef   := GetMv( 'SIE_ADTREF' )
    Local cYearRef   := cValToChar( Year( dDateRef )  )
    Local cMonthRef  := StrZero( Month( dDateRef ), 2 )
    Local cDayRef    := StrZero( Day( dDateRef ), 2 )
    Local cStartDate := cYearRef + '-' + cMonthRef + '-' +cDayRef // formato yyyy-MM-dd
    Local cEndDate   := cStartDate // formato yyyy-MM-dd
    Local nLimit     := 200
    Local nOffSet    := 0
    Local nCount     := 0
    Local cGetParam  := ''
    Local aListaAd   := {}

    Do While .T.

        oFwRest := FWRest():New( cUrl )

        oFwRest:SetPath( cPath )

        cGetParam += '?limit='
        cGetParam += cValToChar( nLimit )
        cGetParam += '&offset='
        cGetParam += cValToChar( nLimit * nOffSet )
        cGetParam += '&startDate='
        cGetParam += cStartDate
        cGetParam += '&endDate='
        cGetParam += cEndDate

        if oFwRest:Get( aHeader, cGetParam )

            oJson := JsonObject():New()

            cRet := oJson:FromJSON( oFwRest:GetResult() )

            if Empty( cRet )

                iif( nCount == 0, nCount := oJson["resultSetMetadata"]["count"], nil )

                For nX := 1 to Len( oJson["results"] )

                    // Verifica se o t�tulo no Sienge � do tipo "ADI", somente este tipo � incluido
                    if  AllTrim( oJson["results"][nX]['documentIdentificationId'] ) == 'ADI'

                        GetListaAd( @aListaAd, oJson["results"][nX] )

                    end if

                Next nX

            else

                MyConOut( 'N�o Foi Poss�vel Montar o JSON da consulta de pedidos de compras Erro => ' + cRet )

                Exit

            endif

        else

            MyConOut( 'N�o Foi Poss�vel consultar os Adiantamentos Erro => ' + oFwRest:GetLastError() )

            Exit

        endif

        nOffSet++
        cGetParam := ''
        FreeObj( oJson   )
        FreeObj( oFwRest )

        If ( nLimit * nOffSet ) > Int( ( nCount / nLimit ) ) //+ If( Mod( nCount, nLimt ) > 0, 1, 0 )

            Exit

        End If

    End Do

    GravaAdiant( aListaAd )

return

/*/{Protheus.doc} GetListaAd
Monta o array com a lista de dados dos adiantamentos adiciona na lista de t�tulos PA a serem inclu�dos na base.
� verificado:
- Se o fornecedor est� cadastrado verificando seu CNPJ
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 09/07/2020
@param aListaAd, array, Par�metro recebido por refer�ncia a ser populado com os dados do adiantamento
@param oJson, object, Objeto Json com os dados do adiantamento
/*/
static function GetListaAd( aListaAd, oJson )

    Local aAdiant   := {}
    Local cNum      := oJson["documentNumber"]
    Local cData     := StoD( StrTran( oJson["issueDate"], '-', '' ) )
    Local nValor    := oJson["totalInvoiceAmount"]
    Local cNaturez  := 'D32.01'
    Local cIdFornec := cValTochar( oJson['creditorId'] )
    Local cBanco    := '237'    // TODO Qual o banco do PA ?
    Local cAgencia  := '1122'   // TODO Qual Ag�ncia do PA ?
    Local cConta    := '112233' // TODO Qual Conta do PA ?

    Private cCodForn := ''
    Private cCodLoja := ''

    if BuscaForn( cIdFornec )

        aAdd( aAdiant, { "E2_PREFIXO" , "SIE"    , NIL } )
        aAdd( aAdiant, { "E2_NUM"     , cNum     , NIL } )
        aAdd( aAdiant, { "E2_TIPO"    , 'PA'     , NIL } )
        aAdd( aAdiant, { "E2_NATUREZ" , cNaturez , NIL } )
        aAdd( aAdiant, { "E2_FORNECE" , cCodForn , NIL } )
        aAdd( aAdiant, { "E2_LOJA"    , cCodLoja , NIL } )
        aAdd( aAdiant, { "E2_EMISSAO" , cData    , NIL } )
        aAdd( aAdiant, { "E2_VENCTO"  , cData    , NIL } )
        aAdd( aAdiant, { "E2_VENCREA" , cData    , NIL } )
        aAdd( aAdiant, { "E2_VALOR"   , nValor   , NIL } )
        aAdd( aAdiant, { "AUTBANCO"   , cBanco   , NIL } )
        aAdd( aAdiant, { "AUTAGENCIA" , cAgencia , NIL } )
        aAdd( aAdiant, { "AUTCONTA"   , cConta   , NIL } )

        aAdd( aListaAd, aClone( aAdiant ) )

        aSize( aAdiant, 0 )

    End If

return

/*/{Protheus.doc} GravaAdiant
L� a lista de array de dados dos adiantamentos e executado o execauto FINA050 de cada um
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 09/07/2020
@param aListaAd, array, Lista com dados dos adiantamentos.
/*/
static function GravaAdiant( aListaAd )

    Local nX        := 0
    Local cIdSienge := ''

    Private lMsErroAuto    := .F.
    Private lMsHelpAuto    := .T.
    Private lAutoErrNoFile := .T.

    SA2->( DbCloseArea() )

    for nX := 1 to Len( aListaAd )

        cIdSienge := aListaAd[nX][aScan( aListaAd[nX], {|X| X[1] = 'E2_NUM' } )][2]

        Begin Transaction

            MsExecAuto( { | x, y, z | FINA050( x, y, z ) }, aListaAd[ nX ],, 3 )

            If lMsErroAuto

                lMsErroAuto := .F.

                MyConOut( 'Erro na inclus�o do adiantamento id: ' + cIdSienge )
                MyConout( MsgErro( GetAutoGRLog() ) )

                DisarmTransaction()

            end if

        End Transaction

    next nX

    //TODO Verificar como buscar do Sienge o pedido de compras a ser vinculado ao adiantamento

return

/*/{Protheus.doc} MsgErro
Recebe array com erros do execauto e converte em uma string com as linhas do erro 
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 09/07/2020
@param aErro, array, Array com a mensagem de erro
@return character, String resultante da convers�o do array recebido
/*/
static function MsgErro( aErro )

    Local cRet := ''
    Local nX   := 0
    Local nLen := Len( aErro )

    For nX := 1 To nLen

        cRet += aErro[ nX ]

        If nX < nLen

            cRet += CRLF

        End IF

    Next nX

Return cRet

/*/{Protheus.doc} MyConOut
Executa o rotina de conout com um prefixo indicando que se refere a uma mensagem de integra��o com o SIENGE
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 07/07/2020
@param cMsg, character, Mensagem a ser exibida no console
/*/
static function MyConOut( cMsg )

    ConOut( '[ SIENGE ] = > ' + cMsg )

return
