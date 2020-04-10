## Changelog

### Unreleased

- Pinned to Kong EE 1.5
- Exposed RBAC token
- Pinned collector at 1.2.1
- Added dev portal to enable swagger test
- Upgrade kong chart
- Removed internal build dependencies

### 0.1.3

> PR [#2](https://github.com/Kong/kong-collector-helm/pull/2)

#### Improvements

- Pinned versions
- Added testing features
- Added wait for kong
- Remove duplicate values

### 0.1.2

> PR [#1](https://github.com/Kong/kong-collector-helm/pull/1)

#### Improvements

- Labels on all resources have been updated to adhere to the Helm Chart
  guideline
  [here](https://v2.helm.sh/docs/developing_charts/#syncing-your-chart-repository):
- Normalized redis and postgres configurations
- Added initContainers
- Bump collector to 1.1.0
- Use helm dependencies
- Add migration job for flask db upgrade
