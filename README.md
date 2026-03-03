# tedge-parameter-plugin

⚠️ This is a work-in-progress so expect things to break and the Cumulocity feature is still in development

thin-edge.io plugin to add support for the Cumulocity `c8y_ParameterUpdate` operation.

## Pre-requisites

The Cumulocity device parameter feature has a few dependencies which need to be enabled/configured before you can install this plugin.

* Microservices
  * dtm
  * device-parameter

* feature flags
  * `dtm.asset-api`

    ```sh
    c8y features enable --key dtm.asset-api
    ```

    Note: It can take a few minutes before the DTM microservice registers the API.

* User permissions
  * ROLE_DIGITAL_TWIN_DEFINITIONS_CREATE
  * ROLE_DIGITAL_TWIN_DEFINITIONS_ADMIN

  You can assign these to one of the groups using the following commands:

  ```sh
  c8y userroles addRoleToGroup --role ROLE_DIGITAL_TWIN_DEFINITIONS_CREATE --group admins
  c8y userroles addRoleToGroup --role ROLE_DIGITAL_TWIN_DEFINITIONS_ADMIN --group admins
  ```


## Plugin summary

### What will be deployed to the device?

* thin-edge.io workflow called `parameter_update`
* Cumulocity command template for mapping the c8y_ParameterUpdate operation to the `parameter_update` thin-edge.io command
* parameter_set.sh binary used to provide the parameter_update plugin system
* An example [AutoUpdater](./src/plugins/AutoUpdater) parameter set script. This is only an example and can be used as a reference

**Technical summary**

The following details the technical aspects of the plugin to get an idea what systems it supports.

|||
|--|--|
|**Languages**|`shell` (posix compatible)|
|**CPU Architectures**|`all/noarch`. Not CPU specific|
|**Supported init systems**|`N/A`|
|**Required Dependencies**|-|
|**Optional Dependencies (feature specific)**|-|

### How to do I get it?

The following linux package formats are provided on the releases page and also in the [tedge-community](https://cloudsmith.io/~thinedge/repos/community/packages/) repository:

|Operating System|Repository link|
|--|--|
|Debian/Raspian (deb)|[![Latest version of 'tedge-parameter-plugin' @ Cloudsmith](https://api-prd.cloudsmith.io/v1/badges/version/thinedge/community/deb/tedge-parameter-plugin/latest/a=all;d=any-distro%252Fany-version;t=binary/?render=true&show_latest=true)](https://cloudsmith.io/~thinedge/repos/community/packages/detail/deb/tedge-parameter-plugin/latest/a=all;d=any-distro%252Fany-version;t=binary/)|
|Alpine Linux (apk)|[![Latest version of 'tedge-parameter-plugin' @ Cloudsmith](https://api-prd.cloudsmith.io/v1/badges/version/thinedge/community/alpine/tedge-parameter-plugin/latest/a=noarch;d=alpine%252Fany-version/?render=true&show_latest=true)](https://cloudsmith.io/~thinedge/repos/community/packages/detail/alpine/tedge-parameter-plugin/latest/a=noarch;d=alpine%252Fany-version/)|
|RHEL/CentOS/Fedora (rpm)|[![Latest version of 'tedge-parameter-plugin' @ Cloudsmith](https://api-prd.cloudsmith.io/v1/badges/version/thinedge/community/rpm/tedge-parameter-plugin/latest/a=noarch;d=any-distro%252Fany-version;t=binary/?render=true&show_latest=true)](https://cloudsmith.io/~thinedge/repos/community/packages/detail/rpm/tedge-parameter-plugin/latest/a=noarch;d=any-distro%252Fany-version;t=binary/)|

## Adding your own plugin

An additional parameter set plugins should be added in the following script:

1. Add your script to the following folder:

    ```sh
    /usr/share/tedge/parameter-plugins/
    ```

    For example, if you want a parameter set called "foo", then the script would be created at the following location:

    ```sh
    /usr/share/tedge/parameter-plugins/foo
    ```

    The script should also be executable, e.g.

    ```sh
    chmod +x /usr/share/tedge/parameter-plugins/foo
    ```

1. Set the initial state of the parameter set so that the UI will be able to display the current state

    ```sh
    tedge mqtt pub -r -q 1 te/device/main///twin/foo '{}'
    ```

## Advanced

### Cumulocity Digital Twin Data Mapper API

#### Create a property identifier

Create a new property identifier using the following command. This is required before the UI will be able to display the different parameter sets.

```sh
c8y api --raw POST /service/dtm/definitions/properties --template '{
  "identifier": "AutoUpdater",
  "jsonSchema": {
    "title": "Auto Updater",
    "description": "Auto update configuration to keep your device up to date with the latest software",
    "properties": {
      "enabled": {
        "type": "boolean",
        "default": null,
        "title": "enabled",
        "order": 1
      },
      "interval": {
        "type": "string",
        "title": "interval",
        "enum": ["hourly", "daily", "weekly"],
        "order": 2
      }
    },
    "type": "object"
  },
  "contexts": [
    "asset",
    "event",
    "operation"
  ]
}
'
```

#### Delete a property identifier

If you need to delete an existing property identifier use the following command:

```sh
c8y api DELETE "/service/dtm/definitions/properties/AutoUpdater?contexts=asset,event,operation"
```

#### Update a property identifier

**Note** The following command fails. Maybe not all fields can be updated.

```sh
c8y api --raw PUT "/service/dtm/definitions/properties/AutoUpdater?contexts=event,asset,operation" --template '{
  "identifier": "AutoUpdater",
  "jsonSchema": {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "title": "Auto Updater",
    "description": "Auto update configuration to keep your device up to date with the latest software",
    "type": "object",
    "properties": {
      "enabled": {
        "type": "boolean",
        "default": null,
        "title": "enabled",
        "order": 1
      },
      "interval": {
        "type": "string",
        "title": "interval",
        "enum": ["hourly", "daily", "weekly"],
        "order": 2
      }
    }
  },
  "tags": [
    "thin-edge.io"
  ],
  "contexts": ["event", "asset", "operation"]
}
'
```

#### SmartREST 2.0 Templates

This feature relies on the following Cumulocity SmartREST templates:

* https://cumulocity.com/docs/smartrest/mqtt-static-templates/#532
* https://cumulocity.com/docs/smartrest/mqtt-static-templates/#408
