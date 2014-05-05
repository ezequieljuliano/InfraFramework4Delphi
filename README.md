Infra Database For Delphi
==================

The InfraDatabase4Delphi it is an API that facilitates the development of applications that target database. It is characterized by providing mechanisms that enable separate the application in layers and develop following the MVC (Model-View-Controller) architecture.

Its premise is to facilitate the use layering (MVC) without losing productivity, ie, enables the use of all the power of DBware components. In InfraDatabase4Delphi the Model represents one or more Data Modules with their corresponding data access components, the Controller is represented by a derived class of TDriverController and is responsible for all business rule, and the View is Form and components of interaction with the user.

This API allows the use of the main drivers of data access available for Delphi.

The InfraDatabase4Delphi was developed and tested using Delphi XE5.

Features
========

- DriverConnection: responsible for the connection to the driver data access.
- DriverConnectionManager: responsible for handling a set of database connections within the application.
- DriverSingletonConnection: Responsible for providing a connection to the Singleton pattern, ie, a single instance for the entire application.
- DriverController: class responsible for the business rule application.
- DriverDetails: detail controller class when using master-detail.

Drivers Adapters
======

The InfraDatabase4Delphi is available for the following data access drivers:

- FireDAC.


External Dependencies
=====================

The InfraDatabase4Delphi makes use of some external dependencies. Therefore these dependences are included in the project within the "dependencies" folder. If you use the library parser you should add to the Path PropertiesFile4Delphi and SQLBuilder4Delphi.

- PropertiesFile4Delphi: https://github.com/ezequieljuliano/PropertiesFile4Delphi
- SQLBuilder4Delphi: https://github.com/ezequieljuliano/SQLBuilder4Delphi


Samples
=========

Within the project there are a few examples of API usage. In addition there are also some unit tests that can aid in the use of InfraDatabase4Delphi.


Using InfraDatabase4Delphi
==========================

Using this API will is very simple, you simply add the Search Path of your IDE or your project the following directories:

- InfraDatabase4Delphi\dependencies\SQLBuilder4Delphi\src
- InfraDatabase4Delphi\dependencies\SQLBuilder4Delphi\dependencies\gaSQLParser\src
- InfraDatabase4Delphi\dependencies\PropertiesFile4Delphi\src
- InfraDatabase4Delphi\src


