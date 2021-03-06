# Configure CIFs share on Avere

This page shows the steps to configure CIFS on Avere.

All the steps below assume you have brought up the [vFXT Cluster GUI](https://docs.microsoft.com/en-us/azure/avere-vfxt/avere-vfxt-cluster-gui) in the browser.

For more detailed setup information see the [Avere Active Directory Administrator Guide to Avere FXT Deployment](https://azure.github.io/Avere/legacy/pdf/ADAdminCIFSACLsGuide_20140716.pdf) and the [VServer>CIFS document](https://azure.github.io/Avere/legacy/ops_guide/4_6/html/gui_cifs.html).

## Configure DNS

1. Browse to Settings->Administrative Network and configure the DNS server:

    <p align="center">
       <img src="images/administrativenetwork.png" width="800">
    </p>

## Configure Directory Services

The following steps set the AD Domain for the directory services.

1. Browse to Settings->Directory services

1. Cick on `default` and add in the AD Domain (eg. rendering.com).  To find the domain, on a machine joined to the domain, browse to Administrative Tools->Active Directory Domains and Trusts, and this will show the domain name to use.

## Configure CIFS

1. Browse to Settings->CIFS

1. Click "Enable CIFS", and add username, password, and if required by your organization, organizational unit.  


## Configure the coreFiler

1. Browse to Settings->Core Filer Details

1. Click on the core filer name to launch the settings

1. ensure you are using a DNS name under "Core filer network name/IP" field

    <p align="center">
       <img src="images/nfsfiler.png" width="600">
    </p>

## Add the CIFS share

1. Browse to Settings->CIFS Shares

1. Click "Add New Share", name the share, and point at the correct namespace path:

    <p align="center">
       <img src="images/createcifsshare.png" width="800">
    </p>
