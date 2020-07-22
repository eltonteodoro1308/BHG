#include "Protheus.ch"

User Function F450CAES()

    Local cNumComp := PARAMIXB[1]
    Local nRetorno := PARAMIXB[2]
    Local cCommand := ''
    Local cTrab    := ''
    Local aArea    := GetArea()
    Local aAreaSE2 := SE2->( GetArea() )

    If nRetorno == 1

//        cCommand += " UPDATE " + RetSqlName( 'SE2' ) + " SET "
//        cCommand += " E2_BAIXA   = '', "
//        cCommand += " E2_SALDO   = E2_VLCRUZ, "
//        cCommand += " E2_VALLIQ  = 0, "
//        cCommand += " E2_IDENTEE = '' "
//        cCommand += " WHERE D_E_L_E_T_ = ' ' "
//        cCommand += " AND E2_IDENTEE = '"  + cNumComp + "' "
//    
//        TCSqlExec( cCommand )
//
//        cTrab := MPSysOpenQuery( "SELECT R_E_C_N_O_ RECNO FROM " + RetSqlName( 'SE2' ) + " WHERE D_E_L_E_T_ = ' ' AND E2_IDENTEE = '"  + cNumComp + "' " )
//
//        (cTrab)->( DbGoTop() )
//
//        Do While ! (cTrab)->( Eof() )
//
//            SE2->( DbGoTo( (cTrab)->RECNO ) )
//
//            RecLock( 'SE2', .F. )
//
//            SE2->E2_BAIXA   := CtoD('')
//            SE2->E2_SALDO   := SE2->E2_VLCRUZ
//            SE2->E2_VALLIQ  := 0
//            SE2->E2_IDENTEE := ''
//
//            SE2->( MsUnLock() )
//
//            (cTrab)->( DbSkip() )
//
//        End Do
//
//        (cTrab)->( DbCloseArea() )

    EndIf

    //SE2->( RestArea( aAreaSE2 ) )
    //RestArea( aArea )

Return nRetorno
