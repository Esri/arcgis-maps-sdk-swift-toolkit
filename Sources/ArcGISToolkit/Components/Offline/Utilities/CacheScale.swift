***REMOVED*** Copyright 2025 Esri
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

import Foundation
***REMOVED***

enum CacheScale: CaseIterable {
***REMOVED***case room, rooms, houseProperty, houses, smallBuilding, building, buildings, street, streets, neighborhood, town, city, cities,
***REMOVED******REMOVED*** metropolitanArea, county, counties, stateProvince, statesProvinces, countriesSmall, countriesBig, continent, worldSmall, worldBig, world
***REMOVED***
***REMOVED***var levelOfDetail: LevelOfDetail {
***REMOVED******REMOVED***return switch self {
***REMOVED******REMOVED***case .room:
***REMOVED******REMOVED******REMOVED***LevelOfDetail(level: 23, resolution: 0.01866138385297604, scale: 70.5310735)
***REMOVED******REMOVED***case .rooms:
***REMOVED******REMOVED******REMOVED***LevelOfDetail(level: 22, resolution: 0.03732276770595208, scale: 141.062147)
***REMOVED******REMOVED***case .houseProperty:
***REMOVED******REMOVED******REMOVED***LevelOfDetail(level: 21, resolution: 0.07464553541190416, scale: 282.124294)
***REMOVED******REMOVED***case .houses:
***REMOVED******REMOVED******REMOVED***LevelOfDetail(level: 20, resolution: 0.14929107082380833, scale: 564.248588)
***REMOVED******REMOVED***case .smallBuilding:
***REMOVED******REMOVED******REMOVED***LevelOfDetail(level: 19, resolution: 0.2985821417799086, scale: 1128.497175)
***REMOVED******REMOVED***case .building:
***REMOVED******REMOVED******REMOVED***LevelOfDetail(level: 18, resolution: 0.5971642835598172, scale: 2256.994353)
***REMOVED******REMOVED***case .buildings:
***REMOVED******REMOVED******REMOVED***LevelOfDetail(level: 17, resolution: 1.1943285668550503, scale: 4513.988705)
***REMOVED******REMOVED***case .street:
***REMOVED******REMOVED******REMOVED***LevelOfDetail(level: 16, resolution: 2.388657133974685, scale: 9027.977411)
***REMOVED******REMOVED***case .streets:
***REMOVED******REMOVED******REMOVED***LevelOfDetail(level: 15, resolution: 4.77731426794937, scale: 18055.954822)
***REMOVED******REMOVED***case .neighborhood:
***REMOVED******REMOVED******REMOVED***LevelOfDetail(level: 14, resolution: 9.554628535634155, scale: 36111.909643)
***REMOVED******REMOVED***case .town:
***REMOVED******REMOVED******REMOVED***LevelOfDetail(level: 13, resolution: 19.10925707126831, scale: 72223.819286)
***REMOVED******REMOVED***case .city:
***REMOVED******REMOVED******REMOVED***LevelOfDetail(level: 12, resolution: 38.21851414253662, scale: 144447.638572)
***REMOVED******REMOVED***case .cities:
***REMOVED******REMOVED******REMOVED***LevelOfDetail(level: 11, resolution: 76.43702828507324, scale: 288895.277144)
***REMOVED******REMOVED***case .metropolitanArea:
***REMOVED******REMOVED******REMOVED***LevelOfDetail(level: 10, resolution: 152.87405657041106, scale: 577790.554289)
***REMOVED******REMOVED***case .county:
***REMOVED******REMOVED******REMOVED***LevelOfDetail(level: 9, resolution: 305.74811314055756, scale: 1155581.108577)
***REMOVED******REMOVED***case .counties:
***REMOVED******REMOVED******REMOVED***LevelOfDetail(level: 8, resolution: 611.4962262813797, scale: 2311162.217155)
***REMOVED******REMOVED***case .stateProvince:
***REMOVED******REMOVED******REMOVED***LevelOfDetail(level: 7, resolution: 1222.992452562495, scale: 4622324.434309)
***REMOVED******REMOVED***case .statesProvinces:
***REMOVED******REMOVED******REMOVED***LevelOfDetail(level: 6, resolution: 2445.98490512499, scale: 9244648.868618)
***REMOVED******REMOVED***case .countriesSmall:
***REMOVED******REMOVED******REMOVED***LevelOfDetail(level: 5, resolution: 4891.96981024998, scale: 18489297.737236)
***REMOVED******REMOVED***case .countriesBig:
***REMOVED******REMOVED******REMOVED***LevelOfDetail(level: 4, resolution: 9783.93962049996, scale: 36978595.474472)
***REMOVED******REMOVED***case .continent:
***REMOVED******REMOVED******REMOVED***LevelOfDetail(level: 3, resolution: 19567.87924099992, scale: 73957190.948944)
***REMOVED******REMOVED***case .worldSmall:
***REMOVED******REMOVED******REMOVED***LevelOfDetail(level: 2, resolution: 39135.75848200009, scale: 147914381.897889)
***REMOVED******REMOVED***case .worldBig:
***REMOVED******REMOVED******REMOVED***LevelOfDetail(level: 1, resolution: 78271.51696399994, scale: 295828763.795777)
***REMOVED******REMOVED***case .world:
***REMOVED******REMOVED******REMOVED***LevelOfDetail(level: 0, resolution: 156543.03392800014, scale: 591657527.591555)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var scale: Double {
***REMOVED******REMOVED***self.levelOfDetail.scale
***REMOVED***
***REMOVED***
***REMOVED***var scaleDescription: String {
***REMOVED******REMOVED***"1:\(Int(scale))"
***REMOVED***
***REMOVED***
***REMOVED***var description: String {
***REMOVED******REMOVED***switch self {
***REMOVED******REMOVED***case .room:
***REMOVED******REMOVED******REMOVED***"Room"
***REMOVED******REMOVED***case .rooms:
***REMOVED******REMOVED******REMOVED***"Rooms"
***REMOVED******REMOVED***case .houseProperty:
***REMOVED******REMOVED******REMOVED***"House Property"
***REMOVED******REMOVED***case .houses:
***REMOVED******REMOVED******REMOVED***"Houses"
***REMOVED******REMOVED***case .smallBuilding:
***REMOVED******REMOVED******REMOVED***"Small Building"
***REMOVED******REMOVED***case .building:
***REMOVED******REMOVED******REMOVED***"Building"
***REMOVED******REMOVED***case .buildings:
***REMOVED******REMOVED******REMOVED***"Buildings"
***REMOVED******REMOVED***case .street:
***REMOVED******REMOVED******REMOVED***"Street"
***REMOVED******REMOVED***case .streets:
***REMOVED******REMOVED******REMOVED***"Streets"
***REMOVED******REMOVED***case .neighborhood:
***REMOVED******REMOVED******REMOVED***"Neighborhood"
***REMOVED******REMOVED***case .town:
***REMOVED******REMOVED******REMOVED***"Town"
***REMOVED******REMOVED***case .city:
***REMOVED******REMOVED******REMOVED***"City"
***REMOVED******REMOVED***case .cities:
***REMOVED******REMOVED******REMOVED***"Cities"
***REMOVED******REMOVED***case .metropolitanArea:
***REMOVED******REMOVED******REMOVED***"Metropolitan Area"
***REMOVED******REMOVED***case .county:
***REMOVED******REMOVED******REMOVED***"County"
***REMOVED******REMOVED***case .counties:
***REMOVED******REMOVED******REMOVED***"Counties"
***REMOVED******REMOVED***case .stateProvince:
***REMOVED******REMOVED******REMOVED***"State/Province"
***REMOVED******REMOVED***case .statesProvinces:
***REMOVED******REMOVED******REMOVED***"States/Provinces"
***REMOVED******REMOVED***case .countriesSmall:
***REMOVED******REMOVED******REMOVED***"Countries (Small)"
***REMOVED******REMOVED***case .countriesBig:
***REMOVED******REMOVED******REMOVED***"Countries (Big)"
***REMOVED******REMOVED***case .continent:
***REMOVED******REMOVED******REMOVED***"Continent"
***REMOVED******REMOVED***case .worldSmall:
***REMOVED******REMOVED******REMOVED***"World (Small)"
***REMOVED******REMOVED***case .worldBig:
***REMOVED******REMOVED******REMOVED***"World (Big)"
***REMOVED******REMOVED***case .world:
***REMOVED******REMOVED******REMOVED***"World"
***REMOVED***
***REMOVED***
***REMOVED***
