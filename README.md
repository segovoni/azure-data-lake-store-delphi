# Azure Data Lake Store library for Delphi

From [Microsoft-Docs](https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/data-lake-store/data-lake-store-overview.md): Azure Data Lake Store is an enterprise-wide hyper-scale repository for big data analytic workloads. Azure Data Lake enables you to capture data of any size, type, and ingestion speed in one single place for operational and exploratory analytics.

## Introduction

Because I'm a Delphi developer, Microsoft Data Platform MVP since 2010 and because there are poor documentation about the integration between the Delphi programming language and Microsoft Azure services, I decided to do something for help Delphi developers to use Microsoft services and products. I developped a REST library to connect and manage an instance of Azure Data Lake Store.

This library is intended for Delphi developers those want to build applications that are able to connect to an instance of Azure Data Lake Store, retrieve an access token, upload data to the store, retrieve folder list and so on.

The library has been developped using Model View Presenter design pattern.

# Getting Started

This section explains how to getting start to use the ADLSLibrary4D to connect to an Azure Data Lake instance and manage data.

## Prerequisites

If you want to learn how to connect to an instance of Azure Data Lake from a Delphi application I suppose you already have an Azure subscription. Anyway, if you don't already have an Azure subscription, you can get one for free here: [get Azure free trial](https://azure.microsoft.com/en-us/free/).

When your Azure subscription is ready to use, you have to create an Azure Active Directory "Web" Application, to to that, you must have completed the steps explained in [Service-to-service authentication with Data Lake Store using Azure Active Directory](https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-service-to-service-authenticate-using-active-directory).

## Service-to-service authentication

To connect to an Azure Data Lake instance using service-to-service authentication, the application have to provides its own credentials to perform the operations. The application must send a POST request to the URL specified in the Access Token Endpoint field shown in the following picture. For the credentials, the application have to specify the Client ID and the Client Secret key that are provided during the creation of the [Azure Active Directory application and service principal](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal).

In short words, the application can get an access token by a POST request to the URL specified in the Access Token Endpoint with credentials specified respectively in the fields Client ID and Client Secret as showing in the following picture. Replace <TENANTID or DIRECTORYID> in the Access Token Endpoint with the Tenant ID of your Azure active directory.

![Picture 1](https://github.com/segovoni/azure-data-lake-store-delphi/blob/master/ADL%20Store%20Library%20for%20Delphi/img/ADLSLibrary4D_Connector.png)

Using the "Get Token" button the application will get the access token to be used later for file managing operations.

## Upload data

The upload data operation is based on the WebHDFS REST API call defined [here](http://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/WebHDFS.html#Create_and_Write_to_a_File). The application must send a PUT request to the URL specified in the field "Base URL" that is shows in the following picture.

![Picture 2](https://github.com/segovoni/azure-data-lake-store-delphi/blob/master/ADL%20Store%20Library%20for%20Delphi/img/ADLSLibrary4D_FileManager.png)

Replace <DATA LAKE STORE NAME> with the name of your Data Lake Store. The access token must be provided into the API call (see the source code for much details). The location of the file you are uploading must be provided in the resource property of the REST Request. The application can get the list of the folders contained in the Data Lake Store instance using a specific call (see ListFolders method implemented in the class TADLSFileManagerPresenter). The UploadFile method of the class TADLSFileManagerPresenter contains the code to do an upload request to Data Lake Store.
