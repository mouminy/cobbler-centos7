cobbler:
  next_server: "{{ grains['ipv4'][1] }}"
  server: "{{ grains['ipv4'][1] }}"
  manage_dhcp: 1
  manage_dns: 1
  manage_tftpd: 1
  restart_dhcp: 1
  restart_dns: 1
  pxe_just_once: 1
  dns_module: manage_dnsmasq
  dhcp_module: manage_dnsmasq
  tftpd_module: manage_in_tftpd
  dnsmasq-dhcp-range: 192.168.1.85,192.168.1.200
  default_virt_bridge: xenbr0
  default_virt_type: xenpv
  register_new_installs: 0
  netd_tftp_disable: no
  default_password_crypted: {}