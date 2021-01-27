//
//  LocalizableConstants.swift
//  assignment
//
//  Created by Martin Miklas on 27/01/2021.
//
struct Localize {
    struct TabBar {
        static let Map = "TabBar.Map".localized();
        static let Search = "TabBar.Search".localized();
        static let Favorites = "TabBar.Favorites".localized();
    }
    
    struct Map {
        static let Standard = "Map.Standard".localized();
        static let Satellite = "Map.Satellite".localized();
    }
    
    struct Search {
        static let Title = "Search.Title".localized();
        static let Placeholder = "Search.Placeholder".localized();
    }
    
    struct Favorites {
        static let Title = "Favorites.Title".localized();
        static let Latitude = "Favorites.Latitude".localized();
        static let Longitude = "Favorites.Longitude".localized();
    }
    
    struct Detail {
        static let FeelsLike = "Detail.FeelsLike".localized();
        static let AddToFavorites = "Detail.AddToFavorites".localized();
        static let RemovesFromFavorites = "Detail.RemovesFromFavorites".localized();
    }
    
    struct Alert {
        static let Ok = "Alert.Ok".localized();
        static let UpdateSettings = "Alert.UpdateSettings".localized();
        struct Location {
            static let Title = "Alert.Location.Title".localized();
            static let Message = "Alert.Location.Message".localized();
        }
        struct Net {
            static let NoConnection = "Alert.Net.NoConnection".localized();
        }
    }
}
