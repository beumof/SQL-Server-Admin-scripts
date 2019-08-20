::File: Collation/CollationChange.cmd
::Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
::Added in 2019-0820
::Commentaries: SQL Service must be stopped.
::Origin: https://www.mssqltips.com/sqlservertip/3519/changing-sql-server-collation-after-installation/

sqlservr -m -T4022 -T3659 -q"SQL_Latin1_General_CP1_CI_AI"