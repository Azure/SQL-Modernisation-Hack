# SQL Server Modernisation Hackathon #
This hackathon is [a repetable IP listed in Chrysalis](https://chrysalis.microsoft.com/assets/2155/) and can be used during the Execution Phase of the [VBD: Proof of Concept for Migrating your Data Estate to Azure SQL](https://chrysalis.microsoft.com/Projects/993 "VBD: Proof of Concept for Migrating your Data Estate to Azure SQL" ).
Please refer to the “Step-By-Step Guide For Delivery” located at the bottom of the page to deliver this IP.

## Purpose of the Hackathon / Hands-on labs ##
In these hands-on labs, the attendees will implement a proof-of-concept (PoC) for migrating an on-premises SQL Server 2012 or SQL Server 2016 database into Azure SQL Database Managed Instance (SQL MI). They will perform assessments to reveal any feature parity and compatibility issues between the on-premises SQL Server database and the managed database offerings in Azure. You will then migrate the customer's on-premises databases into Azure, using migration services. Optionally, attendees will migrate SSIS packages from on premise into Azure PaaS Services. Finally, they will enable some of the advanced SQL features available in SQL MI to improve security and performance in the customer's application.
At the end of this hands-on lab, you will be better able to implement a cloud migration solution for business-critical applications and databases. 

Full list of the Labs are as follows:

1.  **Lab 1a:**  Offline Migration with Azure Data Studio / **Lab 1b**: Online Migration with SQL MI Link
2.  **Lab 2 :**  Monitoring and Performance on SQL Managed Instance
3.  **Lab 3 :**  Security on SQL Managed Instance
4.  **Lab 4 :**  SSIS Migration  


Except for Lab 1, all other labs are optional for the delivery and independent from each other. In an offline migration scenario, you can utilize Azure Data Studio for migration which is Lab 1a. For an online migration scenario, you have the optional choice of using SQL MI Link for the migration, Lab 1b. 

Before each Lab, there is a short theoretical part recommended, the sample presantations of which have been provided in the repo. 

## Use Case ##
Awesome Trading inc. is an online trading company. Founded in 2012, the company has experience exponential growth since releasing its online trading platform. As part of their monitoring of ongoing trades, the company uses a legacy Application called the “Online Transaction Monitor”, which was originally written in VB6 and developed against a SQL Server 2012 and 2016 Databases.

Awesome Trading have started to find that the management of the SQL Server database is becoming too much to manage with the current support staff, and would like to reduce this burden on their support teams. As their service has also increased in popularity, the Stand-alone SQL server this database currently uses does not meet the 99.99% SLA for availability required, and they would prefer to use supported Windows and OS versions.

Awesome Trading would like to run a Proof of Concept (PoC) the “Online Transaction Monitor” and using PaaS Data Services in Azure. However, there is a complication in that Awesome Trading do not have the latest up to date source code for this application, so the only thing that can be changed is the connection strings for this application. There is also a set of SSIS packages that feed a Datawarehouse that need to be factored. Additionally databases contain sensitive data, these  will need to be marked and encrypted during the migration and any other vulnerabilities assessed and resolved.

## Target audience ##

Up to 20 Attendees:

* Database administrators
* SQL/Database developers
* Application developers

## Lab Architecture ##

The following diagram provides an overview of the Lab environment that will be built.

![SQL Hack Architecture](https://github.com/Azure/SQL-Modernisation-Hack/blob/main/HackathonArchitecture.jpg "SQL Hack Architecture")

**This architecture is designed for a classroom environment of up to 20 teams / participants within a single subscription.**
In order to deliver this hackathon, you can apply for a One-Time PASS subscription request up to 1500 $ and 30 days that can be extended after expiration, so that you can reuse it when necessary. Details for One-Time PASS subscription request have been given below in the section "How To Request for One-Time PASS Subscription and a Contoso Tenant for the delivery" 



***NOTE: There are up to 20 workshop environments using a SHARED source SQL Server and Target SQL Managed Instance. The attendees should be respectful of only migrating their teams Databases and Logins.***

## Azure services and related products used in the Hackathon ##
* Azure SQL  Managed Instance (SQL MI)
* Azure SQL Database (SQL DB)
* Azure Database Migration Service (DMS)
* Azure Data Studio (with Migration Extension)
* Microsoft Data Migration Assistant (DMA)
* SQL Server 2012 (source for offline migration scenario over Azure Data Studio and DMS)
* SQL Server 2016 (source for online migration scenario over SQL MI Link)
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


## Step-By-Step Guide For Delivery ##
- **Search the VBD** in your ESXP account and follow the necessary steps you do for any other delivery. Details regarding time booking and best practices for the delivery have been given in the FaQ section below.

- **Identify a peer CSA** who will act as the second coach.

- **Decide on what modules / labs of the repetable IP should be delivered**. Each Lab takes ~2 hours, incl. the theoretical part in the beginning. Here are the labs / modules you can combine and deliver:

    ->Overview of Azure SQL & Modernization - Migration paths​ (This is the Intro and cannot be skipped)

    ->Assessing & Migrating SQL Server databases to Azure SQL : **Lab 1** ( You need to choose between Lab 1a *Offline migration* or Lab 1b *Online Migration over MI Link.* Lab1 cannot be skipped.)

    ->Administering & Monitoring & Perf. Optimization Azure SQL MI​: **Lab 2**
    
    ->Securing Azure SQL Managed Instance: **Lab 3**

    ->SSIS Migration: **Lab 4**


- **Identify the subscription** where the Hackathon resources will be installed. 
If you cannot use the customer's subscription, **apply for the One-Time PASS Subscription and create a Contoso tenant for the delivery** (Instructions are given in the below section "How To Request for One-Time PASS Subscription and Create a Contoso Tenant for the delivery")
If you are allowed to use a customer subscription, you need to make sure that all access rights are granted on the customer's platform. Or you need to organize a provisioning session with a customer contact to provision the resources together.  

- **Provision the environment** at least 4-5 days before the delivery.
 There is a [detailed description for the provisioning](https://github.com/Azure/SQL-Modernisation-Hack/blob/main/Hack%20Environment%20-%20Setup%20and%20Reset%20MASTER.docx) among the repo. documents. Basically you will be taking those steps with the order, when you follow the instructions in the document: 

    ->Go to the BUILD folder and download the ARM Deployment - SQL Hackathon v2.ps1 powershell script 
    
    ->Within Powershell ISE or VSCode - load the ARM Deployment - SQL Hackathon v2.ps1

    ->Execute the ARM Deployment - SQL Hackathon v2.ps1 script, following the on screen prompts
    
    ->Run the Post Provisioning Scripts and the Post Provisioning Tasks as described in the document (i.e [detailed description for the provisioning](https://github.com/Azure/SQL-Modernisation-Hack/blob/main/Hack%20Environment%20-%20Setup%20and%20Reset%20MASTER.docx) )

    ->Automatically create users and grant permissions by running the CreateAdUsersAndPermissions.ps1 that is in the BUILD folder.

- **Do a Dry Run** for each Lab you want to deliver at least 2 days before the actual delivery
    
- **Synch. with your CSA peer** before the delivery

- **Deliver the hackathon**.  You can use the [presentation](https://github.com/Azure/SQL-Modernisation-Hack/blob/main/Presentations/FY24_Azure%20SQL%20Modernization%20Hackathon.pptx) as a reference and a good starting point. All instructions for the Labs are already given in the Lab docs uploaded to User VM's.  

- **Clean-up resources** as described in the [detailed description for the provisioning](https://github.com/Azure/SQL-Modernisation-Hack/blob/main/Hack%20Environment%20-%20Setup%20and%20Reset%20MASTER.docx)

 
 ***NOTE This repository will install a number of components within the designated subscription at an estimated cost of around $25 per day***

 If you use a PASS subscription for the delivery and encounter any quota limitations in the PASS subscription for the resources you need to provision, you can raise these quotas automatically with a ticket from within the Azure Portal under "Help + Support". This usally takes a couple of minutes and runs in the self-service mode. 

 (For any questions regarding provisioning and preparation you can reach out to [the owners of this IP](https://chrysalis.microsoft.com/assets/2155/))  



## How To Request for One-Time PASS Subscription and Create a Contoso Tenant for the delivery ##

If you cannot / don't prefer to use the customer's subscription for the delivery you need another tenant and a PASS subscription. To get this: 


1.Go to one-time PASS Request Page -> [Microsoft Azure Pass Requests](https://requests.microsoftazurepass.com/OneTime/Request)

2.Fill in the forms with the details (like PC 'Profit Center' Code, PC Program Approver Alias, Finance contract, etc. which are mandartory fields. Reach out to your finance contact in your region if you don't know these details. If you see any changes later on the input fields of the form or if you face rejection after your request: 
->A.  if it is related to finance related issues, reach out to your finance contact 
->B.  if it is due to some other reason, escalate it to regional BG team.
    
3.Create a new tenant using [Microsoft Customer Digital Experiences](https://cdx.transform.microsoft.com/my-tenants) to be used in your Hackathon.

4.Redeem the Promo Code that you will get after confirmation of your One-Time PASS request by following the instructions in the confirmation e-mail. Associate this Promo Code with the newly created tenant for the Hackathon in the previous step. (The assosiation will be done automatically when you fill in the form while redeeming the Promo Code for the PASS. You just need to provide the information for the new tenant.)

5.Check your balance on [Microsoft Azure Sponsorships | Balance](https://www.microsoftazuresponsorships.com/Balance) from time to time.Sign in with the admin and pass from the tenant created in the 3rd step.


## Potential Value of this Repetable IP ##

->Custom package selection is possible which is providing a jump-start to Azure SQL (4x2 Hour Packages can be combined for the delivery.)

->This IP offers a Step-by-step guide for 4 Labs with a story behind -> Migrate - optimize -administer- protect


->Every CSA can reproduce a guided workshop / hackathon with the same quality.

->Comprehensive provisioning scripts with all resources, labs and instructions ensure the reusability and repetability.


->When deployed directly to customer’s subscription, the whole lab environment generates instant consumption (alternatively you can use a PASS subscription.)



 ## FAQs ##
***Q*** : What is the format of this hackathon ?

***A*** This is slightly different than official Microsoft Hackathons in that participants are following a step-by-step guides for each lab. Each part of the hackathon consists of a short theretical part followed by a practical Hands-On Lab. This hackathon can be delivered both on-site and online and can be dedicated to one specific customer or be delivered as a multicustomer event.

***Q*** : How many coaches are recommended ?

***A*** : 2 coaches are necessary based on experience so far, 3 can be beneficial if vast majority of attendess are not familiar both with  Azure and SQL Server.

***Q*** : What is the best practice for the delivery ?
 
 ***A*** : For the online version, the best practice is that the 2 coaches and the attendees are present in the same Teams call during the whole duration.
If there are questions or comprehensive, individuall help is necessary, one coach exceptionally can create a break-out room in Teams and help the respective attendee in a 5 min 1:1 so that the main hackathon flow won't be affected or stopped. However, generic questions and challanges should be discussed with the whole audience in the main room.

***Q*** : What are prerequisits for the attendees ?

***A*** : No special skills are required, however a general understanding of SQL Server or even other databases and basic knowledge on Azure significantly help for the timely progression of the hackathon and better results.

***Q*** : Can this IP be delivered in conjunction with a VBD.

***A*** : Yes, it is strongly recommended to deliver this IP during the execution phase of the [VBD: Proof of Concept for Migrating your Data Estate to Azure SQL](https://chrysalis.microsoft.com/Projects/993) 


***Q*** : Is this IP/VBD a customer funded or a MSFT funded VBD ? 

***A*** : This IP/VBD can both be delivered in a MSFT or a customer funded way. This is a decision of the account team and the CSA manager, simply as for any other VBD.

***Q*** : How does it work with time booking when I want to deliver this VBD over this IP? 

***A*** : If this IP is delivered as a customer funded VBD, the total duration of the time booked in ESXP  should be inline with the total duration of the VBD. This means, if there are 2 coaches, the 3 days foreseen for this VBD should be divided as 2 days and 1 day based on who has spent more time for preparation and post-hackathon actions, etc. If it has to be delivered as a MSFT funded VBD, then total time booked by all CSA's is allowed to exceed the total duration of the VBD. I.e both coaches are allowed to register 3 full days and the total booking time can go up to 6 days, although the duration of the VBD itself is 3 days. This can be achieved by overriding a VBD via respective Resource Coordinators.) 
If you have further questions please reach out to Mert Senguner or Dhaneshwari Kumari, so that they can provide sample ROSS's confirmed by the Resource Coordinatators before. 

## Known Issues ##
The screens for Azure services on the portal and on the extensions on Azure Data Studio are rapidly changing with new updates and features. We try to maintain these changes as soon as possible, however it is sometimes impossible to keep each and every detail 100% up-to-date. For the occasions where there is a devaition from the lab docs, the CSA's / coaches should be prepared. So the best and easist way to overcome these kind of situations is to do Dry-Runs, a couple of days before the delivery.     
