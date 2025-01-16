// Copyright 2025 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import ArcGIS

enum CacheScale: CaseIterable {
    case room, rooms, houseProperty, houses, smallBuilding, building, buildings, street, streets, neighborhood, town, city, cities,
         metropolitanArea, county, counties, stateProvince, statesProvinces, countriesSmall, countriesBig, continent, worldSmall, worldBig, world
    
    var levelOfDetail: LevelOfDetail {
        return switch self {
        case .room:
            LevelOfDetail(level: 23, resolution: 0.01866138385297604, scale: 70.5310735)
        case .rooms:
            LevelOfDetail(level: 22, resolution: 0.03732276770595208, scale: 141.062147)
        case .houseProperty:
            LevelOfDetail(level: 21, resolution: 0.07464553541190416, scale: 282.124294)
        case .houses:
            LevelOfDetail(level: 20, resolution: 0.14929107082380833, scale: 564.248588)
        case .smallBuilding:
            LevelOfDetail(level: 19, resolution: 0.2985821417799086, scale: 1128.497175)
        case .building:
            LevelOfDetail(level: 18, resolution: 0.5971642835598172, scale: 2256.994353)
        case .buildings:
            LevelOfDetail(level: 17, resolution: 1.1943285668550503, scale: 4513.988705)
        case .street:
            LevelOfDetail(level: 16, resolution: 2.388657133974685, scale: 9027.977411)
        case .streets:
            LevelOfDetail(level: 15, resolution: 4.77731426794937, scale: 18055.954822)
        case .neighborhood:
            LevelOfDetail(level: 14, resolution: 9.554628535634155, scale: 36111.909643)
        case .town:
            LevelOfDetail(level: 13, resolution: 19.10925707126831, scale: 72223.819286)
        case .city:
            LevelOfDetail(level: 12, resolution: 38.21851414253662, scale: 144447.638572)
        case .cities:
            LevelOfDetail(level: 11, resolution: 76.43702828507324, scale: 288895.277144)
        case .metropolitanArea:
            LevelOfDetail(level: 10, resolution: 152.87405657041106, scale: 577790.554289)
        case .county:
            LevelOfDetail(level: 9, resolution: 305.74811314055756, scale: 1155581.108577)
        case .counties:
            LevelOfDetail(level: 8, resolution: 611.4962262813797, scale: 2311162.217155)
        case .stateProvince:
            LevelOfDetail(level: 7, resolution: 1222.992452562495, scale: 4622324.434309)
        case .statesProvinces:
            LevelOfDetail(level: 6, resolution: 2445.98490512499, scale: 9244648.868618)
        case .countriesSmall:
            LevelOfDetail(level: 5, resolution: 4891.96981024998, scale: 18489297.737236)
        case .countriesBig:
            LevelOfDetail(level: 4, resolution: 9783.93962049996, scale: 36978595.474472)
        case .continent:
            LevelOfDetail(level: 3, resolution: 19567.87924099992, scale: 73957190.948944)
        case .worldSmall:
            LevelOfDetail(level: 2, resolution: 39135.75848200009, scale: 147914381.897889)
        case .worldBig:
            LevelOfDetail(level: 1, resolution: 78271.51696399994, scale: 295828763.795777)
        case .world:
            LevelOfDetail(level: 0, resolution: 156543.03392800014, scale: 591657527.591555)
        }
    }
    
    var scale: Double {
        self.levelOfDetail.scale
    }
    
    var scaleDescription: String {
        "1:\(Int(scale))"
    }
    
    var description: String {
        switch self {
        case .room:
            "Room"
        case .rooms:
            "Rooms"
        case .houseProperty:
            "House Property"
        case .houses:
            "Houses"
        case .smallBuilding:
            "Small Building"
        case .building:
            "Building"
        case .buildings:
            "Buildings"
        case .street:
            "Street"
        case .streets:
            "Streets"
        case .neighborhood:
            "Neighborhood"
        case .town:
            "Town"
        case .city:
            "City"
        case .cities:
            "Cities"
        case .metropolitanArea:
            "Metropolitan Area"
        case .county:
            "County"
        case .counties:
            "Counties"
        case .stateProvince:
            "State/Province"
        case .statesProvinces:
            "States/Provinces"
        case .countriesSmall:
            "Countries (Small)"
        case .countriesBig:
            "Countries (Big)"
        case .continent:
            "Continent"
        case .worldSmall:
            "World (Small)"
        case .worldBig:
            "World (Big)"
        case .world:
            "World"
        }
    }
}
