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
***REMOVED******REMOVED******REMOVED***room
***REMOVED******REMOVED***case .rooms:
***REMOVED******REMOVED******REMOVED***rooms
***REMOVED******REMOVED***case .houseProperty:
***REMOVED******REMOVED******REMOVED***houseProperty
***REMOVED******REMOVED***case .houses:
***REMOVED******REMOVED******REMOVED***houses
***REMOVED******REMOVED***case .smallBuilding:
***REMOVED******REMOVED******REMOVED***smallBuilding
***REMOVED******REMOVED***case .building:
***REMOVED******REMOVED******REMOVED***building
***REMOVED******REMOVED***case .buildings:
***REMOVED******REMOVED******REMOVED***buildings
***REMOVED******REMOVED***case .street:
***REMOVED******REMOVED******REMOVED***street
***REMOVED******REMOVED***case .streets:
***REMOVED******REMOVED******REMOVED***streets
***REMOVED******REMOVED***case .neighborhood:
***REMOVED******REMOVED******REMOVED***neighborhood
***REMOVED******REMOVED***case .town:
***REMOVED******REMOVED******REMOVED***town
***REMOVED******REMOVED***case .city:
***REMOVED******REMOVED******REMOVED***city
***REMOVED******REMOVED***case .cities:
***REMOVED******REMOVED******REMOVED***cities
***REMOVED******REMOVED***case .metropolitanArea:
***REMOVED******REMOVED******REMOVED***metropolitanArea
***REMOVED******REMOVED***case .county:
***REMOVED******REMOVED******REMOVED***county
***REMOVED******REMOVED***case .counties:
***REMOVED******REMOVED******REMOVED***counties
***REMOVED******REMOVED***case .stateProvince:
***REMOVED******REMOVED******REMOVED***stateProvince
***REMOVED******REMOVED***case .statesProvinces:
***REMOVED******REMOVED******REMOVED***statesProvinces
***REMOVED******REMOVED***case .countriesSmall:
***REMOVED******REMOVED******REMOVED***countriesSmall
***REMOVED******REMOVED***case .countriesBig:
***REMOVED******REMOVED******REMOVED***countriesBig
***REMOVED******REMOVED***case .continent:
***REMOVED******REMOVED******REMOVED***continent
***REMOVED******REMOVED***case .worldSmall:
***REMOVED******REMOVED******REMOVED***worldSmall
***REMOVED******REMOVED***case .worldBig:
***REMOVED******REMOVED******REMOVED***worldBig
***REMOVED******REMOVED***case .world:
***REMOVED******REMOVED******REMOVED***world
***REMOVED***
***REMOVED***
***REMOVED***

private extension CacheScale {
***REMOVED******REMOVED***/ A localized string for the word "Room".
***REMOVED***var room: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Room",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Room (Level of Detail)"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A localized string for the word "Rooms".
***REMOVED***var rooms: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Rooms",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Rooms (Level of Detail)"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A localized string for "House Property".
***REMOVED***var houseProperty: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "House Property",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "House Property (Level of Detail)"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A localized string for "Houses".
***REMOVED***var houses: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Houses",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Houses (Level of Detail)"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A localized string for "Small Building".
***REMOVED***var smallBuilding: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Small Building",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Small Building (Level of Detail)"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A localized string for the word "Building".
***REMOVED***var building: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Building",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Building (Level of Detail)"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A localized string for the word "Buildings".
***REMOVED***var buildings: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Buildings",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Buildings (Level of Detail)"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A localized string for the word "Street".
***REMOVED***var street: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Street",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Street (Level of Detail)"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A localized string for the word "Streets".
***REMOVED***var streets: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Streets",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Streets (Level of Detail)"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A localized string for the word "Neighborhood".
***REMOVED***var neighborhood: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Neighborhood",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Neighborhood (Level of Detail)"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A localized string for the word "Town".
***REMOVED***var town: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Town",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Town (Level of Detail)"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A localized string for the word "City".
***REMOVED***var city: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "City",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "City (Level of Detail)"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A localized string for the word "Cities".
***REMOVED***var cities: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Cities",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Cities (Level of Detail)"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A localized string for "Metropolitan Area".
***REMOVED***var metropolitanArea: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Metropolitan Area",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Metropolitan Area (Level of Detail)"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A localized string for the word "County".
***REMOVED***var county: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "County",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "County (Level of Detail)"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A localized string for the word "Counties".
***REMOVED***var counties: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Counties",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Counties (Level of Detail)"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A localized string for "State/Province".
***REMOVED***var stateProvince: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "State/Province",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "State/Province (Level of Detail)"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A localized string for "States/Provinces".
***REMOVED***var statesProvinces: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "States/Provinces",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "States/Provinces (Level of Detail)"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A localized string for "Countries (Small)".
***REMOVED***var countriesSmall: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Countries (Small)",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Countries (Small) (Level of Detail)"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A localized string for "Countries (Big)".
***REMOVED***var countriesBig: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Countries (Big)",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Countries (Big) (Level of Detail)"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A localized string for the word "Continent".
***REMOVED***var continent: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Continent",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Continent (Level of Detail)"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A localized string for "World (Small)".
***REMOVED***var worldSmall: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "World (Small)",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "World (Small) (Level of Detail)"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A localized string for "World (Big)".
***REMOVED***var worldBig: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "World (Big)",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "World (Big) (Level of Detail)"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A localized string for the word "World".
***REMOVED***var world: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "World",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "World (Level of Detail)"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
