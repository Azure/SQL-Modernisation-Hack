USE master;

CREATE LOGIN [watcher_user] WITH PASSWORD = '$(WatcherUserPassword)';

GRANT CONNECT SQL, CONNECT ANY DATABASE, VIEW ANY DATABASE, VIEW ANY DEFINITION, VIEW SERVER PERFORMANCE STATE TO [watcher_user];

USE msdb;

CREATE USER [watcher_user] FOR LOGIN [watcher_user];

GRANT SELECT ON dbo.sysjobactivity TO [watcher_user];
GRANT SELECT ON dbo.sysjobs TO [watcher_user];
GRANT SELECT ON dbo.syssessions TO [watcher_user];
GRANT SELECT ON dbo.sysjobhistory TO [watcher_user];
GRANT SELECT ON dbo.sysjobsteps TO [watcher_user];
GRANT SELECT ON dbo.syscategories TO [watcher_user];
GRANT SELECT ON dbo.sysoperators TO [watcher_user];
GRANT SELECT ON dbo.suspect_pages TO [watcher_user];
GRANT SELECT ON dbo.backupset TO [watcher_user];
GRANT SELECT ON dbo.backupmediaset TO [watcher_user];
GRANT SELECT ON dbo.backupmediafamily TO [watcher_user];