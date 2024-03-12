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
        
        parseXML_StripNS()
    }


}

extension ViewController {
    func loadXML(xmlFilename: String = "lir-be-bbox") -> Data {
        let path = Bundle.main.path(forResource: xmlFilename, ofType: "xml")
        let xmlData = try! Data(contentsOf: URL(fileURLWithPath: path!))
        
        return xmlData
    }
    
    func parseXML_StripNS() {
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
            let response = try decoder.decode(OJP.self, from: xmlData)
            for placeResult in response.response.serviceDelivery.locationInformationDelivery.placeResults {
                print(placeResult)
                print()
            }
            
            print("parse OK")
        } catch {
            print("ERRORS during parsing: \(error.localizedDescription)")
        }
    }
}

