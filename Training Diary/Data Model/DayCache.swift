//
//  DayCache.swift
//  Training Diary
//
//  Created by Steven Lord on 18/05/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

class DayCache{
    
    static var shared: DayCache = DayCache()
    
    private var cacheingDays: [TrainingDiary:[DayValueProtocol]] = [:]
    
    
    func setCache(_ days: [DayValueProtocol], forTrainingDiary td: TrainingDiary){
        var cache: [DayValueProtocol] = []
        for d in days{
            cache.append(CacheingDay(d))
        }
        cacheingDays[td] = cache
    }
    
    func getCache(forTrainingDiary td: TrainingDiary) -> [DayValueProtocol]{
        if let result = cacheingDays[td]{
            return result
        }
        return []
    }
    
    private init(){
        
    }
    
}
