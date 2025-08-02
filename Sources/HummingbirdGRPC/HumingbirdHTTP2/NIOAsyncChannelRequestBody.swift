//===----------------------------------------------------------------------===//
//
// This source file was originally part of the Hummingbird server framework project
//
// Copyright (c) 2024 the Hummingbird authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See hummingbird/CONTRIBUTORS.txt for the list of Hummingbird authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import NIOConcurrencyHelpers
import NIOCore
import NIOHTTPTypes

/// Request body that is a stream of ByteBuffers sourced from a NIOAsyncChannelInboundStream.
///
/// This is a unicast async sequence that allows a single iterator to be created.
@usableFromInline
struct NIOAsyncChannelRequestBody: Sendable, AsyncSequence {
    public typealias Element = ByteBuffer
    public typealias InboundStream = NIOAsyncChannelInboundStream<HTTPRequestPart>

    @usableFromInline
    internal let underlyingIterator: UnsafeTransfer<InboundStream.AsyncIterator>
    @usableFromInline
    internal let alreadyIterated: NIOLockedValueBox<Bool>

    /// Initialize NIOAsyncChannelRequestBody from AsyncIterator of a NIOAsyncChannelInboundStream
    @inlinable
    public init(iterator: InboundStream.AsyncIterator) {
        self.underlyingIterator = .init(iterator)
        self.alreadyIterated = .init(false)
    }

    /// Async Iterator for NIOAsyncChannelRequestBody
    public struct AsyncIterator: AsyncIteratorProtocol {
        @usableFromInline
        internal var underlyingIterator: InboundStream.AsyncIterator
        @usableFromInline
        internal var done: Bool

        @inlinable
        init(underlyingIterator: InboundStream.AsyncIterator, done: Bool = false) {
            self.underlyingIterator = underlyingIterator
            self.done = done
        }

        @inlinable
        public mutating func next() async throws -> ByteBuffer? {
            if self.done { return nil }
            // if we are still expecting parts and the iterator finishes.
            // In this case I think we can just assume we hit an .end
            guard let part = try await self.underlyingIterator.next() else { return nil }
            switch part {
            case .body(let buffer):
                return buffer
            case .end:
                self.done = true
                return nil
            default:
                throw HTTPChannelError.unexpectedHTTPPart(part)
            }
        }
    }

    @inlinable
    public func makeAsyncIterator() -> AsyncIterator {
        // verify if an iterator has already been created. If it has then create an
        // iterator that returns nothing. This could be a precondition failure (currently
        // an assert) as you should not be allowed to do this.
        let done = self.alreadyIterated.withLockedValue {
            assert($0 == false, "Can only create iterator from request body once")
            let done = $0
            $0 = true
            return done
        }
        return AsyncIterator(underlyingIterator: self.underlyingIterator.wrappedValue, done: done)
    }
}

@usableFromInline
struct UnsafeTransfer<Wrapped> {
    @usableFromInline
    package var wrappedValue: Wrapped

    @inlinable
    package init(_ wrappedValue: Wrapped) {
        self.wrappedValue = wrappedValue
    }
}

extension UnsafeTransfer: @unchecked Sendable {}

extension UnsafeTransfer: Equatable where Wrapped: Equatable {}
extension UnsafeTransfer: Hashable where Wrapped: Hashable {}

