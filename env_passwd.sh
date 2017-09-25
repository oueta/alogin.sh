function env_passwd()
{
    if [ $# -eq 1 ]; then
        ENV_TPL=$1
    else
        read -p 'Template: ' ENV_TPL
    fi
    ENV_TPL=`echo $ENV_TPL | awk '{print toupper($0)}'`
    read -s -p 'Password: ' ENV_PASSWD
    echo
    read -s -p 'Password: ' ENV_PASSWD_RETYPE
    echo
    if [ "$ENV_PASSWD" == "$ENV_PASSWD_RETYPE" ]; then
        export $ENV_TPL=$ENV_PASSWD
    else
        echo "Password does not match the confirm password."
    fi
}
