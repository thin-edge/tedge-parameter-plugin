*** Settings ***
Library    Cumulocity
Library    DeviceLibrary

*** Variables ***

# Cumulocity settings
&{C8Y_CONFIG}        host=%{C8Y_BASEURL= }    username=%{C8Y_USER= }    password=%{C8Y_PASSWORD= }    tenant=%{C8Y_TENANT= }

# Docker adapter settings (to control which image is used in the system tests).
# The user just needs to set the IMAGE env variable
&{DOCKER_CONFIG}    image=%{IMAGE=debian-12}

*** Keywords ***

Setup Device
    ${DEVICE_ID}=    DeviceLibrary.Setup    skip_bootstrap=${True}
    Set Test Variable    $DEVICE_ID
    Bootstrap Device    ${DEVICE_ID}

Bootstrap Device
    [Arguments]    ${device_id}
    ${domain}=    Cumulocity.Get Domain
    DeviceLibrary.Execute Command    cmd=tedge config set c8y.url ${domain}
    ${credentials}=    Cumulocity.Bulk Register Device With Cumulocity CA    external_id=${device_id}
    DeviceLibrary.Execute Command    cmd=tedge cert download c8y --device-id ${device_id} --retry-every 5s --one-time-password '${credentials.one_time_password}'
    DeviceLibrary.Execute Command    cmd=tedge reconnect c8y
    Cumulocity.External Identity Should Exist    external_id=${device_id}
    ${operation}=    Cumulocity.Get Configuration    typename=tedge-configuration-plugin    timeout=60
    Cumulocity.Operation Should Be SUCCESSFUL    ${operation}
    Sleep    2s

Collect Logs
    Run Keyword And Continue On Failure    Get Workflow Logs
    Run Keyword And Continue On Failure    Get Service Logs

Get Workflow Logs
    DeviceLibrary.Execute Command    head -n-0 /var/log/tedge/agent/*

Get Service Logs
    # systemd image: collect from the journal rather than on-disk log files
    DeviceLibrary.Execute Command    cmd=journalctl -n 10000 -u "tedge-*" -u "c8y-*" --no-pager

Teardown Device
    Collect Logs
    Cumulocity.Delete Managed Object And Device User    external_id=${DEVICE_ID}
