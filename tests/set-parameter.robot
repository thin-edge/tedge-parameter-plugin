*** Settings ***
Resource    ./resources/common.resource
Library    Cumulocity
Library    DeviceLibrary    bootstrap_script=bootstrap.sh

Suite Setup    Test Setup
Suite Teardown    Collect Logs

*** Test Cases ***

Capability message is visible
    ${output}=    DeviceLibrary.Execute Command    timeout 2 tedge mqtt sub te/device/main///cmd/parameter_update    ignore_exit_code=${True}    strip=${True}
    Should Be Equal    ${output}    [te/device/main///cmd/parameter_update] {}

Run Parameter Update handler as a plugin
    Symlink Should Exist    /etc/tedge/operations/c8y/c8y_ParameterUpdate
    Cumulocity.Should Contain Supported Operations    c8y_ParameterUpdate

    # Set the initial state (required to view it in Cumulocity)
    Execute Command    cmd=tedge mqtt pub -r te/device/main///twin/AutoUpdater '{"enabled":true,"interval":"weekly"}'

    ${operation}=    Cumulocity.Create Operation
    ...    description=Set auto updater parameters
    ...    fragments={"c8y_ParameterUpdate":{},"c8y_ParameterUpdate_AutoUpdater":{},"AutoUpdater":{"enabled":false,"interval":"hourly"}}
    Cumulocity.Operation Should Be SUCCESSFUL    ${operation}
    Cumulocity.Managed Object Should Have Fragment Values    AutoUpdater.enabled\=false    AutoUpdater.interval\="hourly"


*** Keywords ***

Test Setup
    ${DEVICE_SN}=    Setup
    Set Suite Variable    $DEVICE_SN
    Device Should Exist    ${DEVICE_SN}

Collect Logs
    Get Workflow Logs
    Get Service Logs

Get Workflow Logs
    DeviceLibrary.Execute Command    head -n-0 /var/log/tedge/agent/*

Get Service Logs
    DeviceLibrary.Execute Command    journalctl --no-pager
