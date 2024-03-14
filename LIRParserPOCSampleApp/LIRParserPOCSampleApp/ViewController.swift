//
//  ViewController.swift
//  LIR_ParserPOC
//
//  Created by Vasile Cotovanu on 12.03.2024.
//

import UIKit
import XMLCoder

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildXMLRequest()
        // parseXML_StripNS()
        // parseXML_NS()
    }


}

extension ViewController {
    func buildXMLRequest() {
        // BE/Köniz area
        let bbox = Geo.Bbox(minLongitude: 7.372097, minLatitude: 46.904860, maxLongitude: 7.479042, maxLatitude: 46.942787)
        let ojp = OJPHelpers.LocationInformationRequest.initWithBBOX(bbox: bbox)
        
        let ojpXMLData = try! XMLEncoder().encode(ojp, withRootKey: "ojp")
        let ojpXML = String.init(data: ojpXMLData, encoding: .utf8)!
        
        print(ojpXML)
    }
}

extension ViewController {
    func loadXML(xmlFilename: String = "lir-be-bbox") -> Data {
        let path = Bundle.main.path(forResource: xmlFilename, ofType: "xml")
        let xmlData = try! Data(contentsOf: URL(fileURLWithPath: path!))
        
        return xmlData
    }
    
    func parseXML_StripNS() {
        
        // test
        
        let ojpSDK = OjpSDK()
        
        Task {
            
            let stations = try? await ojpSDK.stations(from: "Bern", count: 2)
            
        }
        
        
        let xmlData = loadXML()
        
        let decoder = XMLDecoder()
        decoder.keyDecodingStrategy = .convertFromCapitalized
        decoder.dateDecodingStrategy = .iso8601
        decoder.shouldProcessNamespaces = true
        decoder.keyDecodingStrategy = .useDefaultKeys
        
        print("1) Response with XML - no namespaces")
        print("Decoder keyDecodingStrategy: \(decoder.keyDecodingStrategy)")
        print()
        
        do {
            let ojp = try decoder.decode(OJP.self, from: xmlData)
            if let response = ojp.response {
                for placeResult in response.serviceDelivery.locationInformationDelivery.placeResults {
                    print(placeResult)
                    print()
                }
            }
            
            print("parse OK")
        } catch {
            print("ERRORS during parsing: \(error.localizedDescription)")
        }
    }
    
    func parseXML_NS() {
        let xmlData = loadXML()
        
        // without namespaces
        let decoder2 = XMLDecoder()
        decoder2.keyDecodingStrategy = .convertFromCapitalized
        decoder2.keyDecodingStrategy = .useDefaultKeys
        
        let response2 = try! decoder2.decode(OJP_NS.self, from: xmlData)
        print("2) Response with XML namespaces")
        print(response2)
        print()
    }
}

