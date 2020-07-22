/*TODO Cadastrar seguintes modificacoes no dicionario:

- Cadastrar par�metro SIE_PEDREF
- Cadastrar par�metro SIE_ADTREF
- Cadastrar par�metro SIE_ADTNAT
- Cadastrar indice Pedido de Compra NUMSIENGE
- Cadastrar indice Condi��o de pagamento CODSIENGE
- Cadastrar indice Produto CODSIENGE

*/

#include 'totvs.ch'

/*/{Protheus.doc} SiengeV2
Rotina a ser utilizada no schedule que ir� buscar no Web Service do SIENGE para buscar os dados dos pedidos de compras e
adiantamento a fornecedrores e ir� incluir estes dados no protheus, vinculando o adiantamento ao seu pedido de compras 
correspondenete.
@type user function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 17/07/2020
@param aParam, array, Parametros enviados pelo schedule
@obs O par�metro aParam n�o � utilizado na execu��o da fun��o e caso seja informada outra empresa/filial diferente de  01/010001
O array de par�metros enviado pelo schedule tem a seguinte estrutura:
aParam[ 1 ] => Empresa associada ao agendamento da rotina
aParam[ 2 ] => Filial associada ao agendamento da rotina
aParam[ 3 ] => Usu�rio associado ao agendamento
aParam[ 4 ] => Id do agendamento
/*/
user function SiengeV2( aParam )

    Local nX   := 0
    Local cMsg := ''

    // Par�metros utilizados por todos os End Points dos Web Service do SIENGE
    Private cUrl       := 'https://api.sienge.com.br'
    Private cPrefix    := '/bhg/public/api/v1/'
    Private aHeader    := { 'Authorization: Basic ' + Encode64( 'bhg-api' + ':' + 'KkJ3THNPk2h8' ) }
    Private aCodFil    := {}

    Default aParam := { '01', '010001' }

    if Alltrim( aParam[1] ) + Alltrim( aParam[2] ) # '01010001'

        return

    end if

    GetEmpresas()

    for nX := 1 to Len( aCodFil )

        if RpcSetEnv( aCodFil[nX]["M0_CODIGO"], aCodFil[nX]["M0_CODFIL"] )

            //GetPedidos(aCodFil[nX]["id"])
            GetAdiant(aCodFil[nX]["id"])

            RpcClearEnv()

        else

            cMsg += "N�o foi conectar com a Empresa/Filial/CNPJ/ID => "
            cMsg += aCodFil[nX]["M0_CODIGO"] + "/"
            cMsg += aCodFil[nX]["M0_CODFIL"] + "/"
            cMsg += aCodFil[nX]["cnpj"] + "/"
            cMsg += cValTochar( aCodFil[nX]["id"] )

            MyConOut( cMsg )

            cMsg := ""

        end if

    next nX

    //TODO incrementar o par�metro SIE_PEDREF
    //TODO incrementar o par�metro SIE_ADTREF

return

/*/{Protheus.doc} GetEmpresas
Popula o array com a lista de empresas (aCodFil ) com os dados das empresas cadastrados no Sienge, 
caso a empresa n�o tenha o cnpj preenchido ser� desconsiderada
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 17/07/2020
/*/
static function GetEmpresas()

    Local cPath     := cPrefix + 'companies'
    Local aResult   := nil
    Local nX        := 0

    aResult := fetch( cPath,, 'Empresas' )

    if ! Empty( aResult )

        for nX := 1 To Len( aResult )

            if ! Empty( aResult[nX]["cnpj"] )

                aAdd( aCodFil , JsonObject():New() )

                aTail( aCodFil )["cnpj"]      := AllTrim( StrTran( StrTran( StrTran( aResult[nX]["cnpj"], '.', '' ), '/', '' ), '-' , '' ) )
                aTail( aCodFil )["id"]        := aResult[nX]["id"]
                aTail( aCodFil )["name"]      := aResult[nX]["name"]
                aTail( aCodFil )["M0_CODIGO"] := ''
                aTail( aCodFil )["M0_CODFIL"] := ''

            end if

        next nX

    end if

    aSize( aResult, 0 )

    GetCodFil( @aCodFil  )

return

/*/{Protheus.doc} GetCodFil
Popula o array com a lista de empresas (aCodFil ) com os cnpj�s correspondentes na base do protheus,
caso o cnpj n�o seja localizado na base o item ser� retirado do array.
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 17/07/2020
@param aCodFil , array, Array com a lista de processamento recebido por refer�ncia que ser� preenchido com os c�digos da empresa e filial buscando na base pelo cnpj
/*/
static function GetCodFil( aCodFil  )

    Local cDataBase := GetSrvProfString( 'DBDATABASE', GetPvProfString( 'DBACCESS', 'DATABASE', '', GetSrvIniName() ) )
    Local cAlias    := GetSrvProfString( 'DBALIS', GetPvProfString( 'DBACCESS', 'ALIAS', '', GetSrvIniName() ) )
    Local cServer   := GetSrvProfString( 'DBSERVER', GetPvProfString( 'DBACCESS', 'SERVER', '', GetSrvIniName() ) )
    Local nPort     := Val( GetSrvProfInt( 'DBPORT', cValToChar( GetPvProfileInt( 'DBACCESS', 'PORT',  0, GetSrvIniName() ) ) ) )
    Local oDbAccess := FwDbAccess():New( cDataBase + '/' + cAlias, cServer, nPort )
    Local cTmp      := 'SM0'
    Local nPos      := 0
    Local aAux      := {}

    if oDbAccess:OpenConnection()

        oDbAccess:NewAlias( "SELECT M0_CODIGO, M0_CODFIL, M0_CGC FROM SYS_COMPANY WHERE D_E_L_E_T_ = ' '", cTmp )

    else

        MyConOut( 'Erro na conex�o com banco de dados para consulta de dados da empresa na base de dados Erro => ' + oDbAccess:ErrorMessage() )

    end if

    Do While ! SM0->( Eof() )

        nPos := aScan( aCodFil , { |Item| Item["cnpj"] == AllTrim( SM0->M0_CGC ) } )

        if nPos # 0

            aCodFil [ nPos ]["M0_CODIGO"] := SM0->M0_CODIGO
            aCodFil [ nPos ]["M0_CODFIL"] := SM0->M0_CODFIL

        end if

        SM0->( DbSkip() )

    End Do

    oDbAccess:CloseConnection()
    oDbAccess:Finish()

    for nPos := 1 to Len( aCodFil )

        If ! Empty( aCodFil[nPos]["M0_CODIGO"] ) .And. ! Empty( aCodFil[nPos]["M0_CODFIL"] )

            aAdd( aAux, aCodFil[nPos] )

        end if

    next nPos

    aSize( aCodFil, 0 )

    aCodFil := aClone( aAux )

return

/*/{Protheus.doc} GetPedidos
Busca lista de pedidos do Web service
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 17/07/2020
@param nIdEmpresa, numeric, Id da empresa correspondente aos pedidos a serem retornado pelo Web Service
/*/
static function GetPedidos( nIdEmpresa )

    Local aArea     := GetArea()
    Local cPath      := cPrefix + 'purchase-orders'
    Local aResult    := nil
    Local nX         := 0
    Local cQuery     := ''
    Local dDateRef   := GetMv( 'SIE_PEDREF' )
    Local cYearRef   := cValToChar( Year( dDateRef )  )
    Local cMonthRef  := StrZero( Month( dDateRef ), 2 )
    Local cDayRef    := StrZero( Day( dDateRef ), 2 )
    Local cStartDate := cYearRef + '-' + cMonthRef + '-' +cDayRef // formato yyyy-MM-dd
    Local cEndDate   := cStartDate // formato yyyy-MM-dd

    Local cIdPedido  := ''
    Local cIdFornec  := ''

    Local cNum       := ''
    Local dEmissao   := ''
    Local cCodForn   := ''
    Local cCodLoja   := ''
    Local cTpFrete   := ''
    Local nFrete     := ''
    Local cCC        := ''
    Local cItCtb     := ''

    Private aListaPC := {}

    cQuery += '&startDate='
    cQuery += cStartDate
    cQuery += '&endDate='
    cQuery += cEndDate
    cQuery += '&buildingId='
    cQuery += cValToChar( nIdEmpresa )

    aResult := fetch( cPath, cQuery, 'Pedidos de Compras' )

    for nX := 1 to len( aResult )

        if aResult[nX]['authorized'] .And. aResult[nX]['status'] == 'PENDING'

            cIdPedido := cValTochar( aResult[nX]['id'] )

            // Verifica se Pedido j� est� na cadastrado
            DbSelectArea( 'SC7' )
            SC7->( DBOrderNickname( 'NUMSIENGE' ) ) // C7_FILIAL+C7_XNUMSIE
            if ! SC7->( DbSeek( xFilial() + cIdPedido ) )

                cIdFornec  := cValTochar( aResult[nX]['supplierId'] )

                // Verifica se fornecedor est� cadastrado e em caso positivo popula as vari�veis de C�digo e Loja
                if BuscaForn( cIdFornec, @cCodForn, @cCodLoja )

                    // TODO Pedidos vindo do sienge com centros de custos nao cadastrados ou sinteticos
                    cCC      := '31103'//cValTochar( aResult[nX]['costCenterId'] )
                    // TODO Pedidos vindo do sienge com itens contabeis nao cadastrados ou sinteticos
                    // TODO buildingId e equivalente a Item contabil ?
                    cItCtb   := '01001'//cValTochar( aResult[nX]['buildingId'] )

                    // Busca itens do pedido e se os mesmos exitirem no cadastro de produtos popula aListaPC com dados de Cabe�alho e Itens
                    If GetItens( cIdPedido, cCC, cItCtb, @aListaPC )

                        cNum     := GetNumSC7() //NextNumero( 'SC7', 1, 'C7_NUM', .T. )
                        dEmissao := StoD( StrTran( aResult[nX]['date'], '-', '' ) )
                        cTpFrete := 'F'
                        nFrete   :=  0 //TODO Soma a propriedade freightunitprice dos itens para compor o frete ? // aResult[nX]['increase']

                        aadd( aTail( aListaPC )[ 1 ], { "C7_NUM"     , cNum      } )
                        aadd( aTail( aListaPC )[ 1 ], { "C7_EMISSAO" , dEmissao  } )
                        aAdd( aTail( aListaPC )[ 1 ], { "C7_FORNECE" , cCodForn  } )
                        aAdd( aTail( aListaPC )[ 1 ], { "C7_LOJA"    , cCodLoja  } )
                        //TODO Verificar a condi��o de pagamento no Fornecedor aAdd( aTail( aListaPC )[ 1 ], { "C7_COND"    , cCondic   } )
                        aAdd( aTail( aListaPC )[ 1 ], { "C7_CONAPRO" , 'L'       } )
                        aAdd( aTail( aListaPC )[ 1 ], { "C7_XNUMSIE" , cIdPedido } )
                        // TODO O item do pedido de compras ja tem Observacao e o cabecalhao nao, considera mesmo este item ?
                        aAdd( aTail( aListaPC )[ 1 ], { "C7_OBS"     , ''        } )
                        aAdd( aTail( aListaPC )[ 1 ], { "C7_TPFRETE" , cTpFrete  } )
                        aAdd( aTail( aListaPC )[ 1 ], { "C7_FRETE"   , nFrete    } )

                    end

                else

                    MyConOut( 'Fornecedore n�o localizado na base pedido id: ' + cIdPedido )

                end if

            else

                MyConOut( 'Pedido j� cadastrado na base id: ' + cIdPedido )

            end if

        else

            MyConOut( 'Pedido n�o autorizado ou com status diferente de "PENDING" id: ' + cIdPedido )

        end if

    next nX

    SC7->( DbCloseArea() )
    SE4->( DbCloseArea() )

    RestArea( aArea )

    if ! empty( aListaPC )

        GravaPedidos( aListaPC )

    end if

return

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
                SC7->C7_CONAPRO := 'L'

                MsUnlock()


            End If

        End Transaction

    next nX

return

/*/{Protheus.doc} BuscaForn
Busca pelo id o CNPJ do fornecedor no End Point correspondenete e valida busca do CNPJ na base e
popula as var�veis de c�digo e loja do fornecedor 
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 20/07/2020
@param cIdFornec, character, Id de busca do fornecedor no End Point
@param cCodForn, character, Vari�vel recebida por refer�ncia a ser populada com o c�digo do fornecedor localizado na base 
@param cCodLoja, character, Vari�vel recebida por refer�ncia a ser populada com a loja do fornecedor localizado na base
@return logical, Retorna verdadeiro se o CNPJ do Fornecedor foi lacalizado e as vari�veis de c�diogo e loja foram populadas
/*/
static function BuscaForn( cIdFornec, cCodForn, cCodLoja )

    Local cPath     := cPrefix + 'creditors/' + cIdFornec
    Local cCnpj     := ''
    Local lRet      := .F.
    Local oJson     := fetch( cPath, , 'Fornecedores' )

    if ValType( oJson ) == 'J'

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

    end if

    SA2->( DbCloseArea() )

return lRet

/*/{Protheus.doc} GetItens
Busca no end point correspondente os itens do pedido de compra e popula o array para o execauto 
@type static function
@version 12.1.27
@author elton.alves@totvs.coml.br
@since 09/07/2020
@param cIdPedido, character, Id do pedido de compras
@param cCC, character, Centro de custo definido no cabe�alho do Pedido de Compras na propriedade a ser populado ao itens
@param cItCtb, character, Item Cont�bil definido no cabe�alho do Pedido de Compras a ser populado ao itens
@param aListaPC, array, Lista de pedidos de compras recebida por refer�ncia para ser populada com os itens do pedido
@return logical, Retorna verdadeiro se conseguiu buscar no end point os itens do pedido de compras e tamb�m que todos estejam no cadastro de produtos
/*/
static function  GetItens( cIdPedido, cCC, cItCtb, aListaPC )

    Local lRet      := .T.
    Local cPath     := cPrefix + '/purchase-orders/' + cIdPedido + '/items'
    Local aWsItens  := fetch( cPath, , 'Itens do Pedido de Compras' )
    Local nX        := 0
    Local cIdItem   := ''
    Local cDescric  := ''
    Local nQuantid  := 0
    Local nPrecUnit := 0
    Local cObsIt    := ''
    Local aLinha    := {}
    Local aItens    := {}
    Local nItem     := 1

    If ! Empty( aWsItens )

        DbSelectArea( 'SB1' )
        SB1->( DBOrderNickname( 'CODSIENGE' ) ) // B1_FILIAL+B1_XSIENGE

        for nX := 1 To Len( aWsItens )

            cIdItem := cValToChar( aWsItens[nX]['resourceId'] )

            If SB1->( DbSeek( xFilial() + cIdItem ) )

                cDescric  := aWsItens[nX]['resourceDescription']
                nQuantid  := aWsItens[nX]['quantity']
                nPrecUnit := aWsItens[nX]['unitPrice']
                cObsIt    := aWsItens[nX]['notes']

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
                lRet := .F.

                Exit

            end if

        next nX

    end if

    // Se todos os itens foram localizado no cadastro de produtos ent�o o array com as linhas dos itens � adicionado ao array da lista de pedidos v�lidos
    if lRet

        aAdd( aListaPC, { {}, aClone( aItens ) } )

    end if

    SB1->( DbCloseArea() )

return lRet

/*/{Protheus.doc} GetAdiant
Busca no Web Service do Sienge do adiantamentos 
@type static function
@version 12.1.27
@author elton.alves2totvs.com.br
@since 14/07/2020
@param nIdEmpresa, numeric, Id da empresa correspondente aos adiantamentos a serem retornado pelo Web Service
/*/
static function GetAdiant( nIdEmpresa )

    Local cPath      := cPrefix + 'bills'
    Local dDateRef   := GetMv( 'SIE_ADTREF' )
    Local cYearRef   := cValToChar( Year( dDateRef )  )
    Local cMonthRef  := StrZero( Month( dDateRef ), 2 )
    Local cDayRef    := StrZero( Day( dDateRef ), 2 )
    Local cStartDate := cYearRef + '-' + cMonthRef + '-' +cDayRef // formato yyyy-MM-dd
    Local cEndDate   := cStartDate // formato yyyy-MM-dd
    Local cQuery     := ''
    Local aResult    := {}
    Local aAdiant    := {}
    Local aListaAd   := {}
    Local cNum       := ''
    Local cData      := ''
    Local nValor     := 0
    Local cNaturez   := ''
    Local cIdFornec  := ''
    Local cBanco     := ''
    Local cAgencia   := ''
    Local cConta     := ''
    Local cCodForn   := ''
    Local cCodLoja   := ''
    Local nX         := 0

    cQuery += '&startDate='
    cQuery += cStartDate
    cQuery += '&endDate='
    cQuery += cEndDate
    cQuery += '&debtorId='
    cQuery += cValToChar( nIdEmpresa )

    aResult := fetch( cPath, cQuery, 'Adiantamentos' )

    if ValType( aResult ) # "U"

        for nX := 1 to len( aResult )

            // Verifica se o t�tulo no Sienge � do tipo "ADI", somente este tipo � incluido
            if AllTrim( aResult[nX]['documentIdentificationId'] ) == 'ADI'

                cIdFornec := cValTochar( aResult[nX]['creditorId'] )

                if BuscaForn( cIdFornec, @cCodForn, @cCodLoja )

                    cNum      := aResult[nX]["documentNumber"]
                    cData     := StoD( StrTran( aResult[nX]["issueDate"], '-', '' ) )
                    nValor    := aResult[nX]["totalInvoiceAmount"]
                    cNaturez  := GetMv( 'SIE_ADTNAT' )
                    cBanco    := '237'    // TODO Qual o banco do PA ?
                    cAgencia  := '1122'   // TODO Qual Ag�ncia do PA ?
                    cConta    := '112233' // TODO Qual Conta do PA ?

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

                else

                    MyConOut( 'Fornecedor n�o foi localizado na base adiantamento id: ' + cNum )

                end if

            end if

        next nx

    end if

    if ! Empty( aListaAd )

        GravaAdiant( aListaAd )

    end if

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

/*/{Protheus.doc} fetch
Fun��o gen�riaca de busca de dados no Web Sercice do Sienge
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 17/07/2020
@param cPath, character, Path do caminho da requisi��o
@param cQuery, character, Par�metros de busca 
@param cConsulta, character, Nome da consulta impress�o de identifica��o na mensagem no console 
@return undefined, Retorna um array com a lista de itens requisitados ou um objeto json conforme solictado no par�metro nTpRet 
/*/
static function fetch( cPath, cQuery, cConsulta )

    Local uRet      := nil
    Local cRet      := ""
    Local cGetParam := ""
    Local nLimit    := 200
    Local nOffSet   := 0
    Local nCount    := 0
    Local oFwRest   := nil
    Local oJson     := nil
    Local nX        := 0

    Default cQuery    := ""
    Default cConsulta := ""

    Do While .T.

        oFwRest := FWRest():New( cUrl )

        oFwRest:SetPath( cPath )

        cGetParam += '?limit='
        cGetParam += cValToChar( nLimit )
        cGetParam += '&offset='
        cGetParam += cValToChar( nLimit * nOffSet )
        cGetParam += cQuery

        if oFwRest:Get( aHeader, cGetParam )

            oJson := JsonObject():New()

            cRet := oJson:FromJSON( oFwRest:GetResult() )

            if Empty( cRet )

                if ! ValType( oJson['results'] ) == 'U'

                    iif( nCount == 0, nCount := oJson["resultSetMetadata"]["count"], nil )

                    if Empty( uRet )

                        uRet := {}

                    End If

                    for nX := 1 to Len( oJson['results'] )

                        aAdd( uRet, oJson['results'][nX] )

                    next nX

                else

                    uRet := oJson

                end if

            else

                MyConOut( 'N�o Foi Poss�vel Montar o JSON da consulta de "' + cConsulta + '" Erro => ' + cRet )

                Exit

            end if

        else

            MyConOut( 'N�o Foi Poss�vel efetuar a consulta de "' + cConsulta + '" Erro => ' + oFwRest:GetLastError() )

            Exit

        end if

        nOffSet++
        cGetParam := ''
        FreeObj( oJson   )
        FreeObj( oFwRest )

        If ( nLimit * nOffSet ) > Int( ( nCount / nLimit ) ) .Or. ValType( oJson['results'] ) == 'U'

            Exit

        End If

    End Do

return uRet

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
