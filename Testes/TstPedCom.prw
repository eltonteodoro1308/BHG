#include 'totvs.ch'

user function TstPedCom()

    Local aCabec := {}
    Local aLinha := {}
    Local aItens := {}

    Private lMsErroAuto    := .F.
    //Private lMsHelpAuto    := .T.
    //Private lAutoErrNoFile := .F.
    //GetNumSC7()                                                                                                                     

    RpcSetEnv( '01','010001' )


    //aAdd( aLinha, { "C7_FILIAL"     , '010001'  } )
    aadd( aCabec, { "C7_NUM" , "000036"  } )
    aadd( aCabec, { "C7_EMISSAO" , Date() })
    aAdd( aCabec, { "C7_FORNECE"   ,"SIE001   " } ) // Buscar CNPJ do fornecedor pelo end point de credores e com cnpj buscar na base o fornecedor
    aAdd( aCabec, { "C7_LOJA"     ,"00"        } )
    aAdd( aCabec, { "C7_COND"   ,"004"       } ) // Verificar a equivalência da consição de pagamento pelo campo E4_XSIENGE
    //aadd(aCabec,  { "C7_CONTATO" ,"AUTO"})
    //aadd(aCabec,  { "C7_FILENT" ,"010001"})
    aAdd( aCabec, { "C7_CONAPRO"  ,"L"         } )
    aAdd( aCabec, { "C7_XNUMSIE"  ,"5157"       } ) // Verificar a exitência do pedido na base para não duplicar
    aAdd( aCabec, { "C7_OBS"      ,"" } )
    aAdd( aCabec, { "C7_TPFRETE" , "C"        } ) // C - CIF e F - FOB verificar no sienge
    aAdd( aCabec, { "C7_FRETE"    , 0        } ) // Valor frete verificar sienge

    aAdd( aLinha, { "C7_ITEM"     , "0001"   , NIL } )
    aAdd( aLinha, { "C7_PRODUTO"      , "505045"   , nil } ) // Buscar código pelo código B1_XSIENGE
    aAdd( aLinha, { "C7_DESCRI"   , "ARGAMASSA"   , nil } )
    //aAdd( aLinha, { "UM"          , "UN"    , nil } )
    aAdd( aLinha, { "C7_QUANT"    , 150    , nil } )
    aAdd( aLinha, { "C7_PRECO"    , 14.91    , nil } )
    aAdd( aLinha, { "C7_TOTAL"    , 2236.5    , nil } )
    //aAdd( aLinha, { "C7_TES"      , "001"       , nil  } )
    //aAdd( aLinha, { "C7_DATPRF"    , Date()    , nil } )
    aAdd( aLinha, { "C7_OBSM"     , "PK REJ ACRIL CZA PLATINA BD 1KG"   , nil } )
    aAdd( aLinha, { "C7_LOCAL"    , "01" , nil } )
    aAdd( aLinha, { "C7_CC"       , "99999"   , nil } ) // Equivalente Centro de Custo
    aAdd( aLinha, { "C7_ITEMCTA"  , ""   , nil } ) // Equivalente Projeto
    aAdd( aLinha, { "C7_CONTA"    , ""   , nil } ) // Buscar conta no campo B1_CONTA vem gatilhado do padrão

    aAdd( aItens, aLinha )

    Begin Transaction

        MsExecAuto( { |a,b,c,d| MATA120(a,b,c,d) }, 1, aCabec, aItens, 3 )

        //cret := MATA120( 1, aCabec, aItens, 3 )

        If lMsErroAuto

            //AutoGrLog( MsgErro( GetAutoGRLog() ) )

            MostraErro()

            DisarmTransaction()

        else

            Alert('Incluído com sucesso')

        End If

    End Transaction


    RpcClearEnv()

return

/*
*C7_ITEM   -Item        
*C7_PRODUTO-Produto     
C7_UM     -Unidade     
*C7_QUANT  -Quantidade  
*C7_PRECO  -Prc Unitario
*C7_TOTAL  -Vlr.Total   
*C7_LOCAL  -Armazem     
*C7_CC     -Centro Custo
C7_FILCEN -Fil.Central.

*/
