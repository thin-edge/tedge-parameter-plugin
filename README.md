# tedge-parameter-plugin

⚠️ This is a work-in-progress so expect things to break and the Cumulocity feature is still in development

thin-edge.io plugin to add support for the Cumulocity `c8y_ParameterUpdate` operation.

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
c8y api POST /service/dtm/definitions/properties --template '{
  "identifier": "AutoUpdater",
  "jsonSchema": {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "title": "Auto Updater",
    "description": "Auto update configuration to keep your device up to date with the latest software",
    "type": "object",
    "properties": {
      "enabled": {
        "type": "boolean"
      },
      "interval": {
        "type": "string"
      }
    }
  },
  "tags": [
    "thin-edge.io"
  ],
  "contexts": ["event", "asset"],
  "additionalProp1": {}
}
'
```

#### Delete a property identifier

If you need to delete an existing property identifier use the following command:

```sh
c8y api DELETE "/service/dtm/definitions/properties/AutoUpdater?contexts=asset,event"
```

#### Update a property identifier

**Note** The following command fails. Maybe not all fields can be updated.

```sh
c8y api PUT "/service/dtm/definitions/properties/AutoUpdater?contexts=event,asset" --template '{
  "identifier": "AutoUpdater",
  "jsonSchema": {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "title": "Auto Updater",
    "description": "Auto update configuration to keep your device up to date with the latest software",
    "type": "object",
    "properties": {
      "enabled": {
        "type": "boolean"
      },
      "interval": {
        "type": "string",
        "enum": ["hourly", "daily", "weekly"]
      }
    }
  },
  "tags": [
    "thin-edge.io"
  ],
  "contexts": ["event", "asset"],
  "additionalProp1": {}
}
'
```

#### SmartREST 2.0 Templates

This feature relies on the following Cumulocity SmartREST templates:

* https://cumulocity.com/docs/smartrest/mqtt-static-templates/#532
* https://cumulocity.com/docs/smartrest/mqtt-static-templates/#408
