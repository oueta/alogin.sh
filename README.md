## alogin.sh

## Requirements
/bin/bash
/usr/bin/expect

## Usage
./alogin.sh host template

## File permissions
1. chmod 600 alogin.conf env_passwd.sh README.md
2. chmod 700 alogin.sh

## Template file example
alogin.conf

1. &#35; template_name:service:port:user:password
2. &#35; service = ssh or telnet
3. &#35; password = password or $ for environment variable $TEMPLATE_NAME
4. mail:ssh:22:my_user:my_password
5. switch:telnet:23:my_user:my_password
6. mail.myhost.com:ssh:22:my_user:my_password
7. envar:ssh:22:my_user:$

## Examples by templates
mail

* ./alogin.sh mail.example-one.com
* ./alogin.sh mail.example-two.com

switch

* ./alogin.sh campus-switch.example.com
* ./alogin.sh library-switch.example.com

mail.myhost.com template more specific than "mail"
* ./alogin.sh mail.myhost.com

envar, store the password in $TEMPLATE_NAME environment variable

1. source env_passwd.sh
2. env_passwd envar
3. ./alogin.sh server.example.com envar

Warning: keep your passwords in a safe place, use the right permissions and keep in mind that root can read anything!
