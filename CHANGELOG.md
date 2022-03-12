## [2.1.3] Update CacheChannelListPage
* Add saveAsync function.
* Will not caculate size if count bigger than 1000
## [2.1.2] Update CacheChannelListPage
* Make sure CacheChannelListPage can view UserDefaultSync values;

## [2.1.1] Add UserDefaultSync.setCachePath(url)
* Remove image cache loader.
* Now can set spacial path to UserDefaultSync use UserDefaultSync.setCachePath(url).

## [2.0.2] Fix DefaultValueCache
* Change DefaultValueCache.value to no-null.

## [2.0.1] Add Async Func
* Add some async functions to LocalCacheObject.

## [2.0.0-nullsafety.0] Add nullsafety

## [1.3.0] Remove image cache feature
* Remove image cache feature
## [1.2.5] Update Readme

* Update Readme.
* Fix bug: return null when json.decode work with wrong string.
## [1.2.4] Update Readme

* Update Readme.

## [1.2.3] Add Data Detail Page

* Now can use `LocalCacheSync.pushDetailPage(context)` view cache detail.

## [1.2.2] Add Size Calculate

* Now can view total cache size of channel by `LocalCacheLoader(channel).cacheInfo`.
* Now can view every total cache size on `CacheChannelListPage`.

## [1.2.1] Add ImageCache

* Add image cache.

## [1.2.0] Breaking change!

* If you update to 1.2.0. You cannot read old data with same code!
* Add global cache name.
* Add `CacheChannelListPage` widget.
* Add `DefaultValueCache` class.

## [1.1.1] Release

* Fix bug.

## [1.1.0] Release

* Add `UserDefaultSync` class.

## [1.0.0] Release

* Release

## [0.0.3] - Add Data View Page.

* Now you can simple view data table with CacheViewTablePage.  


## [0.0.2] - Update(Breaking change).

* Update loader working.  

## [0.0.1] - Creat.

* Create project.
