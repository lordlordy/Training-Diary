//
//  Maths.swift
//  Training Diary
//
//  Created by Steven Lord on 08/02/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

class Maths{
  
    func standardDeviation(_ array: [Double]) -> Double{
        return stdDevMeanTotal(array).stdDev
    }
    
    // this is mean / stdDev
    func monotony(_ array: [Double]) -> Double{
        let r = stdDevMeanTotal(array)
        if r.stdDev == 0.0{
            return 0.0
        }
        return r.mean / r.stdDev
        
    }
    
    func strain(_ array: [Double]) -> Double{
        let r = stdDevMeanTotal(array)
        if r.stdDev == 0.0{
            return 0.0
        }
        return r.mean * r.total / r.stdDev
    }
    
    func monotonyAndStrain(_ array: [Double]) -> (monotony: Double, strain: Double){
        let r = stdDevMeanTotal(array)
        var monotony: Double = 0.0
        var strain: Double = 0.0
        if r.stdDev > 0.0{
            monotony = r.mean / r.stdDev
            strain = r.mean * r.total / r.stdDev
        }
        return (monotony, strain)
    }
    
    /* Implementation from https://www.johndcook.com/blog/cpp_phi/
    */
    func phi(stdDev: Double) -> Double{
        let a1 =  0.254829592
        let a2 = -0.284496736
        let a3 =  1.421413741
        let a4 = -1.453152027
        let a5 =  1.061405429
        let p  =  0.3275911
        
        // Save the sign of x
        var sign = 1.0
        if (stdDev < 0){ sign = -1 }
        
        let x = abs(stdDev)/sqrt(2.0)
        
        // A&S formula 7.1.26
        let t = 1.0/(1.0 + p*x)
        let y = 1.0 - (((((a5*t + a4)*t) + a3)*t + a2)*t + a1)*t*exp(-x*x)
        
         return 0.5*(1.0 + sign*y)
    }
    
    //Implementation from https://www.johndcook.com/blog/csharp_phi_inverse/
    func  rationalApproximation(_ t: Double) -> Double{
        // Abramowitz and Stegun formula 26.2.23.
        // The absolute value of the error should be less than 4.5 e-4.
        let c = [2.515517, 0.802853, 0.010328]
        let d = [1.432788, 0.189269, 0.001308]
        return t - ((c[2]*t + c[1])*t + c[0]) / (((d[2]*t + d[1])*t + d[0])*t + 1.0)
    }
    
    //Implementation from https://www.johndcook.com/blog/csharp_phi_inverse/
    //this takes a percentile (probability) and returns number of SD from mean
    func normalCDFInverse(_ p: Double) -> Double{
        if (p <= 0.0 || p >= 1.0){
            print("Invalid input argument: \(p)")
        }
        
        // See article above for explanation of this section.
        if (p < 0.5) {
            // F^-1(p) = - G^-1(p)
            return -rationalApproximation( sqrt(-2.0*log(p)) )
        }else{
            // F^-1(p) = G^-1(1-p)
            return rationalApproximation( sqrt(-2.0*log(1.0 - p)) )
        }
    }
    
    
    func test(){
        let testStdDevs = [-3.0, -2.0, -1.0, 0, 1.0, 2.0, 3.0]
        for x in testStdDevs{
            let p = phi(stdDev: x)
            let i = normalCDFInverse(p)
            print("Stddev \(x) -> \(p) -> \(i)")
        }
        
        let d = Date()
        var array: [Double] = []
        for a in 1...10000{
            array.append(Double(a))
            let r = stdDevMeanTotal(array)
            print("Standard dev of integers to \(a) is \(r.stdDev), monotony = \(r.mean / r.stdDev), strain = \(r.mean * r.total / r.stdDev)")
        }
        
        print("Time for 10,000 std dev calc = \(Date().timeIntervalSince(d))s")
        
    }
    
    private func stdDevMeanTotal(_ array: [Double]) -> (stdDev: Double, mean: Double, total: Double){
        let length = Double(array.count)
        let sum = array.reduce(0, {$0 + $1})
        let avg = sum / length
        let sumOfSquaredAvgDiff = array.map { pow($0 - avg, 2.0)}.reduce(0, {$0 + $1})
        let stdDev = sqrt(sumOfSquaredAvgDiff / length)
        return (stdDev, avg, sum)
    }
    
}

