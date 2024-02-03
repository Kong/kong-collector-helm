# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## Unreleased

2021-05-06
### Fixed
- Fix Consumer model training saving wrong model shape

2021-04-05
### Fixed
- Fixes bug in unknown parameters training that would happen under certain conditions
- Update alert config broken

2021-03-2
### Fixed
- remove mentions of brain in /status

2021-02-23
### Fixed
- don't trigger consumer alerts when no consumers configured.

2020-02-08
### Fixed
- /alerts prefers workspace_id when given both id and name

2020-12-7
### Add
-/metrics endpoint for prometheus stats

2020-12-3
### Add
- more metrics for collect_metrics

2020-12-3
### Fixed
- Fix /monitoredendpoints


## 4.0.0
2020-11-10
### Add
- TRAFFIC_ALERT_MIN env var to celery-worker, set the time to wait until triggering traffic alert

2020-11-09
### Fix
- Alert when traffic = 0 for 10 minutes

2020-09-18
### Remove
Remove Brain

## 3.0
2020-08-06
### Refactor
- Trigger auto-training schedule on collector startup, make schedule smart

2020-08-05
### Fixed
- Version number is correct in /status
- Auto converts old HAR format to the new one, making collector compatible with Kong 1.5+

2020-07-01
### Fixed
- Fix swagger V3 authorization not working in test swagger, adds default bearer auth

2020-06-01
### Fixed
- /swagger error when post_data was not dictionary
- auto-training error when getting workspace data from Kong

2020-06-1
### Fixed
- Swagger re-upload is fixed.

2020-05-29
###  Fixed
- /clean-data cleans traffic-map and swagger too

2020-05-28
### Fixed
- Parameter alerts with consumer_ids show up in Traffic Map.

2020-05-22
### Fixed
- /swagger title parameter transiently sets full title in returned swagger

### Added
- "generated_by" field in swagger['info']

## [2.0.2]
2020-05-15
### Fixed
- /clean-data endpoint fixed to clean everything

2020-05-12
### Fixed
- Fix bug in returning slack config when multiple configs configured for one endpoint

2020-05-08
### Fixed
- collector/status returns error message when Kong Admin not reachable

2020-04-27
### Added
- parameter alerts have state and do not resolve automatically

2020-04-30
### Added
- VERIFY_SSL env var, which takes a boolean for collector and celery-worker

2020-04-23
### Fixed
- Send admin-api-token on requests made in /collector

2020-04-22
### Added
- /clean-data endpoint to wipe data so demo envs can be made more easily.

2020-04-20
### Fixed
- KONG_PROTOCOL and KONG_ADMIN_TOKEN now optional env vars.

## [2.0.1] 2020-04-20

2020-04-16
### Fixed
- Don't send parameter alerts indefinitly for old traffic that has already made the alert.

2020-04-09

### Fixed
- Fix training when consumer_id == None
- Filenames cleaned in urls.

2020-03-31
### Refactor
- Condensed parameter alerts into parameter alert entity


2020-04-09
### Fixed
- Swagger doesn't break with collector-plugin log-bodies = False

## [2.0.0] 2020-03-27

2020-04-06
### Fixed
- Move looking for workspaces to querying Kong Admin

2020-04-08
### Fixed
- Abstract filename from urls on Har ingress


2020-04-02
### Fixed
- Handle Kong-Admin-Token not set properly error on Swagger update

2020-03-17
### Removed
- Removed KONG_MANAGER_URL env var

2020-03-05
### Fixed
- Preserve configured swagger permissions so that they don't get erased on swagger upload

2020-02-12
### Added
- consumer_id to POST /trainer/config to create auto-training rule on consumer_id

2020-02-13
### Fixed
- /alerts returns consumer alerts when consumer_id and workspace_name provided.

2020-02-11
### Added
- add unknown paramter + statuscode alerts to consumer alerts

## [1.2.0] 2020-02-11
2020-02-06
### Added
- latency alerts to consumer

### Remove
- Auto training configuration can be set per workspace only

2020-02-05
### Remove
- Remove S3 requirement from Immunity
- Remove graphing of alerts

2020-01-31
### Added
- kong version to status endpoint
- more debug info in test scripts

2020-01-29
### Added
- COPYRIGHT file added

2020-01-22
### Added
- service-map is now called traffic-map
- traffic-map does not contain alerts while persisted. alerts are added when traffic-map is requested
- traffic-map is now persisted in PostgreSQL in the form of unique uris

2020-01-20
### Added
- kong_consumer_id column to Hars table, filled during har ingress

2020-01-17
### Added
- Adapts collector to new har format generated by Kong
- Make sure all code base uses timezoned datetimes in utc

## [1.1.0] - 2019-12-17
2019-12-11
### Added
- /alerts takes "offset" and "limit" parameters to provide pagination

2019-11-27
### Added
- /alerts takes "hostname" parameter and will return only alerts that pertain to that hostname.

2019-12-02
### Fixed
- Fixed collector-app service-map severity counts and alert recording.
- Fixed service-map GUI's missing red dot.

2019-11-11
### Added
- KONG_MANAGER_URL env var to compose files for proper sending Kong Manager URL in slack notifications

## [1.0.0] - 2019-11-08

2019-11-07
### Fixed
- Improved /alerts endpoint parameter validation, changed workspace_id model type from unicode to UUID.

2019-11-01
### Added
- REDACT_BODY_DATA collector environment variable which instructs collector to NOT save body data.

2019-10-28
### Added
- Enabling SSL cert creation for production environments

2019-10-27
### Fixed
- Swagger doesn't fail when updating swagger from REDIS cache.
- Swagger doesn't fail on generating swagger when Har postData doesn't contain "encoding" key.

2019-10-23
### Refactored
- Don't pass workspaces information with service-map in leaf nodes.

2019-10-22
### Added
- /1.1.0/clean-hars endpoint which takes max_hars_storage parameter and immediately cleans Hars database to the amount passed, if no value passed it cleans to environment variable defaults.

### Fixed
- Collector now responsible for cleaning Hars, not Immunity.

2019-10-20
### Fixed
- Collector doesn't fail when storing Hars that contain downstream, non-kong calls


## [Summit-2019-RC] - 2019-10-01
2019-09-26
### Fixed
- Fix inconsistent traffic and status code alerts.
- Updating service map cache no longer erases prior alerts information from service map
- service map alerts are resolved now even regardless of SYSTEM_RESTORED_MESSAGE status of alert type.

2019-09-19
### Fixed
- Training and detection resolve all paths with trailing '/' as the same as paths without trailing '/'

2019-09-18
### Refactored
- metadata on /alerts returns total count by workspace_name when workspace_name provided as parameter to alerts provided.

### Fixed
- Ignored alerts are not sent to slack.

2019-09-17
### Refactored
- alerts in service map are cleaner, have detected_at and resolved_at timestamps added

2019-09-12
### Added
- Add "ignored" category of severity to alerts.

2019-09-11
### Fixed
- Traffic alert will alert when traffic goes to 0, assuming this is part of the traffic model

2019-08-30
### Added
- task every 10 minutes which cleans service-map

### Fixed
- can't use cursor outside transaction exception error
- can't filter on har_id comparison to None error

2019-08-27
### Fix
- Fix auto-train so that it doesn't error on Har filtering.

2019-08-22
### Added
- Configure auto-train down to "method", also passed as param to /trainer/config.

2019-08-20
### Fixed
- Fix /alerts to not have key error when returning latency alerts.
- Traffic alerts are specific to method in addition to url.


2019-08-19
### Added
- Add detected_at_unix as returned value in /alerts endpoint.

2019-08-15
### Added
- Alert information included in service map

### Fixed
- Service Map updating of caching works.

2019-08-07
### Added
- Alerts are now delivered by method + base_url + alert_type, as opposed to base_url + alert_type as before.

### Changed
- /alerts now takes method as a parameter to filter alerts.
- /monitoredendpoints displays models by method

2019-08-06
### Changed
- Removed concept of global models and global alerts.

2019-07-30
### Changed
- Bumped Celery to 4.3.0

2019-07-29
### Changed
- Images now based off slim version of Debian Buster

### Added
- metadata which includes various counts of alerts returned on /alerts.

##[0.4.1] - 2019-07-26
2019-07-24
### Fixed
- Return false on latency model when latency model doesn't exist.
- Service-map format when uploading it to Kong is now compatible with Kong Admin UI

2019-07-25
### Fixed
- Fix GET erroring on /notifications/slack/config when a default endpoint rule is made AFTER a specific rule for the same endpoint.

## [0.4.0] - 2019-07-24
2019-07-22
### Added
- severity_num value which translate severity into number for all returned severity objects on /alerts
- Can now pass a number into severity parameters on all /alerts endpoints that accept it.

2019-07-09
### Added
- /notifications/slack/config endpoint to add, delete, and get slack configurations.
- Immunity and Brain status information on /status endpoint return object.

## [0.3.0] - 2019-07-08
2019-06-25
### Added
- startedDateTime_initial and startedDateTime_latest added to service_map

2019-06-19
### Fixed
- Abstract out ids from base_url.

2019-06-18
### Added
- collector discards postData of hars with invalid json or form

2019-06-17
### Fixed
- Fix bug when non-json data is encoded in har formdata during query parameter extraction

### Added
- task for periodically upload service-maps to kong.
- training by kong_entity to /trainer endpoint.

2019-06-13
### Fixed
- Fix failing har maintenance task.

2019-06-12
### Added
- Added parameters in formdata to all parameter based models.
- Make parameter based models more specific in messages and hars recorded.

2019-06-11
### Added
- route_id and service_id information in /monitorednedpoints.

2019-06-06
- expand /autotrain endpoint so users can specify by kong entity (service_id, route_id) on/off autotraining settings.

2019-06-07
### Refactor
- /autotrain to /alerts/config endpoint where users can configure their alert settings on alert_type to kong_entity + alert_type granularity.  Does not work on workspace_id nor workspace_name as a potential kong_entity.

2019-05-28
### Added
- /autotrain endpoints, get and post where users can turn on or off their default auto-train setting, and retrieve setting information

2019-06-04
### Added
- default severity for all alert models, which are included in the /alerts endpoint and can filter by severity level (low, medium, high) as well as slack message.

## [0.2.3] - 2019-06-12
### Fixed
- Added back in the optional fields in swagger that developer portal assumes are there
- We now replace ids (UUID or int) in URLs by placeholders representing such ids.

## [0.2.2] - 2019-06-05
### Fixed
- Fixed a 500 error being thrown from the /get_swagger endpoint
- Brought back the host parameter in /get_swagger endpoint
- 0.2.0 brought in a previously undocumented breaking change where the /get_swagger endpoint's `version` parameter was changed to openapi_version
    - `version` is now used so that a user can automatically populate their APIs version number in the swagger file
    - `openapi_version` is now used to specify if the output should be Swagger v2 or v3
    - 2 other new parameters, `description` and `title` are supported to automatically populate the swagger file with that info

## [0.2.1] - 2019-05-28
### Fixed
- Fixed task that uploads swaggers to kong. Also, fixed `aggregate` task from brain.

## [0.2.0] - 2019-05-23
### Added
- Add workspace_name parameter optin for /alerts endpoint

## [0.1.1] - 2019-05-22
### Fixed
- Initial alert messages are now properly sending to slack

## [0.1.0] - 2019-05-14
2019-05-02
### Added
- `/monitoredendpoints/` returning all endpoints for which there are trained models

2019-05-03
### Added
- Apply traffic model to urls
- logging messages for celery-tasks

2019-05-08
### Fixed
- Split all url-model into separate tasks for alert generation stability.
- Remove sent-notifications table, and adjust Alerts to behave like sent-notifications
- Delete local plot files once plot transfered to S3

2019-05-13
### Fixed
- Brain generates valid Swagger v3 spec that can be rendered in Dev Portal

2019-05-14
### Fixed
- Fix detector to allow traffic model to be url specific in detection and training.

2019-05-14
### Changed
- Better slack messaging

2019-05-15
### Added
- Give alert_id with response from /alerts
- retrieve hars by alert_id
- Record Har IDS for alerts that want it, so that users can retrieve specific hars to examine in-depth the origins of an alert.