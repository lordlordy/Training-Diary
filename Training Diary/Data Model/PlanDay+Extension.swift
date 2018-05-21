//
//  PlanDay+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 23/04/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

extension PlanDay{
    
    
    @objc dynamic var swimTSB: Double { return swimCTL - swimATL    }
    @objc dynamic var bikeTSB: Double { return bikeCTL - bikeATL    }
    @objc dynamic var runTSB: Double { return runCTL - runATL    }

    @objc dynamic var allTSS: Double { return swimTSS + bikeTSS + runTSS}
    @objc dynamic var allATL: Double { return swimATL + bikeATL + runATL}
    @objc dynamic var allCTL: Double { return swimCTL + bikeCTL + runCTL}
    @objc dynamic var allTSB: Double { return swimTSB + bikeTSB + runTSB}

    @objc dynamic var actualSwimTSB: Double { return actualSwimCTL - actualSwimATL    }
    @objc dynamic var actualBikeTSB: Double { return actualBikeCTL - actualBikeATL    }
    @objc dynamic var actualRunTSB: Double { return actualRunCTL - actualRunATL    }

    @objc dynamic var actualThenPlanSwimTSB: Double { return actualThenPlanSwimCTL - actualThenPlanSwimATL    }
    @objc dynamic var actualThenPlanBikeTSB: Double { return actualThenPlanBikeCTL - actualThenPlanBikeATL    }
    @objc dynamic var actualThenPlanRunTSB: Double { return actualThenPlanRunCTL - actualThenPlanRunATL    }
    
    @objc dynamic var actualAllTSS: Double { return actualSwimTSS + actualBikeTSS + actualRunTSS}
    @objc dynamic var actualAllATL: Double { return actualSwimATL + actualBikeATL + actualRunATL}
    @objc dynamic var actualAllCTL: Double { return actualSwimCTL + actualBikeCTL + actualRunCTL}
    @objc dynamic var actualAllTSB: Double { return actualAllCTL - actualAllATL}

    @objc dynamic var actualThenPlanAllATL: Double { return actualThenPlanSwimATL + actualThenPlanBikeATL + actualThenPlanRunATL}
    @objc dynamic var actualThenPlanAllCTL: Double { return actualThenPlanSwimCTL + actualThenPlanBikeCTL + actualThenPlanRunCTL}
    @objc dynamic var actualThenPlanAllTSB: Double { return actualThenPlanAllCTL - actualThenPlanAllATL}
    
    //this is for JSON serialisation
    @objc dynamic var iso8061DateString: String{
        return date!.iso8601Format()
    }
    
    @objc dynamic var trainingDiary: Any{
        get{
            print("Accessing PlanDay.trainingDiary")
            return Date()
        }
        set{
            print("Setting PlanDay.trainingDiary")

        }
    }
    
}
