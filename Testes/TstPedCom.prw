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

    aadd( aCabec, { "C7_NUM"     , GetNumSC7() } )
    aadd( aCabec, { "C7_EMISSAO" , Date()      } )
    aAdd( aCabec, { "C7_FORNECE" , '402384402' } )
    aAdd( aCabec, { "C7_LOJA"    , '01'          } )
    aAdd( aCabec, { "C7_COND"    , '004'       } )
    aAdd( aCabec, { "C7_CONAPRO" , 'L'         } )
    aAdd( aCabec, { "C7_XNUMSIE" , 'SIETESTE'  } )
    aAdd( aCabec, { "C7_OBS"     , 'OBS CABEC' } )
    aAdd( aCabec, { "C7_TPFRETE" , 'F'         } )
    aAdd( aCabec, { "C7_DESPESA" , 134.56      } )
    aAdd( aCabec, { "C7_FRETCON" , 324.67      } )


    aAdd( aLinha, { "C7_ITEM"     , "0001"    , NIL } )
    aAdd( aLinha, { "C7_PRODUTO"  , "599998"   , nil } )
    aAdd( aLinha, { "C7_DESCRI"   , 'DIFAL'    , nil } )
    aAdd( aLinha, { "C7_QUANT"    , 10         , nil } )
    aAdd( aLinha, { "C7_PRECO"    , 150        , nil } )
    aAdd( aLinha, { "C7_TOTAL"    , 10*150     , nil } )
    aAdd( aLinha, { "C7_OBSM"     , 'OBS ITEM' , nil } )
    aAdd( aLinha, { "C7_LOCAL"    , '01'       , nil } )
    aAdd( aLinha, { "C7_CC"       , '31103'    , nil } ) // Equivalente Centro de Custo
    aAdd( aLinha, { "C7_ITEMCTA"  , '01001'    , nil } ) // Equivalente Projeto
    aAdd( aLinha, { "C7_CONTA"    , '21101002' , nil } )

    aAdd( aItens, aLinha )

    Begin Transaction

        MsExecAuto( { |a,b,c,d| MATA120(a,b,c,d) }, 1, aCabec, aItens, 3 )

        If lMsErroAuto

            MostraErro()

            DisarmTransaction()

        else

            Alert('Incluído com sucesso')

        End If

    End Transaction


    RpcClearEnv()

return
