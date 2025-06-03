//
//  Copyright © 2025 Darren Ford. All rights reserved.
//
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

extension BinaryFloatingPoint {
	/// Clamp an Binary flowing point value to a closed range
	/// - Parameter range: The range
	/// - Returns: A clamped value
	@inlinable func clamped(_ range: ClosedRange<Self>) -> Self {
		max(range.lowerBound, min(range.upperBound, self))
	}
}

extension ExpressibleByIntegerLiteral where Self: Strideable {
	/// Clamp an integer literal to a closed range
	/// - Parameter range: The range
	/// - Returns: A clamped value
	@inlinable func clamped(_ range: ClosedRange<Self>) -> Self {
		max(range.lowerBound, min(range.upperBound, self))
	}
}
