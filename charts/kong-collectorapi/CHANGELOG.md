## Changelog

### Unreleased

### 0.4.2
##### Removed
- Brain docs

### 0.4.0
##### Improvements
- Bump kong ee to 2.2.0.0
- Bump Kong Collector to 4.0.0

### 0.3.0

#### Improvements

- Bump kong ee to 2.1.3.1
- Bump kong helm chart to 1.10.0

### 0.2.0

#### Improvements

- Pinned collector at 3.0.0

### 0.1.9

#### Improvements

- Pinned collector at 2.0.3

### 0.1.8

#### Improvements

- Pinned collector at 2.0.2
- Collector bugfixes

### 0.1.7

#### Improvements

- Pinned collector at 2.0.1

### 0.1.6

#### Improvements

- Removed bundled echo server, testendpoints
- Remove old test documentation
- Match pull secret naming to kong

### 0.1.5

#### Improvements

- Pinned collector at 2.0.0

### 0.1.4

#### Improvements

- Added existingSecret from kong admin token
- Moved all containers into collector pod
- Pinned to Kong EE 1.5
- Exposed kong admin token
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
