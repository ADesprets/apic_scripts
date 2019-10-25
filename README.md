In this repository samples of script to operate API Connect for both Windows and Unix.

# Overview and approach

There are two aspects to operate in the context of API Connect:
* The YAML for each API and Product and the WSDL in case of a SOAP API
* The content of the YAML for fined grained control, for example, managing the Licenses and Terms section, or managing endpoint within properties for each catalog.

For the first case, manipulating the all yaml file, most of the work is performed using the apic command within the toolkit.
For the second case, we need to modify the content of the file, two approaches here:
* Using scripts to replace strings within the yaml that are pre positioned
* Using a YAML/Swagger parser. We will illustrate the latest in this tutorial.

Here is the output of the apic -h command for the V5 version of API Connect
```
Syntaxe : OPTIONS DE COMMANDE apic

  Options
    -h, --help        syntaxe de la commande
    -v, --version     version du produit
    --ext-version     version détaillée du toolkit

Commandes (entrez apic COMMAND -h pour accéder à une aide supplémentaire) :

  Création et validation d'artefacts
    config          gestion des variables de configuration
    create          création d'artefacts de développement
    edit            exécution d'API Designer
    validate        validation des artefacts de développement

  Création et test d'applications
    logs            affichage des journaux de maintenance
    loopback        création et gestion d'applications LoopBack

    microgateway    création d'applications Micro Gateway
    props           propriétés des services
    services        gestion des services
    start           démarrage des services
    stop            arrêt des services

  Publication dans le cloud
    apis            gestion des API dans un catalogue
    apps            gestion des applications fournisseur
    catalogs        gestion des catalogues dans une organisation
    devapps         gestion des applications client
    drafts          gestion des API et des produits dans des brouillons
    login           connexion à un cloud IBM API Connect
    logout          déconnexion d'un cloud IBM API Connect
    members         gestion des membres
    orgs            gestion des organisations
    policies        gestion des stratégies dans un catalogue
    products        gestion des produits dans un catalogue
    publish         publication des produits et des API dans un catalogue
    securegateways  gestion des passerelles sécurisées
    spaces          gestion des espaces dans un catalogue
    subscriptions   gestion des abonnements

```
The most useful apic commands are:
* Login: `apic login -s management.fr.ibm -u org1owner1@fr.ibm.com -p Passw0rd!`
* Get list of organizations: `apic organizations --server management.fr.ibm`
* Get list of catalogs: `apic catalogs --organization org1 --server management.fr.ibm`
* Get list of products: `apic products --catalog sb --organization org1 --server management.fr.ibm`
* Get drafts APIs and Products: `apic drafts --organization org1 -s management.fr.ibm`
* Get information on an API or a product: `apic drafts:get loansoap --organization org1 --server management.fr.ibm`
* Pull an API or a product definition from draft: `apic drafts:pull loansoap --organization org1 --server management.fr.ibm`
* Push an API or a product definition to draft: `apic drafts:push loansoap_2.0.0.yaml --organization org1 --server management.fr.ibm`
* Publish a product to a catalog: `apic publish loan-product_product_1.0.0.yaml --catalog sb --organization org1 --server management.fr.ibm`

**Hint**: In those samples the manager hostname is management.fr.ibm, you need to replace according your environment onPremise or in the cloud. uid and password of course need to be changed with the right account as well.


# Scope and use cases
The use cases are driven by the various roles included in API Connect. For more information, see : [API Connect user roles](https://www.ibm.com/support/knowledgecenter/SSMNED_5.0.0/com.ibm.apic.overview.doc/overview_apimgmt_users.html)


| Scope            | Role name                    | - | Scope            | Role name                    |
| ---------------- |:----------------------------:| - | ---------------- |:----------------------------:|
| Cloud Manager    | Cloud Owner                  | - | API Manager      | Owner                        |
| Cloud Manager    | Cloud Administrator          | - | API Manager      | Administrator                |
| Cloud Manager    | Organization Manager         | - | API Manager      | Product Manager              |
| Cloud Manager    | Topology Administrator       | - | API Manager      | API Developer                |
| Developer Portal | Developer Organization Owner | - | API Manager      | Publisher                    |
| Developer Portal | App Developer                |
| Developer Portal | Viewer                       |

More interesting for our cases are the permissions associated to the roles. In the following table, I have created a table will all the permissions and associated a number from 0 to 3, 0 means not a good candidate for scripting, 3 highly candidate for scripting. *This classification is from my personal experience and is not an IBM official statement.*

| Permissions	                                       | Type            | Likelyhood |
| -------------------------------------------------- |:---------------:|:----------:|
| Manage Manager and gateway services and servers    | Infrastructure  | 1          |
| Manage provider organizations and their owners     | Infrastructure  | 1          |
| Manage Cloud Manager users                         | Users/Orgs.     | 2          |
| Manage SSL identities                              | Infrastructure  | 2          |
| Manage user registries                             | Infrastructure  | 1          |
| Manage roles in the roles editing page             | Users/Orgs.     | 0          |
| Manage organization users                          | Users/Orgs.     | 2          |
| Manage draft APIs                                  | APIs life cycle | 3          |
| Manage draft Products                              | APIs life cycle | 3          |
| Approve Plan subscriptions                         | APIs life cycle | 2          |
| Manage Catalogs                                    | Infrastructure  | 1          |
| Manage developers and developer organizations      | Users/Orgs.     | 2          |
| Life cycle management of APIs/Products in catalogs | APIs life cycle | 3          |
| Manage Catalog members                             | Users/Orgs.     | 2          |
| Manage subscription approvals                      | APIs life cycle | 2          |
| Manage applications                                | Consumer side   | 1          |
| Manage Spaces                                      | Infrastructure  | 1          |
| Invite other users to join the developer orgs.     | Users/Orgs.     | 2          |
| Create applications                                | Consumer side   | 2          |
| Subscribe to use APIs                              | Consumer side   | 2          |

# Managing the content of the Swagger file programmaticaly



# Sample scripts
The scripts are organized in two directories, one for Windows one for Unix system.
And under each folder, there are two folders one for each version V5 and V2018.

The UNIX implementations are not finalized. Please feel free to implement using Windows implementation as a sample.

The first script **TestPublishVxxx** illustrates three basic operations:
1. List products and API in all catalogs and in draft for all organisation the user is authorized.
1. Backup all products and APIs in draft
1. Backup all catalogs
