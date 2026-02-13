<<<<<<< HEAD
## How we have handled secret in the   Azure VM creation 

os.environ["AZURE_TENANT_ID"] which we have specified as this is not sensitive information 
os.environ["AZURE_CLIENT_ID"] which we have specified as this is not sensitive information
AZURE_CLIENT_SECRET this we need to create in .env file root of our python folder and specify locally 
recommend not to upload any secret / sensitive information like password, API keys, Service Principal keys into Github as this is  Data Security concern and not Craft exellence attribute

so DefaultAzureCredential() automatically picks these parameters to fetch token, secret it fetch from local .env file 

Flow of VM creation using python 

1. First fetch API Access Token by using Service Principal and its secret
2. Ask user where they want to deploy the  new VM
3. Fetch all resource groups available in all regions use Get methode of REST API to create a virtual machine ( Pass API end point  and access token for authentication and authorization) 
4. set resource group and region as per user inputs
5. Create a Virtual Machine NIC in region and resource group of User choice
6. use PUT methode of REST API to create a virtual machine NIC ( Pass API end point, Data as NIC parameters , and access token for authentication and authorization) 
7. fetch NIC ID and pass this into the Data field for API when we will create Virtual machine
8. Finally use PUT methode of REST API to create a virtual machine ( Pass API end point, Data as VM parameters , and access token for authentication and authorization)











Reach out to admin@jitendrasingh.net if you need any help around any files or concept in this Git Repo 
=======

## How we have handled secret in the   Azure VM creation 



os.environ["AZURE_TENANT_ID"] which we have specified as this is not sensitive information 

os.environ["AZURE_CLIENT_ID"] which we have specified as this is not sensitive information

AZURE_CLIENT_SECRET this we need to create in .env file root of our python folder and specify locally 

recommend not to upload any secret / sensitive information like password, API keys, Service Principal keys into Github as this is  Data Security concern and not Craft exellence attribute



so DefaultAzureCredential() automatically picks these parameters to fetch token, secret it fetch from local .env file 



Flow of VM creation using python 



1. First fetch API Access Token by using Service Principal and its secret

2. Ask user where they want to deploy the  new VM

3. Fetch all resource groups available in all regions use Get methode of REST API to create a virtual machine ( Pass API end point  and access token for authentication and authorization) 

4. set resource group and region as per user inputs

5. Create a Virtual Machine NIC in region and resource group of User choice

6. use PUT methode of REST API to create a virtual machine NIC ( Pass API end point, Data as NIC parameters , and access token for authentication and authorization) 

7. fetch NIC ID and pass this into the Data field for API when we will create Virtual machine

8. Finally use PUT methode of REST API to create a virtual machine ( Pass API end point, Data as VM parameters , and access token for authentication and authorization)
>>>>>>> 4ba8fa463c448f1507cf739973e1bf4660de0bf6
