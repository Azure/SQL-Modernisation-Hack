# SQL Server Modernisation Hackathon #
This hackathon is a repetable IP listed in [Chrysalis](https://chrysalis.microsoft.com/) and can be used during the Execution Phase of [VBD: Proof of Concept for Migrating your Data Estate to Azure SQL](https://chrysalis.microsoft.com/Projects/993 "VBD: Proof of Concept for Migrating your Data Estate to Azure SQL").
Please refer to the “Installation Instructions” located at the bottom of the page to complete the delivery of this IP.

## Purpose of the Hackathon / Hands-on labs ##
In these hands-on labs, you will implement a proof-of-concept (PoC) for migrating an on-premises SQL Server 2012 or SQL Server 2016 database into Azure SQL Database Managed Instance (SQL MI). You will perform assessments to reveal any feature parity and compatibility issues between the on-premises SQL Server database and the managed database offerings in Azure. You will then migrate the customer's on-premises databases into Azure, using migration services. Additionally, you will migrate SSIS packages from on premise into Azure PaaS Services. Finally, you will enable some of the advanced SQL features available in SQL MI to improve security and performance in the customer's application.
At the end of this hands-on lab, you will be better able to implement a cloud migration solution for business-critical applications and databases. 

Except for Lab 1 (Migration), all other labs are optional for delivery. In an offline migration scenario, you can utilize Azure Data Studio for migration. For an online migration scenario, you have the optional choice of using SQL MI Link for the migration.

## Use Case ##
Awesome Trading inc. is an online trading company. Founded in 2012, the company has experience exponential growth since releasing its online trading platform. As part of their monitoring of ongoing trades, the company uses a legacy Application called the “Online Transaction Monitor”, which was originally written in VB6 and developed against a SQL Server 2012 and 2016 Databases.

Awesome Trading have started to find that the management of the SQL Server database is becoming too much to manage with the current support staff, and would like to reduce this burden on their support teams. As their service has also increased in popularity, the Stand-alone SQL server this database currently uses does not meet the 99.99% SLA for availability required, and they would prefer to use supported Windows and OS versions.

Awesome Trading would like to run a Proof of Concept (PoC) the “Online Transaction Monitor” and using PaaS Data Services in Azure. As the Trading platform is only used during business hours, Awesome Trading are happy for the PoC to be migrated with downtime over a weekend. However, there is a complication in that Awesome Trading do not have the latest up to date source code for this application, so the only thing that can be changed is the connection strings for this application. There is also a set of SSIS packages that feed a Datawarehouse that need to be factored. Additionally databases contain sensitive data, these  will need to be marked and encrypted during the migration and any other vulnerabilities assessed and resolved.

## Target audience ##

Up to 20 Teams of:

* Database administrators
* SQL/Database developers
* Application developers

## Lab Architecture ##

The following diagram provides an overview of the Lab environment that will be built.

**This architecture is designed for a classroom environment of up to 20 teams within a single subscription.**

![SQL Hack Architecture](https://github.com/markjones-msft/SQL-Hackathon/raw/master/Hands-On%20Lab/SQLHack%20Architecture.png "SQL Hack Architecture")

***NOTE: There are up to 20 workshop environments using a SHARED source SQL Server and Target Azure SQL Database. Please be respectful of only migrating your teams Databases and Logins.***

## Azure services and related products ##
* Azure SQL Database Managed Instance (SQL MI)
* Azure SQL Database (SQL DB)
* Azure Database Migration Service (DMS)
* Azure Data Studio
* Microsoft Data Migration Assistant (DMA)
* SQL Server 2012
* SQL Server 2016
* SQL Server on VM
* SQL Server Management Studio (SSMS)
* Azure virtual machines
* Visual Studio SSDT
* Azure virtual network
* Azure virtual network gateway
* Azure Blob Storage account
* Azure Key Vault
* Azure Data Factory
* Integration Runtime SSIS

## Instructions to Install ##

***NOTE This repositry will install a number of components within the designated subscription at an estimated cost of around $20 per day***

To install please complete the following:
1. Go to the BUILD folder and download the ARM Deployment - SQL Hackathon v2.ps1 powershell script.
2. Within Powershell ISE or VSCode - load the ARM Deployment - SQL Hackathon v2.ps1
3. Execute the ARM Deployment - SQL Hackathon v2.ps1 script, following the on screen prompts


 ## FaQ ##
What is the format of this hackathon ?
This is slightly different than official Microsoft Hackathons in that participants are following a step-by-step guide.

How many coaches ?
2 is the best, 3 can be beneficial if people are not very good at AZure etc.

What is the best practice for the delivery ?
This hackathon is delviered both on site and online. For the online version, the best practice is that 2 caoaches
in the same virtual room
If there are questions or conprehensive help requiremetn, one coach can create a break-out room in teams and help the attendde so that the main hackathon flow won't be    
Each part of the hackathion consists of a short theretical part followed by a practiocal Hands-On Lab.

Q:What are prerequsitis for the attendees.
A:No special required, however a general understanding of SQL Server or even other databases and basic knowledge on Azure significantly helps for the timely delivery and better results.


Q:Can this IP be delviered in conjunction of a VBD.
Yes, this has been acknowledged by xxx 

Refer to chrysalis,
refere VBD catalog, 

Q: Is the related VBD a customer funded VBD or MSFT funded VBD. How does it work with time booking.
If the VBD will be delivered over this execution path (over this VBD) this can both be MSFT or customer funded. This is a decision of the account team and the CSA manager, simply as for any other VBD.
However if it is delivered as a customer funded VBD, the total duration ofthe while time booking should be inline with the total duration of the VBD. This means, if there are 2 coaches, the days should be divided as 2 and 1 based on who has spent more time for preparation and post-hackathon actions, etc.

If it is delivered as a MSFT funded VBD, then total time booked by all CSA's is allowed to exceed the total duration of the VBD. (i.e both coaches are allowed to register 3 full days and the total booking time is 6 days, although the duration of the VBD is 3 days.) 
If you have further questions please reach out to Mert Senguner or Dhnaeshwari, so that we can provide different sample ROSS's where this has been the case. 




how I contacted RC's.


## Known Issues ##

