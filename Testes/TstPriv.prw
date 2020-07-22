#include 'totvs.ch'

user function TstPriv()

    Local cDataBase := GetPvProfString( 'DBACCESS', 'DATABASE' , '', GetSrvIniName() )
    Local cAlias    := GetPvProfString( 'DBACCESS', 'ALIAS'    , '', GetSrvIniName() )
    Local cServer   := GetPvProfString( 'DBACCESS', 'SERVER'   , '', GetSrvIniName() )
    Local nPort     := GetPvProfileInt( 'DBACCESS', 'PORT'     ,  0, GetSrvIniName() )
    Local oDbAccess := FwDbAccess():New( cDataBase + '/' + cAlias, cServer, nPort )
    Local cTmp      := ''

    if oDbAccess:OpenConnection()

        cTmp := oDbAccess:NewAlias( "SELECT COUNT(*) FROM SYS_COMPANY WHERE D_E_L_E_T_ = ' '", 'SM0' )

    end

    oDbAccess:CloseConnection()
    oDbAccess:Finish()

return
