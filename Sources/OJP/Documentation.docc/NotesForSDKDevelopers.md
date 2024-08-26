# Notes For SDK Developers

This page is aimed at developers of this SDK regarding design decisions. 

## General Design Decisions

- We try to be as close to the OJP specificiation in terms of modelling and naming as possible
- We won't implement everything the OJP specifictaion offers, but focus on public transportation use cases in Switzerland
- The goal should be to offer similiar APIs for Android and iOS while adhering to platform standards

### XML Coding and Decoding

OJP is XML based, a format that hasn't seen much enthousiasm in the mobile developer space. While there is a quite robust support, it lacks the ergonomics of Codable. We've chosen [XMLCoder](https://github.com/CoreOffice/XMLCoder) to leverage Codable for XML. 

#### Limitations of XMLCoder

Namespace handling is very basic. We currently require `ojp` to be the default (unprefixed) namespace for the OJP XSD and `siri:` to be the namespace for SIRI XSD. We use custom `keyDecodingStrategy` and some logic to see, if `siri:` or `ojp:` namespaces occur in the response, in order to map the xml to our codable structs.

### How to define CodingKeys

An element in the XSD maps to a nested Codable struct in ``OJPv2``. We have to define CodingKeys that map to the element's name according to the XSD. For `siri` elements, we include `siri:` as a value in the coding key.

``` swift
public struct ServiceRequest: Codable {
    public let requestTimestamp: Date
    public let requestorRef: String
    public let locationInformationRequest: LocationInformationRequest?
    public let tripRequest: TripRequest?

    public enum CodingKeys: String, CodingKey {
        case requestTimestamp = "siri:RequestTimestamp"
        case requestorRef = "siri:RequestorRef"
        case locationInformationRequest = "OJPLocationInformationRequest"
        case tripRequest = "OJPTripRequest"
    }
}
```

Under the hood our custom `keyDecodingStrategy` and `NamespaceAwareCodingKey` will do the mapping.


### Handling XML Choice Types

XML supports choice types which translate best to Swift enums with associated types. Parsing those types requires some adaptation and conventions.

As an example, a [Leg](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__LegStructure) contains a choice of either [ContinuousLegStructure](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__ContinuousLegStructure), [TimedLegStructure](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__TimedLegStructure) or 
[TransferLegStructure](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__TransferLegStructure).

To support this, we introduce a ``LegTypeChoice`` enum that containes those three cases. The value is added as a ``OJPv2/Leg/legType`` property.
