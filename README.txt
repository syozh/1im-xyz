Example implementation of PS-connector to data in Json-file

1) To test PS-module Xyz.psm1: run Test-Xyz.ps1
   NLog.dll and NLog.config used for local logging to the Xyz.log

2) Import transports to OneIM:
   Transport-Xyz-TargetSystem.zip
   Transport-Xyz-ProjectAndProcess.zip

3) Copy Xyz.ps1 to PS-modules directory, I used "С:\tmp\xyz"

4) Edit target system connection settings (module path, Json-file path) and 
   set base object in the sync. project.

5) Add to globallog.config target and loggers:
   ...
   <target name="XyzLogFile" xsi:type="File" fileName="C:/tmp/xyz/Xyz.log" layout="${layout}" encoding="utf-8" archiveFileName="C:/tmp/xyz/Xyz.{#}.log" maxArchiveFiles="7" archiveEvery="Day" archiveNumbering="Rolling"/>
   ...
   <logger name="XyzConnectorLog" minlevel="Trace" writeTo="XyzLogFile"/>
   <logger name="XyzProvisionLog" minlevel="Trace" writeTo="XyzLogFile"/>
   ...

Questions
=========
  1) Why Update-method of PS-connector pass on to the PS-module command (Set-XyzAccount) changed attributes only 
     even if ForceSyncOf parameter was set.

     I.e. if the account (UNSAccountB) had been changed like this:
     ObjectGUID  (mapped to id)   : 1
     FirstName   (mapped to fname): 'Alice'
     LastName    (mapped to lname): 'Anderson'
     Description (mapped to title): 'CTO' => 'CSO'

     then connector will call command with such arguments:
     Set-XyzAccount id=1 fname='' lname='' title='CSO'

  2) If method Update (Create) consists of many commands (like Set-XyzAccount, Set-XyzAccount2, ...) and
     commands have common parameters, then all subsequent commands receive empty parameters after the first
     I.e.
     Set-XyzAccount  id=1 title='Big boss'
     Set-XyzAccount2 id=1 title=''
     ...
