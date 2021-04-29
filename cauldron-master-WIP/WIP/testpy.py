#!/usr/bin/python

def subprocess.run('''
    # This syntax is Bash only
    ioreg -d2 -c IOPlatformExpertDevice | awk -F\" '/IOPlatformUUID/{print $(NF-1)}' >> /private/tmp/uuid.txt''',
    shell=True, check=True,
    executable='/bin/bash')

SERVER = 'https://wellframe.okta.com'  # eg. 'https://<orgname>.okta.com'
ORG_API_TOKEN = 'SSWS <API_TOKEN>'  # eg. 'SSWS 00q6jBD9vjrQUjs8Gk2s8Tn6cyAdnfcsqD9'
MAC_UDID = open('/private/tmp/uuid.txt', 'r').read()

print (MAC_UDID)
