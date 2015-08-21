{% from "cobbler/map.jinja" import cobbler with context %}

{% set cfg_cobbler = pillar.get('cobbler', {}) -%}
{%- macro get_config(configname, default_value) -%}
{%- if configname in cfg_cobbler -%}
{{ cfg_cobbler[configname] }}
{%- else -%}
{{ default_value }}
{%- endif -%}
{%- endmacro -%}

install_epel_release:
  pkg.installed:
    - name: epel-release

cobbler-deps:
  pkg.installed:
    - pkgs: {{ cobbler['cobbler_pkg_dep'] }}
    - require:
      - pkg: install_epel_release

cobbler_config:
  file.managed:
    - name: /etc/cobbler/settings 
    - source: salt://cobbler/templates/settings.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - pkg: cobbler-deps

cobbler_module:
  file.managed:
    - name: /etc/cobbler/modules.conf
    - source: salt://cobbler/templates/modules.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - pkg: cobbler-deps

cobbler_dnsmasq:
  file.managed:
    - name: /etc/cobbler/dnsmasq.template
    - source: salt://cobbler/templates/dnsmasq.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - pkg: cobbler-deps

xinetd_tftp_conf:
  file.managed:
    - name: /etc/xinetd.d/tftp
    - source: salt://cobbler/templates/tftp.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja

cobbler_start:
  service.running:
    - name: cobblerd
    - enable: True
    - watch:
      - pkg: cobbler-deps
      - file: cobbler_dnsmasq 
      - file: cobbler_module
      - file: cobbler_config
    - require:
      - file: cobbler_dnsmasq 
      - file: cobbler_module
      - file: cobbler_config

apache_start:
  service.running:
    - name: httpd
    - enable: True
    - require:
      - pkg: cobbler-deps

cobbler_sync:
  cmd.run:
    - name: cobbler sync
    - require:
      - service: cobbler_start

xinetd_start:
  service.running:
    - name: xinetd
    - enable: True
    - watch:
      - pkg: cobbler-deps
    - require:
      - file: cobbler_dnsmasq

import_disto_img:
  cmd.run:
    - name: cobbler import --arch=x86_64 --path=/mnt/iso --name=CentOS-7
    - require:
      - cmd: cobbler_sync
	- unless: ls /var/www/cobbler/ks_mirror/CentOS-7-x86_64
