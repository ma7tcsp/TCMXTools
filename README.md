# TCMXTools
Tableau CMT tools for multi-site 

Tableau Content Migration Tool (CMT) provides a very user-friendly way to copy workbooks between sites/servers and offers the ability to manipulate the workbooks being copied by changing data sources and such information inside the workbooks. Much of this can be done by scripting using the REST API and the Document API, however the GUI framework of CMT makes the entry point to this much lower and simpler. However, as of yet, CMT does not provide a way to easily copy a workbook to multiple sites without creating a plan for every single site. This type of scenario is very common when embedding Tableau and offering analytics for external clients, where each client has a different site. This tool aims to address this limitation by automatically generating multiple CMT plans, one for each site, and executing them on batch. The values for the sites is all parameterised via a simple csv file. 
In addition to copying a workbooks/data sources between sites, each site will ordinarily have its own data source, and hence the CMT plans can chage these during the migration process. Again, this tool allows for parameterisation of information in the csv file. 

This is not a fully flegded script to do everything, and the example shown is quite specific, but shows how a template workbook and site can be simply used. 

## Set Up
In this example we have 5 sites. 

Site: Default. This is where our "Dev" workbook lives. This is where our content is created and where our development data sources live. 

Site: \_\_\_MapTemplate_\_\_. This is our dummy - or template site. This is just for use with the CMT tool as a dummy destination.

Sites: AAA, BBB, CCC are all destination sites - where our content will be distributed. 

In this example a workbook has been set up to use pubished data source. The data source has been generated using Custom SQL. This is simply as an example. CMT allows for altering many facets regarding data sources, however Custom SQL was used in this example to show how it could be changed for each site. The data source is the same for each site, but each site will then retrieve an extract of the data based on a field. In this example case, we're using a PostgreSQL database of Superstore and each client will have a different Region. 

## Default or Template Site
In this site, we simply create our workbook as we normally would. We need to use a cut of the data for development, so in this exmaple I've picked Canada as the development Region. 

Custom SQL: select * from "global_superstore" where "Region" = 'Canada'

This data source was then published and set as an extract. A workbook was then created using this data souce, and simply called "template wb".

![image](https://user-images.githubusercontent.com/47423639/154929057-e701538f-bde5-43bc-8c48-4bbd0387f2a9.png)

# Using CMT 
The first thing we want to do, is create our initial plan and start to parameterise this for us to use later. So in this case we're simply going to migrate from our Default site, to our dummy mapping site. 

![image](https://user-images.githubusercontent.com/47423639/154929389-01086b61-be3a-414b-a561-c58363a86656.png)

We can then select our template workbook, and in the mapping section, we want to rename this. And this is where we rename to our workbook token which we call \_\_\_WB\_\_\_

![image](https://user-images.githubusercontent.com/47423639/154929558-d63c1dc4-69f6-4574-b764-85339e1672b1.png)

As we are using a published data source in this example, we don't need to perform any other transformations. 

In the Published Data Sources section of CMT we need to select our Custom SQL Query as this is what we want to alter for each site. We then perform a simplar renaming mapping to a token, this time \_\_\_DS\_\_\_

![image](https://user-images.githubusercontent.com/47423639/154930137-0211222d-694a-49a0-ab55-afb5dc03b405.png)

This time we do have to perform a couple of transformations. Firstly, as we're publishing essentially a new data source to each site, we need to provide the credentials explicitly.   

![image](https://user-images.githubusercontent.com/47423639/154930456-5fbe4f61-bef6-4897-b5fb-2739256e0ead.png)


And then we must chage the SQL as each site will need a different Region value. We again parameterise this Region value, this time to \_\_\_ID\_\_\_

![image](https://user-images.githubusercontent.com/47423639/154930695-ca168547-e837-485f-a3f5-27bcdf591bfe.png)

As we're working with extracts, the final step is just to ensure we Refresh Extracts After Migration in the Plan Options. 

We will then save this plan as \_\_\_MAP\_\_\.tcmx. Place this file in the root of TCMX Tools. 

![image](https://user-images.githubusercontent.com/47423639/154933874-a0a1c6dc-d02b-4800-bbb4-14f9a4c66028.png)


If we executre this plan, we'll see a new workbook and datasouce show up in our dummy mapping site, but this step isn't necessary. No data will be returned as the regional value will be set to a token (\_\_\_ID\_\_\_), which has specificlly been chosen to NOT exist in the field Region. 

![image](https://user-images.githubusercontent.com/47423639/154931475-befbba58-98b7-4f97-b866-a5ff697ad44b.png)


## CSV 
A tcmx file is a Tableau CMT plan file. Inside our plan, we have now parameterised several key bit of informaiton. 

Desintaion Site Name: \_\_\_MapTemplate\_\_\_

Destination Workbook Name: \_\_\_WB\_\_\_

Destination Data Source Name: \_\_\_DS\_\_\_

Destination Region WHERE clause in the Custom SQL: \_\_\_ID\_\_\_

In addition to this we need a name for the new plan file tcmx which gets created. 

This is what our demo csv looks like

![image](https://user-images.githubusercontent.com/47423639/154932835-5bbae178-13f2-49f9-9e17-ade974ccdd8c.png)

As you can see, we're going to generate 3 tcmx plans, one for each site. We're going to set the workbook and data source names for each site, as well as set a specific region to each site in the SQL. 

## The Script - Part 1
A tcmx file is simple a zipped XML of the execution plan, as well as a specific version file so that CMT plans can remain backwards compatible. The script simply parses this informaion and for each line in the CSV generates a copy of the tcmx. When copying, the tokens are found inside the XML file and replaced with the relevant values from the csv. Upon running this script, this will create 3 tcmx files in the output folder. All these files are stand-alone and will work manually with the CMT tool and the replacement values could be checked here. NB Although these files are named .zip as they're in the correct format, CMT will accept these. 

![image](https://user-images.githubusercontent.com/47423639/154933992-de210d8c-9e86-44b6-85fd-b6b53d815e5a.png)

As we can see, we've opened up sitea.zip in CMT, the destination site has been set to AAA and the new workbook name is Asda Workbook. 

![image](https://user-images.githubusercontent.com/47423639/154934423-1e366eee-4263-40ea-93b9-1458663bde6b.png)

## The Script - Part 2
CMT also provides a CLI to run plan files. This provides a programatic way of batching together plans for execution. The second part of this scrip optionally then runs all the plans in the output folder. This is simply a sequentional operation, and the output is logged into the runlog folder as a plain text file. The very last line, the Exit Code indicates if the operation was sucessful, a 0 being a success. 

![image](https://user-images.githubusercontent.com/47423639/154934937-424e8e29-e04d-4ef8-a016-c1994b4c97a9.png)


## Final Result 
Assuming everything ran correclty, we will now have 3 sites populated with a workbook and associated data source. The data source will be a cut of the data based on a field of the database, in this case Region. Example for site AAA

![image](https://user-images.githubusercontent.com/47423639/154935498-b120856a-bf26-4d34-af63-4e03198e7be2.png)

And the dashboard just showing the relevant values for the Oceania region 

![image](https://user-images.githubusercontent.com/47423639/154935983-ca8952ee-f8d2-4946-a51b-4b663fb391be.png)

## Final thoughts
This concept can easily be extended to cover off any mapping or tranformation value in the CMT. Ultimaty the CMT is an excellent tool for peerforming the trnaslations and mappings, this script simply piggy-backs onto this to generate execution plans. The idea of using the tokenised approach can therfore be extended very easily. 

This script is provided as-is, with zero support and contains no error checking. If spaces are used in site names and differe from the URL paths it will no doubt break instantly. This is just a script to demonstrate a technique for using CMT to publish to multiple sites. CMT is a Windows only tool, hence why I deceided to dust off batch scripiting ;). In te real world - please use something sensible! 
