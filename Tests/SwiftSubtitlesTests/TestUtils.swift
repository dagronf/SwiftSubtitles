import XCTest
@testable import SwiftSubtitles

// Utils to aid testing

enum ResourceError: Error {
	case cannotFindResource
}

/// Returns the URL for a test resource
/// - Parameters:
///   - resource: The name of the resource
///   - extn: The resource extension
/// - Throws: `cannotFindResource` if the resource cannot be found
/// - Returns: A URL
func resourceURL(forResource resource: String, withExtension extn: String) throws -> URL {
	guard let url = Bundle.module.url(forResource: resource, withExtension: extn) else {
		throw ResourceError.cannotFindResource
	}
	return url
}

/// Load data from a resource
/// - Parameters:
///   - resource: The resource name
///   - extn: The resource extension
/// - Throws: `cannotFindResource` if the resource cannot be found
/// - Returns: The data content of the resource file
func resourceData(resource: String, withExtension extn: String) throws -> Data {
	let url = try resourceURL(forResource: resource, withExtension: extn)
	return try Data(contentsOf: url)
}
