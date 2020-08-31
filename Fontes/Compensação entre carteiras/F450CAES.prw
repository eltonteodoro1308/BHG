#include "totvs.ch"

/*/{Protheus.doc} F450CAES
O ponto de entrada F450CAES é utilizado para validar ou executar algum procedimento após o usuário confirmar o Cancelamento/Estorno da compensação entre carteiras.
O objetivo aqui é que o cancelamento seja feito apenas se foi selecionada a mesma Empresa/Filial selecionada no momento de executar a compensação.
Será exibido um alerta indicando a Empresa/Filial que deve ser selecionada.
@type user function 
@version 12.1.27
@author elton.alves@totvs.com.br
@since 28/08/2020
@return numerico, retorna 1 para permitir o estorno/cancelamento e 0 para não permitir
/*/
user function F450CAES()

    Local cNumComp := PARAMIXB[1]
    Local nRetorno := PARAMIXB[2]
    Local cFil     := ''    
    Local cTrb     := ''

    If nRetorno == 1

        cTrb := GetNextAlias()

        BeginSql Alias cTrb

            SELECT E5_FILIAL 
            FROM %TABLE:SE5% 
            WHERE %NOTDEL%
            AND E5_IDENTEE = %EXP:cNumComp%

        EndSql

        cFil := ( cTrb )->E5_FILIAL

        if cFilAnt <> cFil

            Alert( 'Selecione a Empresa/Filail ' + cFil + ' para efetuar o estorno/cancelamento da compensação ' + cNumComp ) 

            nRetorno := 0

        end if

        ( cTrb )->( DbCloseArea() )

    EndIf

Return nRetorno
