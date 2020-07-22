#INCLUDE 'TOTVS.CH'
#DEFINE K_CTRL_E 5

User Function AfterLogin()

    SetKey( K_CTRL_E, { || ShowStack() } )

Return

static function ShowStack()

    n := 0

    while ! Empty( cPrg := ProcName( n ) )

        AutoGrLog( cPrg )

        n++

    end

    MostraErro()

return