# a02. Folders

Any **MySaaS** project has a well defined folders structure.

## a02.1. ORM Regarding Folders

1. `models`: Here are all the classes who inherit from `Sequel::Model`, directly or indirectly.
Except the classes who inherit from `BlackStack::Notification`, who are placed in the `notifications` folder.

2. `notifications`: Here are all the classes who inherit from `BlackStack::Notification`, directly or indirectly.

## a02.2. Background Processing Folders

3. `p`: Here are all the classes who inherit from `BlackStack::Pampa::Process`, dirctly or indirectly.

4. `dispatchers`: Here are all the hash descriptors for dispatching [**Pampa**](https://github.com/leandrosardi/pampa) proocesses.

5. `cli`: Here are just all the commands for running operations manually.

## a02.3. Deplying Folders

6. `deployment-routines`: Here are all the has descriptors for running [**BlackStack-Deployer**](https://github.com/leandrosardi/blackstack-deployer).

7. `sql`: Here are all the database updates to be executed by [**BlackStack-Deployer**](https://github.com/leandrosardi/blackstack-deployer).

8. `gems`: Here are some private gems that are not published, so you need them in your repository in order to install them on servers. **MySaaS** has a [**BlackStack-Deployer**](https://github.com/leandrosardi/blackstack-deployer)'s routine for installing all the gemfiles in this folder. 

## a02.4. Front-end Folders

9. `views`: Here are all the screens.

10. `public`: Here are all the resources for the screens:
	- `public/css`; 
	- `public/images`; 
	- `public/javascripts`;
	- `public/fonts`.

## a02.5. Additional Folders

11. `examples`: Here are some code examples of each extension. 

12. `docu`: Here are markdown files with the documentation of each extension.

13. `extensions`: In this folder we clone other repositories who can be added as modules of your MySaaS project.