
## Introduction

There are 3 technical types of SSL certificates we provide:

1. single-domain certificates – cover only 1 domain/subdomain name and its www subdomain;

2. multi-domain certificate – can secure three domain names for the original price. Overall, the certificate can secure up to 100 domain names (Please note that domain.com and www.domain.com are considered different domain names and need to be added separately.), 97 of them require additional payment;

3. wildcard certificates – can secure one domain name and all its one-level subdomains.

There is not an automated way to add domains to a multi-domain certificate.
The process is manual, unfortunately.
Extra domains can be added only during the reissue process as is explained [here](https://www.namecheap.com/support/knowledgebase/article.aspx/9282/2221/can-i-add-another-domain-later-after-the-ssl-certificate-has-been-issued-and-activated).

The or I have to replace the certificate each time I add a domain?

## Generating CSR code for Your Website

Use this tool:
https://decoder.link/csr_generator

Download 3 files: .CSR, .KEY and .CRT.

The .CRT is useless, because it is not trusted by browsers.
Instead, you should use the SSL certificate that you received from the Certificate Authority.

Reference:
https://www.namecheap.com/support/knowledgebase/article.aspx/467/67/how-do-i-generate-a-csr-code?_ga=2.106623811.113796572.1615728548-320150984.1609760198

## SSL Certificate Renewal

Step 1: Login to NameCheap

Step 2: Find the list of active SSL Certificates here:
https://ap.www.namecheap.com/ProductList/SslCertificates

Step 3: Click on `renew`, and pay the order.

Step 4: Find the new SSL certificate here:
https://ap.www.namecheap.com/ProductList/SslCertificates

Step 5: Click on `activate`.


## Reissue a Certificate

Go to the link above, and choose the option "Reissue" for the SSL certificate.

Follow the steps of the wizard.
Choose DNS CNAME record for domain ownership verification.

You can double-check the validation status here:
https://ap.www.namecheap.com/domains/ssl/productpage/13267413/SocialSellingMachine.com/dashboard

Reference:
https://www.namecheap.com/support/knowledgebase/article.aspx/811/14/how-do-i-reissue-my-ssl-certificate/


## Verification

Use this page to check if .crt and .key files match:
[https://www.sslshopper.com/certificate-key-matcher.html](https://www.sslshopper.com/certificate-key-matcher.html)


## Installation

CSR code is not needed for SSL installation. For installation on Nginx, you need to have end-entity and intermediate certificates bundled. You can paste your end-entity certificate into this tool: [https://decoder.link/result](https://decoder.link/result) then, scroll down to see the "Bundle (Nginx)" field.

* **End-entity certificate** is the one that issued for your domain name. This certificate was sent to you and has extension .crt. 

* **Intermediate certificates** are needed to create Trust Chain, they are sent to you in the .ca-bundle file.

Use this guide to install the certificates in Ngix:
[https://www.namecheap.com/support/knowledgebase/article.aspx/9419/33/installing-an-ssl-certificate-on-nginx/](https://www.namecheap.com/support/knowledgebase/article.aspx/9419/33/installing-an-ssl-certificate-on-nginx/)

Use this site to check if the which version of SSL certificate is installed:
[https://decoder.link/sslchecker/socialsellingmachine.com/443](https://decoder.link/sslchecker/socialsellingmachine.com/443)

Remember that both folders: $tempora/nginx and $tempora/ssl are replicated in the C: drive of each webserver.

Bundle CRT and Ca-Bundle files for NGINX. 

You need to have all the Certificates (your_domain.crt and your_domain.ca-bundle) combined in a single '.crt' file.

The Certificate for your domain should come first in the file, followed by the chain of Certificates (CA Bundle).

Download the SSL files from here:
https://ap.www.namecheap.com/ProductList/SslCertificates

Reference:
https://www.namecheap.com/support/knowledgebase/article.aspx/9419/33/installing-an-ssl-certificate-on-nginx/


## Reference Guide

[NameCheap Tutorial: How to Renew SSL Certificate](https://www.namecheap.com/support/knowledgebase/article.aspx/816/2217/how-to-renew-an-ssl-certificate/)