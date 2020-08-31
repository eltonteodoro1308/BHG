#include "totvs.ch"

/*/{Protheus.doc} F450CAES
O ponto de entrada F450CAES � utilizado para validar ou executar algum procedimento ap�s o usu�rio confirmar o Cancelamento/Estorno da compensa��o entre carteiras.
O objetivo aqui � que o cancelamento seja feito apenas se foi selecionada a mesma Empresa/Filial selecionada no momento de executar a compensa��o.
Ser� exibido um alerta indicando a Empresa/Filial que deve ser selecionada.
@type user function 
@version 12.1.27
@author elton.alves@totvs.com.br
@since 28/08/2020
@return numerico, retorna 1 para permitir o estorno/cancelamento e 0 para n�o permitir
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

            Alert( 'Selecione a Empresa/Filail ' + cFil + ' para efetuar o estorno/cancelamento da compensa��o ' + cNumComp ) 

            nRetorno := 0

        end if

        ( cTrb )->( DbCloseArea() )

    EndIf

Return nRetorno
