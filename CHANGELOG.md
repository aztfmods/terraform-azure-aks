# Changelog

## [1.8.0](https://github.com/aztfmods/module-azurerm-aks/compare/v1.7.0...v1.8.0) (2023-03-22)


### Features

* add kubelet_config support for default and non default node pools ([#57](https://github.com/aztfmods/module-azurerm-aks/issues/57)) ([b8f3f1a](https://github.com/aztfmods/module-azurerm-aks/commit/b8f3f1aef1f1b5f50382b5a9f2244d349dd0ee1d))

## [1.7.0](https://github.com/aztfmods/module-azurerm-aks/compare/v1.6.0...v1.7.0) (2023-03-21)


### Features

* add linux_profile support ([#55](https://github.com/aztfmods/module-azurerm-aks/issues/55)) ([b7237d9](https://github.com/aztfmods/module-azurerm-aks/commit/b7237d90242196117c501a84afaea01963932808))

## [1.6.0](https://github.com/aztfmods/module-azurerm-aks/compare/v1.5.0...v1.6.0) (2023-03-21)


### Features

* add linux os config support for default and non default nodes pools ([#52](https://github.com/aztfmods/module-azurerm-aks/issues/52)) ([9c5e34d](https://github.com/aztfmods/module-azurerm-aks/commit/9c5e34d0c9d84e4c2b541bdcf95c5b98d23c45ac))
* add oms_agent support ([#54](https://github.com/aztfmods/module-azurerm-aks/issues/54)) ([2f77a92](https://github.com/aztfmods/module-azurerm-aks/commit/2f77a92a8234b2c1d2329e96ae81c39ca8639519))

## [1.5.0](https://github.com/aztfmods/module-azurerm-aks/compare/v1.4.0...v1.5.0) (2023-03-21)


### Features

* add node_pool and multiple aks cluster examples ([#42](https://github.com/aztfmods/module-azurerm-aks/issues/42)) ([f3ed63f](https://github.com/aztfmods/module-azurerm-aks/commit/f3ed63f135640556d7b9c534b3fcd489b75a77b4))
* simplify structure ([#51](https://github.com/aztfmods/module-azurerm-aks/issues/51)) ([cefc9e4](https://github.com/aztfmods/module-azurerm-aks/commit/cefc9e44386f9ec6521de725f6433c0c64bcd162))
* small refactor naming convention ([#40](https://github.com/aztfmods/module-azurerm-aks/issues/40)) ([647a9f8](https://github.com/aztfmods/module-azurerm-aks/commit/647a9f8910c91aa458303f7bd6fe00d2f937f281))

## [1.4.0](https://github.com/aztfmods/module-azurerm-aks/compare/v1.3.0...v1.4.0) (2022-10-18)


### Features

* add autoscaler profile ([#19](https://github.com/aztfmods/module-azurerm-aks/issues/19)) ([f7e8026](https://github.com/aztfmods/module-azurerm-aks/commit/f7e802636bc19f932d1fb13b134e818a10469b94))
* add node pool upgrade settings ([#17](https://github.com/aztfmods/module-azurerm-aks/issues/17)) ([a6e7936](https://github.com/aztfmods/module-azurerm-aks/commit/a6e7936f8f616249fa366193b83a332024732cfb))
* add optional network profile ([#20](https://github.com/aztfmods/module-azurerm-aks/issues/20)) ([a317479](https://github.com/aztfmods/module-azurerm-aks/commit/a3174792238f1f8075b9d071500d439ec5520bdb))

## [1.3.0](https://github.com/aztfmods/module-azurerm-aks/compare/v1.2.0...v1.3.0) (2022-10-17)


### Features

* add optional cluster arguments kubernetes_version, sku_tier, node_resource_group, azure_policy_enabled, ([#16](https://github.com/aztfmods/module-azurerm-aks/issues/16)) ([b14311b](https://github.com/aztfmods/module-azurerm-aks/commit/b14311b001791113a32a3b0f1b034a92048d6e3d))
* small update documentation ([#14](https://github.com/aztfmods/module-azurerm-aks/issues/14)) ([101256f](https://github.com/aztfmods/module-azurerm-aks/commit/101256f0be22f953314216474e251e63ebaa07f9))

## [1.2.0](https://github.com/aztfmods/module-azurerm-aks/compare/v1.1.0...v1.2.0) (2022-10-12)


### Features

* add consistent naming ([#10](https://github.com/aztfmods/module-azurerm-aks/issues/10)) ([39f93bc](https://github.com/aztfmods/module-azurerm-aks/commit/39f93bcc31efa2c01bd9d759fcaa8e1e2f24f6a9))
* add diagnostics integration ([#11](https://github.com/aztfmods/module-azurerm-aks/issues/11)) ([a709178](https://github.com/aztfmods/module-azurerm-aks/commit/a7091784b492194381778688761e28d9e878e82b))
* add reusable workflows ([#8](https://github.com/aztfmods/module-azurerm-aks/issues/8)) ([ecd466f](https://github.com/aztfmods/module-azurerm-aks/commit/ecd466f40f98939c9d977760df0720ab8e89730c))
* update documentation ([#12](https://github.com/aztfmods/module-azurerm-aks/issues/12)) ([f582cd8](https://github.com/aztfmods/module-azurerm-aks/commit/f582cd8981e8251cb092cbef12bd5a53c73da277))

## [1.1.0](https://github.com/dkooll/terraform-azurerm-aks/compare/v1.0.0...v1.1.0) (2022-09-05)


### Features

* add availability zone support ([#6](https://github.com/dkooll/terraform-azurerm-aks/issues/6)) ([5c904aa](https://github.com/dkooll/terraform-azurerm-aks/commit/5c904aa6f43e747c6153a10b436164ab906a0367))

## 1.0.0 (2022-09-05)


### Features

* add initial module ([#1](https://github.com/dkooll/terraform-azurerm-aks/issues/1)) ([1cec780](https://github.com/dkooll/terraform-azurerm-aks/commit/1cec7809f0e74bbc320349fb23326477723e4ea7))
* add node pools ([#3](https://github.com/dkooll/terraform-azurerm-aks/issues/3)) ([58cf441](https://github.com/dkooll/terraform-azurerm-aks/commit/58cf441738c47ee8aaaf16a5a5e1bc8ffe49fd3a))
* add terratest validation ([#4](https://github.com/dkooll/terraform-azurerm-aks/issues/4)) ([23407c3](https://github.com/dkooll/terraform-azurerm-aks/commit/23407c3a894957833827d0140a47595a7991442a))
