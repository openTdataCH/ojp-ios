# Notes For SDK Developers

This page is aimed at developers of this SDK regarding design decisions. 

## General Design Decisions

- We try to be as close to the OJP specificiation in terms of modelling and naming as possible
- We won't implement everything the OJP specifictaion offers, but focus on public transportation use cases in Switzerland
- The goal should be to offer similiar APIs for Android and iOS while adhering to platform standards

### XML Coding and Decoding

OJP is XML based, a format that hasn't seen much enthousiasm in the mobile developer space. While there is a quite robust support, it lacks the ergonomics of Codable. We've chosen [XMLCoder](https://github.com/CoreOffice/XMLCoder) to leverage Codable for XML. 

#### Limitations of XMLCoder

Namespace handling is very basic. We currently require `ojp` to be the default (unprefixed) namespace for the OJP XSD and `siri:` to be the namespace for SIRI XSD. Maybe we could leverage using a custom `keyDecodingStrategy` to be a bit more flexible there. [https://github.com/openTdataCH/ojp-ios/issues/41](https://github.com/openTdataCH/ojp-ios/issues/41)

#### How to define CodingKeys

`wip`

