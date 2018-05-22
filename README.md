# Business Value Insights (BVI)

The Business Value Insights (BVI) Dashboard is designed to provide leadership, project teams, and service partners insights to how G Suite is being utilized and its impact. The scope of this solution goes beyond what is provided in the Admin console to provide deep insights into adoption, collaboration, and impact in a more detailed (per user) way.

The template solution provided give customers a comprehensive starting point to build out a flexible reporting dashboard to meet their needs. The template allows customers to choose between using Google’s Reports APIs or detailed audit log files exported to BigQuery (BQ) on a nightly basis, providing their G Suite edition allows them this option in the Admin Panel.  

The solution described in this guide is built 100% with Google Cloud Platform (GCP) solutions and Google’s Data Studio product. All the information provided in this guide and other supporting documentation is based on GCP & Data Studio. Alternative solutions may be substituted at the discretion of the development team to suit a customer’s needs. 

This is not an official Google Cloud product, but rather is a template for deploying a working dashboard as at the time of publication. This document provides the guidance necessary for extracting the required data using the Reports API or BQ export and making calculations on the chosen aggregation level, such as Department, Location, OU, etc. A Data Studio Dashboard is then used to visualize the metrics at the domain, OU, team, and individual level.

The expectation is that G Suite reseller partners will take this template and work with a customer’s requirements to implement and maintain a working solution without the need for Google’s involvement or support.


### Prerequisites

The tools mentioned below are for illustrative purposes and not required to complete the solution. If the developer prefers an alternative tool, substitutes may be used at the user's discretion. In some cases, the customer may have a preference on tools to substitute for the following list. 

* **G Suite Reports API:** The source of all G Suite usage data. For additional information on the APIs used in this project, view the Querying the APIs section. The APIs report G Suite usage data both at the customer or account level (via the Customer Usage API) and at the individual usage level (via the User Usage API and the Activities API). 

* **G Suite Admin API:** Source for user list information. 

* **Google App Engine (GAE):** GAE is a hosted web server where we will host python scripts used to query the API and push data to the data warehouse, BigQuery. 

* **Google BigQuery:** BigQuery will serve as our data warehouse, which will store all data from the Reports API and will be queried against to produce reports in the data visualization tool, Data Studio. 

* **Google Data Studio (Beta):** This free beta version* is the selected data visualization tool used in this guide and will be the front end for the dashboard created. 

* **Google Sheets:** It will be used to store surveys as well as custom fields and be connected to Big Query to have the data used with some other tables and visualized on Data Studio. 

## Deployment

Please follow the Deployment Guide available on the Google Cloud Connect Portal

## License

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.