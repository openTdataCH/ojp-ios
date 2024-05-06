#!/bin/sh


# Formats the source in package
swift package plugin --allow-writing-to-package-directory swiftformat

# Formats Sample App
swift package plugin --allow-writing-to-package-directory swiftformat SampleApp
