/*TODO Cadastrar seguintes modificacoes no dicionario:

- Cadastrar parâmetro SIE_PEDREF
- Cadastrar parâmetro SIE_ADTREF
- Cadastrar parâmetro SIE_ADTNAT
- Cadastrar parâmetro SIE_CONDPG
- Cadastrar parâmetro SIE_URL -> https://api.sienge.com.br
- Cadastrar parâmetro SIE_SUBDOM -> /bhg/public/api/v1/
- Cadastrar parâmetro SIE_USER -> bhg-api
- Cadastrar parâmetro SIE_PASWOR -> KkJ3THNPk2h8
- Cadastrar indice Pedido de Compra NUMSIENGE
- Cadastrar indice Produto CODSIENGE
- Cadastrar indice Centro de Custo CTTSIENGE -> CTT_FILIAL+CTT_XSIENG
- Cadastrar indice Item Contábil CTDSIENGE -> CTD_FILIAL+CTD_XSIENG
- Cadastrar Campo CTT_XSIENG
- Cadastrar Campo CTD_XSIENG

*/

#include 'totvs.ch'

/*/{Protheus.doc} SiengeV2
Rotina a ser utilizada no schedule que irá buscar no Web Service do SIENGE para buscar os dados dos pedidos de compras e
adiantamento a fornecedrores e irá incluir estes dados no protheus, vinculando o adiantamento ao seu pedido de compras 
correspondenete.
@type user function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 17/07/2020
@param aParam, array, Parametros enviados pelo schedule
@obs O parâmetro aParam não é utilizado na execução da função e caso seja informada outra empresa/filial diferente de  01/010001
O array de parâmetros enviado pelo schedule tem a seguinte estrutura:
aParam[ 1 ] => Empresa associada ao agendamento da rotina
aParam[ 2 ] => Filial associada ao agendamento da rotina
aParam[ 3 ] => Usuário associado ao agendamento
aParam[ 4 ] => Id do agendamento
/*/
user function SiengeV2( aParam )

    Local nX   := 0
    Local nY   := 0
    Local cMsg := ''

    //TODO Tratar estes parâmetros para serem lidos sem estar com o ambinete no ar
    //Parâmetros utilizados por todos os End Points dos Web Service do SIENGE
    Private cUrl       := 'https://api.sienge.com.br'//AllTrim( GetMv( 'SIE_URL' ) )
    Private cPrefix    := '/bhg/public/api/v1/'//AllTrim( GetMv( 'SIE_SUBDOM' ) )
    //Private aHeader    := { 'Authorization: Basic ' + Encode64( AllTrim( GetMv( 'SIE_USER' ) ) + ':' + AllTrim( GetMv( 'SIE_PASWOR' ) ) ) }
    Private aHeader    := { 'Authorization: Basic ' + Encode64( 'bhg-api' + ':' + 'KkJ3THNPk2h8' ) }
    Private aCodFil    := {}

    Default aParam := { '01', '010001' }

    if Alltrim( aParam[1] ) + Alltrim( aParam[2] ) # '01010001'

        return

    end if

    GetEmpresas()

    for nX := 1 to Len( aCodFil )

        if RpcSetEnv( aCodFil[nX]["M0_CODIGO"], aCodFil[nX]["M0_CODFIL"] )

            for nY := 1 to len( aCodFil[nX]["buildings"] )

                GetPedidos(aCodFil[nX]["buildings"][nY])
                GetAdiant( aCodFil[nX]["buildings"][nY])

            next nX

            RpcClearEnv()

        else

            cMsg += "Não foi conectar com a Empresa/Filial/CNPJ/ID => "
            cMsg += aCodFil[nX]["M0_CODIGO"] + "/"
            cMsg += aCodFil[nX]["M0_CODFIL"] + "/"
            cMsg += aCodFil[nX]["cnpj"] + "/"
            cMsg += cValTochar( aCodFil[nX]["id"] )

            MyConOut( cMsg )

            cMsg := ""

        end if

    next nX

return

/*/{Protheus.doc} GetEmpresas
Popula o array com a lista de empresas (aCodFil ) com os dados das empresas cadastrados no Sienge, 
caso a empresa não tenha o cnpj preenchido será desconsiderada
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 17/07/2020
/*/
static function GetEmpresas()

    Local cPath      := 'companies'
    Local aResult    := nil
    Local nX         := 0
    Local aBuildings := {}

    //XXX aResult := Eval( {|| cJson:=memoread('C:\Temp\sienge\empresas.json'),oJson:=JsonObject():new(),oJson:FromJson(cjson),ojson['results']} )
    aResult := fetch( cPath,, 'Empresas' )

    if ! Empty( aResult )

        for nX := 1 To Len( aResult )

            if ! Empty( aResult[nX]["cnpj"] )

                aBuildings := GetProjetos( aResult[nX]["id"] )

                if ! Empty( aBuildings )

                    aAdd( aCodFil , JsonObject():New() )

                    aTail( aCodFil )["cnpj"]      := AllTrim( StrTran( StrTran( StrTran( aResult[nX]["cnpj"], '.', '' ), '/', '' ), '-' , '' ) )
                    aTail( aCodFil )["id"]        := aResult[nX]["id"]
                    aTail( aCodFil )["name"]      := aResult[nX]["name"]
                    aTail( aCodFil )["M0_CODIGO"] := ''
                    aTail( aCodFil )["M0_CODFIL"] := ''
                    aTail( aCodFil )["buildings"] := aClone( aBuildings )

                end if

            end if

        next nX

    end if

    GetCodFil( @aCodFil  )

return

/*/{Protheus.doc} GetCodFil
Popula o array com a lista de empresas (aCodFil ) com os cnpj´s correspondentes na base do protheus,
caso o cnpj não seja localizado na base o item será retirado do array.
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 17/07/2020
@param aCodFil , array, Array com a lista de processamento recebido por referência que será preenchido com os códigos da empresa e filial buscando na base pelo cnpj
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

        Do While ! SM0->( Eof() )

            nPos := aScan( aCodFil , { |Item| Item["cnpj"] == AllTrim( SM0->M0_CGC ) } )

            if nPos # 0

                aCodFil [ nPos ]["M0_CODIGO"] := AllTrim( SM0->M0_CODIGO )
                aCodFil [ nPos ]["M0_CODFIL"] := AllTrim( SM0->M0_CODFIL )

            end if

            SM0->( DbSkip() )

        End Do

    else

        MyConOut( 'Erro na conexão com banco de dados para consulta de dados da empresa na base de dados Erro => ' + oDbAccess:ErrorMessage() )

    end if

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

/*/{Protheus.doc} GetProjetos
Busca no SIENGE a lista de id´s de projetos de uma empresa
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 29/07/2020
@param nIdEmpresa, number, Id da empresa a ser pesquisada
@return array, Array com a lista de Projetos
/*/
static function GetProjetos( nIdEmpresa )

    Local cPath   := 'enterprises'
    Local cQuery  := ''
    Local aRet    := {}
    Local aResult := {}
    Local nX      := 0

    cQuery += '&companyId='
    cQuery += cValToChar( nIdEmpresa )

    aResult := fetch( cPath, cQuery, 'Projetos' )

    for nX := 1 to Len( aResult )

        aAdd( aRet, aResult[nX]['id'] )

    next nX

return aRet

/*/{Protheus.doc} GetPedidos
Busca lista de pedidos do Web service
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 17/07/2020
@param nIdProjeto, numeric, Id da empresa correspondente aos pedidos a serem retornado pelo Web Service
/*/
static function GetPedidos( nIdProjeto )

    Local aArea     := GetArea()
    Local cPath      := 'purchase-orders'
    Local aResult    := nil
    Local nX         := 0
    Local cQuery     := ''
    Local nDateRef   := GetMv( 'SIE_PEDREF' )
    Local cStartDate := DateFormat( Date() - nDateRef )
    Local cEndDate   := DateFormat( Date() )
    Local cIdPedido  := ''
    Local cIdFornec  := ''
    Local cNum       := ''
    Local dEmissao   := stod('')
    Local cCodForn   := ''
    Local cCodLoja   := ''
    Local cTpFrete   := ''
    Local cCondic    := ''
    Local cCC        := ''
    Local cItCtb     := ''
    Local nIdCC      := 0
    Local nIdItCtb   := 0

    Private aListaPC := {}

    cQuery += '&startDate='
    cQuery += cStartDate
    cQuery += '&endDate='
    cQuery += cEndDate
    cQuery += '&buildingId='
    cQuery += cValToChar( nIdProjeto )
    cQueyr := '&status=PENDING'
    cQueyr := '&authorized=true'

    aResult := fetch( cPath, cQuery, 'Pedidos de Compras' )

    for nX := 1 to len( aResult )

        cIdPedido := cValTochar( aResult[nX]['id'] )

        // Verifica se Pedido já está na cadastrado
        DbSelectArea( 'SC7' )
        SC7->( DBOrderNickname( 'NUMSIENGE' ) ) // C7_FILIAL+C7_XNUMSIE
        if ! SC7->( DbSeek( xFilial() + cIdPedido ) )

            cIdFornec  := cValTochar( aResult[nX]['supplierId'] )

            // Verifica se fornecedor está cadastrado e em caso positivo popula as variáveis de Código e Loja
            if BuscaForn( cIdFornec, @cCodForn, @cCodLoja )

                nIdCC    := aResult[nX]['costCenterId']
                nIdItCtb := aResult[nX]['buildingId']

                if BuscaCcIt( nIdCC, nIdItCtb, @cCC, @cItCtb )

                    // Busca itens do pedido e se os mesmos exitirem no cadastro de produtos popula aListaPC com dados de Cabeçalho e Itens
                    If GetItens( cIdPedido, cCC, cItCtb, @aListaPC )

                        cNum     := GetNumSC7() //NextNumero( 'SC7', 1, 'C7_NUM', .T. )
                        dEmissao := StoD( StrTran( aResult[nX]['date'], '-', '' ) )
                        cCondic  := GetMv( 'SIE_CONDPG' )
                        cOBs     := cIdPedido + '/' + aResult[nX]['buyerId']
                        cTpFrete := 'F'

                        aadd( aTail( aListaPC )[ 1 ], { "C7_NUM"     , cNum      } )
                        aadd( aTail( aListaPC )[ 1 ], { "C7_EMISSAO" , dEmissao  } )
                        aAdd( aTail( aListaPC )[ 1 ], { "C7_FORNECE" , cCodForn  } )
                        aAdd( aTail( aListaPC )[ 1 ], { "C7_LOJA"    , cCodLoja  } )
                        aAdd( aTail( aListaPC )[ 1 ], { "C7_COND"    , cCondic   } )
                        aAdd( aTail( aListaPC )[ 1 ], { "C7_CONAPRO" , 'L'       } )
                        aAdd( aTail( aListaPC )[ 1 ], { "C7_XNUMSIE" , cIdPedido } )
                        aAdd( aTail( aListaPC )[ 1 ], { "C7_OBS"     , cOBs      } )
                        aAdd( aTail( aListaPC )[ 1 ], { "C7_TPFRETE" , cTpFrete  } )

                    end if

                else

                    MyConOut( 'Centro de Custos e/ou item contábil não localizado na base Pedido de Compras: ' + cIdPedido )

                end if

            else

                MyConOut( 'Fornecedor não localizado na base pedido id: ' + cIdPedido )

            end if

        else

            MyConOut( 'Pedido já cadastrado na base id: ' + cIdPedido )

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
Lê a lista de array de dados dos pedidos de compras e executado o execauto mata120 de cada um
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 09/07/2020
@param aListaPC, array, Lista com dados de cabeçalho e itens dos pedidos de compras.
/*/
static function GravaPedidos( aListaPC )

    Local nX        := 0
    Local cIdSienge := ''
    Local cObs      := ''
    Local cNum      := ''
    Local aAreaSC7  := SC7->( GetArea() )

    Private lMsErroAuto    := .F.
    Private lMsHelpAuto    := .T.
    Private lAutoErrNoFile := .T.

    for nX := 1 To Len( aListaPC )

        cIdSienge := aListaPC[nX][1][aScan( aListaPC[ nX, 1 ], { | X | X[1] == 'C7_XNUMSIE' } )][2]
        cObs      := aListaPC[nX][1][aScan( aListaPC[ nX, 1 ], { | X | X[1] == 'C7_OBS'     } )][2]
        cNum      := aListaPC[nX][1][aScan( aListaPC[ nX, 1 ], { | X | X[1] == 'C7_NUM'     } )][2]

        Begin Transaction

            MsExecAuto( { |a,b,c,d| MATA120(a,b,c,d) }, 1, aListaPC[ nX, 1 ], aListaPC[ nX, 2 ], 3 )

            If lMsErroAuto

                lMsErroAuto := .F.

                MyConOut( 'Erro na inclusão do pedido de compra id: ' + cIdSienge )
                MsgErro( GetAutoGRLog() )

                DisarmTransaction()

            else

                if SC7->( DbSeek( xFilial() + cNum ) )

                    Do While SC7->( ! Eof() .And. C7_FILIAL + C7_NUM == xFilial() + cNum )

                        RecLock( 'SC7', .F. )

                        SC7->C7_XNUMSIE := cIdSienge
                        SC7->C7_CONAPRO := 'L'
                        SC7->C7_OBS     := cObs

                        SC7->( MsUnlock() )

                        SC7->( DbSkip() )

                    End Do

                end if

                SC7->( RestArea( aAreaSC7 ) )

            End If

        End Transaction

    next nX

return

/*/{Protheus.doc} BuscaForn
Busca pelo id o CNPJ do fornecedor no End Point correspondenete e valida busca do CNPJ na base e
popula as varáveis de código e loja do fornecedor 
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 20/07/2020
@param cIdFornec, character, Id de busca do fornecedor no End Point
@param cCodForn, character, Variável recebida por referência a ser populada com o código do fornecedor localizado na base 
@param cCodLoja, character, Variável recebida por referência a ser populada com a loja do fornecedor localizado na base
@return logical, Retorna verdadeiro se o CNPJ do Fornecedor foi lacalizado e as variáveis de códiogo e loja foram populadas
/*/
static function BuscaForn( cIdFornec, cCodForn, cCodLoja )

    Local cPath     := 'creditors/' + cIdFornec
    Local cCnpj     := ''
    Local lRet      := .F.
    Local oJson     := fetch( cPath, , 'Fornecedores' )

    if ValType( oJson ) == 'J'

        DbSelectArea( 'SA2' )
        SA2->( DBSetOrder( 3 ) ) // A2_FILIAL+A2_CGC

        cCnpj := StrTran( oJson['cnpj'] , '.', '' )
        cCnpj := StrTran( cCnpj         , '/', '' )
        cCnpj := StrTran( cCnpj         , '-', '' )

        if ! Empty( cCnpj ) .And. SA2->( DbSeek( xFilial() + cCnpj ) )

            cCodForn := SA2->A2_COD
            cCodLoja := SA2->A2_LOJA
            lRet := .T.

        else

            MyConOut( 'Não Foi Possível localizar o CNPJ do fornecedor na base de dados : ' + cIdFornec )

        end if

    end if

    SA2->( DbCloseArea() )

return lRet

/*/{Protheus.doc} BuscaCcIt
Busca o Centro de Custos e Item contábil correspondente ao ID recebido
@type static function
@version 12.1.17
@author elton.alves@totvs.com.br
@since 29/07/2020
@param nIdCC, number, ID do Centro de custo a ser buscado na base
@param nIdItCtb, number, ID do Item Contábil a ser buscado na base
@param cCC, character, Variável recebida por referência a ser populada com o código do centro de custo correspondente ao ID recebido 
@param cItCtb, character, Variável recebida por referência a ser populada com o código do item contábil correspondente ao ID recebido
@return logical, Indica se o ID do centro de custo e item contábil foram localizados e as variáveis correspondentes foram populadas
/*/
static function BuscaCcIt( nIdCC, nIdItCtb, cCC, cItCtb )

    Local lRet  := .T.
    Local aArea := GetArea()

    DbSelectArea( 'CTT' )
    CTT->( DBOrderNickname( 'CTTSIENGE' ) ) // CTT_FILIAL+CTT_XSIENG

    if CTT->( DbSeek( xFilial() + cValToChaR( nIdCC ) ) )

        cCC := CTT->CTT_CUSTO

    else

        lRet := .F.

    end if

    DbSelectArea( 'CTD' )
    CTD->( DBOrderNickname( 'CTDSIENGE' ) ) // CTD_FILIAL+CTD_XSIENG

    if CTD->( DbSeek( xFilial() + cValToChaR( nIdItCtb ) ) )

        cItCtb := CTD->CTD_CUSTO

    else

        lRet := .F.

    end if

    CTT->( DbCloseArea() )
    CTD->( DbCloseArea() )

    RestArea( aArea )

return lRet

/*/{Protheus.doc} GetItens
Busca no end point correspondente os itens do pedido de compra e popula o array para o execauto 
@type static function
@version 12.1.27
@author elton.alves@totvs.coml.br
@since 09/07/2020
@param cIdPedido, character, Id do pedido de compras
@param cCC, character, Centro de custo definido no cabeçalho do Pedido de Compras na propriedade a ser populado ao itens
@param cItCtb, character, Item Contábil definido no cabeçalho do Pedido de Compras a ser populado ao itens
@param aListaPC, array, Lista de pedidos de compras recebida por referência para ser populada com os itens do pedido
@return logical, Retorna verdadeiro se conseguiu buscar no end point os itens do pedido de compras e também que todos estejam no cadastro de produtos
/*/
static function  GetItens( cIdPedido, cCC, cItCtb, aListaPC )

    Local lRet      := .T.
    Local cPath     := '/purchase-orders/' + cIdPedido + '/items'
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

                MyConOut( 'Não foi possível localizar o item ' + cIdItem + ' do pedido de compras ' + cIdPedido )

                // Como um item não foi localizado no cadastro de produtos todo o processo para este pedido de compras é abortado
                lRet := .F.

                Exit

            end if

        next nX

    end if

    // Se todos os itens foram localizado no cadastro de produtos então o array com as linhas dos itens é adicionado ao array da lista de pedidos válidos
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

    Local cPath      := 'bills'
    Local nDateRef   := GetMv( 'SIE_ADTREF' )
    Local cStartDate := DateFormat( Date() - nDateRef )
    Local cEndDate   := DateFormat( Date() )
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

            DbSelectArea( 'SE2' )
            DbSetOrder( 1 ) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA

            // Verifica se o título no Sienge é do tipo "ADI", somente este tipo é incluido
            if AllTrim( aResult[nX]['documentIdentificationId'] ) == 'ADI'

                cIdFornec := cValTochar( aResult[nX]['creditorId'] )

                if BuscaForn( cIdFornec, @cCodForn, @cCodLoja )

                    cNum      := aResult[nX]["documentNumber"]
                    cData     := StoD( StrTran( aResult[nX]["issueDate"], '-', '' ) )
                    nValor    := aResult[nX]["totalInvoiceAmount"]
                    cNaturez  := GetMv( 'SIE_ADTNAT' )
                    cBanco    := '237'    // TODO Qual o banco do PA ?
                    cAgencia  := '1122'   // TODO Qual Agência do PA ?
                    cConta    := '112233' // TODO Qual Conta do PA ?

                    if ! SE2->( DbSeek( xFilial() +;
                            PadR( "SIE"    , TamSx3('E2_PREFIXO')[1] ) +;
                            PadR( cNum     , TamSx3('E2_NUM'    )[1] ) +;
                            PadR( ""       , TamSx3('E2_PARCELA')[1] ) +;
                            PadR( "PA"     , TamSx3('E2_TIPO'   )[1] ) +;
                            PadR( cCodForn , TamSx3('E2_FORNECE')[1] ) +;
                            PadR( cCodLoja , TamSx3('E2_LOJA'   )[1] ) ) )

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

                    end if

                else

                    MyConOut( 'Fornecedor não foi localizado na base adiantamento id: ' + cNum )

                end if

            end if

        next nx

    end if

    if ! Empty( aListaAd )

        GravaAdiant( aListaAd )

    end if

    SE2->( DbCloseArea() )

return

/*/{Protheus.doc} GravaAdiant
Lê a lista de array de dados dos adiantamentos e executado o execauto FINA050 de cada um
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

                MyConOut( 'Erro na inclusão do adiantamento id: ' + cIdSienge )
                MsgErro( GetAutoGRLog() )

                DisarmTransaction()

            end if

        End Transaction

    next nX

    //TODO Verificar como buscar do Sienge o pedido de compras a ser vinculado ao adiantamento

return

/*/{Protheus.doc} fetch
Função genériaca de busca de dados no Web Sercice do Sienge
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 17/07/2020
@param cPath, character, Path do caminho da requisição
@param cQuery, character, Parâmetros de busca 
@param cConsulta, character, Nome da consulta impressão de identificação na mensagem no console 
@return undefined, Retorna um array com a lista de itens requisitados ou um objeto json conforme solictado no parâmetro nTpRet 
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

        oFwRest:SetPath( cPrefix + cPath )

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

                MyConOut( 'Não Foi Possível Montar o JSON da consulta de "' + cConsulta + '" Erro => ' + cRet )

                Exit

            end if

        else

            MyConOut( 'Não Foi Possível efetuar a consulta de "' + cConsulta + '" Erro => ' + oFwRest:GetLastError() )

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
Recebe array com erros do execauto e gera saida no console 
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 09/07/2020
@param aErro, array, Array com a mensagem de erro
/*/
static function MsgErro( aErro )

    Local nX   := 0
    Local nLen := Len( aErro )

    For nX := 1 To nLen

        MyConOut( aErro[ nX ] )

    Next nX

Return

/*/{Protheus.doc} MyConOut
Executa o rotina de conout com um prefixo indicando que se refere a uma mensagem de integração com o SIENGE
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 07/07/2020
@param cMsg, character, Mensagem a ser exibida no console
/*/
static function MyConOut( cMsg )

    ConOut( '[ SIENGE ] = > ' + cMsg )

return

/*/{Protheus.doc} DateFormat
Formata uma data para uma string no formato yyyy-MM-dd aceito pelo SIENGE
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 24/07/2020
@param dDate, date, Data a ser convertida
@return caractere, Data convertida no formato yyyy-MM-dd de string para integração com o SIENGE
/*/
static function DateFormat( dDate )

    Local cYear  := cValToChar( Year( dDate )  )
    Local cMonth := StrZero( Month( dDate ), 2 )
    Local cDay   := StrZero( Day( dDate ), 2 )
    Local cRet   := cYear + '-' + cMonth + '-' +cDay

return cRet
