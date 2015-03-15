
import BrightFutures
import Foundation


class ConvertsionRateManager {
    
    func getConvertionRate(userModel:UserModel) -> Future<Double> {
        
        let promise = Promise<Double>()
        
        if let homeLocale = userModel.homeLocale? {
            if let currentLocale = userModel.currentLocale? {
                let homeCurrency = homeLocale.objectForKey(NSLocaleCurrencyCode) as String
                let currentCurrency = currentLocale.objectForKey(NSLocaleCurrencyCode) as String
                
                let urlString = "http://rate-exchange.appspot.com/currency?from=\(currentCurrency)&to=\(homeCurrency)"
                let request = NSURLRequest(URL: NSURL(string: urlString)!)
                
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
                    var castedResponse = response as NSHTTPURLResponse
                    if error != nil {
                        promise.failure(NSError(domain: "ConvertionRateManagerAPIError", code: 503, userInfo: nil))
                    } else {
                        if(castedResponse.statusCode == 200){
                            var boardsDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                            
                            var conversionRate : Double = boardsDictionary.objectForKey("rate") as Double;
                            promise.success(conversionRate)
                        } else {
                            promise.failure(NSError(domain: "CurrencyApiError", code: 503, userInfo: nil))
                        }
                    }
                }
                
            }
        }
        
        return promise.future
    }
}