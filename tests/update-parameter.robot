*** Settings ***
Resource    ./resources/common.resource

Test Setup       Setup Device
Test Teardown    Teardown Device

*** Test Cases ***

Capability message is visible
    ${output}=    DeviceLibrary.Execute Command    timeout 2 tedge mqtt sub te/device/main///cmd/parameter_update    ignore_exit_code=${True}    strip=${True}
    Should Be Equal    ${output}    [te/device/main///cmd/parameter_update] {}

Run Parameter Update handler as a plugin
    Symlink Should Exist    /etc/tedge/operations/c8y/c8y_ParameterUpdate
    Cumulocity.Should Contain Supported Operations    c8y_ParameterUpdate

    # Set the initial state (required to view it in Cumulocity)
    # Check the initial state (which is sent by the tedge-inventory-plugin)
    Cumulocity.Managed Object Should Have Fragment Values    AutoUpdater.enabled\=false    AutoUpdater.interval\="weekly"

    ${operation}=    Cumulocity.Create Operation
    ...    description=Set auto updater parameters
    ...    fragments={"c8y_ParameterUpdate":{},"c8y_ParameterUpdate_AutoUpdater":{},"AutoUpdater":{"enabled":true,"interval":"hourly"}}
    Cumulocity.Operation Should Be SUCCESSFUL    ${operation}
    Cumulocity.Managed Object Should Have Fragment Values    AutoUpdater.enabled\=true    AutoUpdater.interval\="hourly"
