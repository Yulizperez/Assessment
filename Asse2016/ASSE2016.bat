pause
sqlcmd -S EXPSATURNO1 -d master -i %CD%\assessment2016.sql -m 1 > %CD%\EXPSATURNO1_Sis&Config.txt
sqlcmd -S EXPSATURNO1 -d master -i %CD%\SQL_Usuario.sql -m 1 > %CD%\EXPSATURNO1_USUARIOS.txt
sqlcmd -S EXPSATURNO1 -d master -i %CD%\LinkedServers.sql -m 1 > %CD%\EXPSATURNO1_LinkedServers.txt
pause