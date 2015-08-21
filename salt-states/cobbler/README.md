"""
Ce state permet l'installation et la configuration de cobber sur une machine CentOS
"""

### Prerequis : 
Avant d'exécuter ce script sur une machine, il faut : 
  - Avoir 10Go sur /var/www/
  - Avoir monter l'image CentOS sur /mnt/iso/
  - Disposer des droit sur la machine

###  Installation

1) renseigner les données du pillar avec les informatios ci-dessous

 next_server: [Addresse de la gw ou mettre l'IP de cobbler qui fait office de gw pour ses clients]
  server: [l'IP/fqdn du serveur où on installe cobbler]
  manage_dhcp: 1
  manage_dns: 1
  manage_tftpd: 1
  restart_dhcp: 1
  restart_dns: 1
  pxe_just_once: 1
  dns_module: manage_dnsmasq
  dhcp_module: manage_dnsmasq
  tftpd_module: manage_in_tftpd
  dnsmasq-dhcp-range: [rage d'@IP]
  default_virt_bridge: xenbr0 [valeurs par defaut pour centos]
  default_virt_type: xenpv [valeurs par defaut pour centos]
  register_new_installs: 0 
  netd_tftp_disable: no
  default_password_crypted: [generer un password avec la commande : `openssl passwd -1 -salt 'canalplus-dropship' 'mdp'`]

### Effectuer l'installation

  Si exécution local :
    salt-call --local state.show_sls cobbler
    salt-call --local state.sls cobbler

  Cette exécution installe les packages : 
   - epel-release
   - cobbler-web
   - dnsmasq
   - syslinux
   - pykickstart
  
  Les fichiers de conf et module cobbler  :
   - /etc/cobbler/
   - /var/www/cobbler/
   - /usr/lib/cobbler
   - /var/log/cobbler
   - /var/lib/cobbler/
   - /etc/httpd/conf.d/cobler 
   - /usr/lib/python2.7/site-packages/cobbler ==> pour les modules 

### Après l'installation
  
  Si l'installtion se passe bien il relances les services nécessaire au bon fonctionnement de cobbler
    - cobblerd
    - xinetd
    - httpd
    - dnsmasq

  Exécuter les 2 commandes :
    - cobbler distro list ==> vérifier que l'import s'est bien passé
    - cobbler profile list ==> le profile a été créé

  Ajouter le client avec cette commande :  
    cobbler system add --name=[Nom de la machine cible] --profile=[profile créé. trouvé le nom avec la commande `cobbler profile list`]  --interface=[Nom de l'interface bios] --mac=[mac address] --ip-address=[@IP] --netboot-enabled=1

  Rebooter la machine cliente
