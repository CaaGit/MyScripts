# Exchange-Server-environment-monitoring-scripts

Some monitoring scripts I'm collecting and adapting for general used

# Download current repository's scripts

Right-click "Save link as" on the below script links:

![image](https://user-images.githubusercontent.com/33433229/121607016-4414ac80-ca1d-11eb-9a70-e78fbd7801df.png)


|Script name|Script purpose|Script link|Credits| Credits link|
|-----------|--------------|-----------|-------|------------|
|DAG table | Export dag table and status | [Dump DAG map](https://raw.githubusercontent.com/SammyKrosoft/Exchange-Server-environment-monitoring-scripts/main/ExchangeDAGDatabaseDistributionTable.ps1)|Ammar Hasayen|[Ammar Hasayen's blog](https://blog.ahasayen.com/)|


> Note: when you download a script from the web, a Microsoft browser will flag the script file as "blocked". Some non Microsoft browsers or applications don't flag it. If it does, right-click on the downloaded script, open Properties, and check the "Unblock" box, and click "Apply":
>
>![image](https://user-images.githubusercontent.com/33433229/121628383-1a707b00-ca47-11eb-96f1-e21a68676c19.png)
>
> then you're good to go launch the script, on a PowerShell console with PowerShell's "RemoteSigned" execution policy in place. You may need to set the PowerShell execution policy to "RemoteSigned" on some workstations as often the default PowerShell execution policy is "Restricted", preventing the execution of any PowerShell scripts.
