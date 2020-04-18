#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Run_Tidy=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.5
	Author:         OBELIKS

	Script Function:
	gcode cleanup
	To add more codes, edit gclean.ini and follow the example.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

#include <File.au3>
#include <Array.au3>

$delete = IniReadSection(@ScriptDir & "\gclean.ini", "delete")
$replace = IniReadSection(@ScriptDir & "\gclean.ini", "replace")
$temperature = IniReadSection(@ScriptDir & "\gclean.ini", "temperature")
$TbedOff = IniRead(@ScriptDir & "\gclean.ini", "config", "TbedOff")
$TnozzleOff = IniRead(@ScriptDir & "\gclean.ini", "config", "TnozzleOff")
$file_name = $CmdLine[1]
;~ $file_name = "test.gcode"
;~ FileDelete($file_name)
;~ FileCopy("original.gcode", $file_name)

Local $array
_FileReadToArray($file_name, $array)
$clean = _ArraySearch($array, ";PLSCLEANMENAO")
$lines = $array[0]

If $clean > 0 Then
	For $j = 1 To UBound($delete, 1) - 1
		Local $aResult = _ArrayFindAll($array, "^" & $delete[$j][0], Default, Default, Default, 3)
		_ArrayInsert($aResult, 0, UBound($aResult, 1))
		_ArrayDelete($array, $aResult)
	Next

	For $j = 1 To UBound($replace, 1) - 1
		Local $aResult = _ArrayFindAll($array, "^" & $replace[$j][0], Default, Default, Default, 3)
		For $k = 0 To UBound($aResult, 1) - 1
			If StringLeft($array[$aResult[$k]], 1) <> ";" Then
				$array[$aResult[$k]] = $replace[$j][1]
			EndIf
		Next
	Next

	For $j = 1 To UBound($temperature, 1) - 1
		Local $aResult = _ArrayFindAll($array, "^" & $temperature[$j][0], Default, Default, Default, 3)
		For $k = 0 To UBound($aResult, 1) - 1
			If StringLeft($array[$aResult[$k]], 1) <> ";" Then

				$original = StringRegExpReplace($array[$aResult[$k]], "^" & $temperature[$j][0] & " S", "")
				$original = StringRegExpReplace($original, " ;.*", "")

				If $original = 0 Then
					$new = 0
				Else
					If $temperature[$j][0] = "M104" or $temperature[$j][0] = "M109" Then
						$new = StringMid($array[$aResult[$k]], 7, 3) - $TnozzleOff
					Else
						$new = StringMid($array[$aResult[$k]], 7, 3) - $TbedOff
					EndIf
				EndIf
				$array[$aResult[$k]] = $temperature[$j][0] & " S" & $new
			EndIf
		Next
	Next

EndIf

_ArrayDelete($array, 0)
_FileWriteFromArray($file_name, $array)
