#!/usr/bin/python
 
#
# Copyright 2018-present, Okta Inc.
#
# Script to revoke client certificates per device
#
# https://help.okta.com/en/prod/Content/Topics/Miscellaneous/Third-party%20Licenses/3rd%20Party%20Notices_Okta%20Password%20Sync%20Setup.pdf
#
# APIs used in this process are internal APIs and they are subject to changes without prior notice.
#
 
import subprocess
import json
 
SERVER = 'https://wellframe.okta.com'  # eg. 'https://<orgname>.okta.com'
ORG_API_TOKEN = 'SSWS 007kXLdkDkr8HAfAzq_M8JIgdkm3YTSB7Vo6xe4rEW'  # eg. 'SSWS 00q6jBD9vjrQUjs8Gk2s8Tn6cyAdnfcsqD9'
MAC_UDID = open('/private/tmp/uuid.txt', 'r').read() # eg. '564D4B62-CE59-616C-D237-0F586BD3C4F0'

 
def get_and_revoke_certs():
    url = '%s/api/v1/internal/devices/%s/credentials/keys' % (SERVER, MAC_UDID)
    print 'Getting certs for device: ' + MAC_UDID
    response = subprocess.check_output(['curl', '-sS', '-X', 'GET',
                                        '-H', 'Authorization: ' + ORG_API_TOKEN,
                                        '%s/api/v1/internal/devices/%s/credentials/keys'])
    print 'Response: ' + response
    data = json.loads(response.content)
    if not data:
        print 'No certs found'
        exit(0)
    for key in data:
        if 'kid' not in key:
            print "Error response."
            exit(1)
        revoke_cert(key['kid'])
    print 'Finished'
 
 
def revoke_cert(kid):
    url = '%s/api/v1/internal/devices/%s/keys/%s/lifecycle/revoke' % (SERVER, MAC_UDID, kid)
    print "Revoking certificate: " + kid
    response = subprocess.check_output(['curl', '-sS', '-X', 'POST',
                                        '-H', 'Authorization: ' + ORG_API_TOKEN,
                                        '%s/api/v1/internal/devices/%s/keys/%s/lifecycle/revoke'])
    print 'Response: ' + response
 
def check_params():
    if not SERVER:
        print "SERVER can't be empty, please populate org URL eg. https://&lt;org>.okta.com"
        exit(1)
    if not ORG_API_TOKEN:
        print "ORG_API_TOKEN can't be empty, please assign API token eg. SSWS <API-Token>"
        exit(1)
    if not MAC_UDID:
        print "MAC_UDID can't be empty, please assign macOS UDID"
        exit(1)
 
check_params()
get_and_revoke_certs()