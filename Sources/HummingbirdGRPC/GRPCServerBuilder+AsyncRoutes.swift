//===----------------------------------------------------------------------===//
//
// Copyright (c) 2023 Unsigned Apps
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

#if compiler(>=5.5.2) && canImport(_Concurrency)

import GRPC
import Hummingbird
import SwiftProtobuf

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension GRPCServerBuilder {

    /// Registers the supplied handler for the given unary gRPC service and method name.
    ///
    /// This is an alternative to using grpc-swift's generated provider code, you just need the generated `SwiftProtobuf` `Message` types, though
    /// you could always use `Google_Protobuf_Any` to work with serialized messages directly.
    ///
    /// This overload supports Swift Concurrency. SwiftNIO `EventLoop` overrides are also available.
    ///
    /// ```swift
    /// let app = HBApplication()
    ///
    /// // Registers a unary gRPC handler on `/echo.Echo/Get`
    /// app.gRPC.onUnary("echo.Echo", "Get", requestType: Echo_EchoRequest.self) { request, context async in
    ///     Echo_EchoResponse.with {
    ///         $0.text = "Swift echo get: " + request.text
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - serviceName:            The gRPC service name. This is usually the first part of the path, eg. `/<serviceName>/<method>`.
    ///   - method:                 The gRPC method name. This is usually the second part of the path, eg. `/<serviceName>/<method>`.
    ///   - requestType:            The type of `SwiftProtobuf` `Message` we should expect to decode. Defaults to using type inference.
    ///   - responseType:           The type of `SwiftProtobuf` `Message` we should expect to return to the client. Defaults to using type inference.
    ///   - interceptors:           Optional gRPC `ServerInterceptor`s to apply to the request/response before calling the handler.
    ///   - handler:                An async closure to be called to handle the request and create the response to return to the client.
    ///                             It is passed two parameters: the `Request` payload and some call context. It is expected to return the `Response` to send to the client.
    ///
    @discardableResult
    func onUnary<Request, Response>(
        _ serviceName: String,
        _ method: String,
        requestType: Request.Type = Request.self,
        responseType: Response.Type = Response.self,
        interceptors: [ServerInterceptor<Request, Response>] = [],
        handler: @Sendable @escaping (Request, GRPCAsyncServerCallContext) async throws -> Response
    ) -> GRPCServerBuilder where Request: SwiftProtobuf.Message, Response: SwiftProtobuf.Message {
        let provider = HBCallHandlerProvider(serviceName: serviceName, method: method) { context in
            GRPCAsyncServerHandler(
                context: context,
                requestDeserializer: ProtobufDeserializer<Request>(),
                responseSerializer: ProtobufSerializer<Response>(),
                interceptors: interceptors,
                wrapping: handler
            )
        }
        addServiceProvider(provider)
        return self
    }

    /// Registers the supplied handler for the given server stream gRPC service and method name.
    ///
    /// This is an alternative to using grpc-swift's generated provider code, you just need the generated `SwiftProtobuf` `Message` types, though
    /// you could always use `Google_Protobuf_Any` to work with serialized messages directly.
    ///
    /// This overload supports Swift Concurrency. SwiftNIO `EventLoop` overrides are also available.
    ///
    /// ```swift
    /// let app = HBApplication()
    ///
    /// // Registers a server stream gRPC handler on `/echo.Echo/Expand`
    /// app.gRPC.onServerStream("echo.Echo", "Expand", requestType: Echo_EchoRequest.self) { request, responseStream, context async throws in
    ///     for (i, part) in request.text.components(separatedBy: " ").lazy.enumerated() {
    ///         try await responseStream.send(Echo_EchoResponse.with { $0.text = "Swift echo expand (\(i)): \(part)" })
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - serviceName:            The gRPC service name. This is usually the first part of the path, eg. `/<serviceName>/<method>`.
    ///   - method:                 The gRPC method name. This is usually the second part of the path, eg. `/<serviceName>/<method>`.
    ///   - requestType:            The type of `SwiftProtobuf` `Message` we should expect to decode. Defaults to using type inference.
    ///   - responseType:           The type of `SwiftProtobuf` `Message` we should expect to return to the client. Defaults to using type inference.
    ///   - interceptors:           Optional gRPC `ServerInterceptor`s to apply to the request/response before calling the handler.
    ///   - handler:                An async closure to be called to handle the request and send responses to the client.
    ///                             It is passed three parameters: the `Request` payload from the client, a stream writer you can use to send messages back to the client
    ///                             and some call context.
    ///
    @discardableResult
    func onServerStream<Request, Response>(
        _ serviceName: String,
        _ method: String,
        requestType: Request.Type = Request.self,
        responseType: Response.Type = Response.self,
        interceptors: [ServerInterceptor<Request, Response>] = [],
        handler: @Sendable @escaping (Request, GRPCAsyncResponseStreamWriter<Response>, GRPCAsyncServerCallContext) async throws -> Void
    ) -> GRPCServerBuilder where Request: SwiftProtobuf.Message, Response: SwiftProtobuf.Message {
        let provider = HBCallHandlerProvider(serviceName: serviceName, method: method) { context in
            GRPCAsyncServerHandler(
                context: context,
                requestDeserializer: ProtobufDeserializer<Request>(),
                responseSerializer: ProtobufSerializer<Response>(),
                interceptors: interceptors,
                wrapping: handler
            )
        }
        addServiceProvider(provider)
        return self
    }

    /// Registers the supplied handler for the given client stream gRPC service and method name.
    ///
    /// This is an alternative to using grpc-swift's generated provider code, you just need the generated `SwiftProtobuf` `Message` types, though
    /// you could always use `Google_Protobuf_Any` to work with serialized messages directly.
    ///
    /// This overload supports Swift Concurrency. SwiftNIO `EventLoop` overrides are also available.
    ///
    /// ```swift
    /// let app = HBApplication()
    ///
    /// // Registers a client stream gRPC handler on `/echo.Echo/Collect`
    /// app.gRPC.onClientStream("echo.Echo", "Collect", requestType: Echo_EchoRequest.self) { requestStream, context async throws in
    ///     let text = try await requestStream.reduce(into: "Swift echo collect:") { result, request in
    ///       result += " \(request.text)"
    ///     }
    ///     return Echo_EchoResponse.with { $0.text = text }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - serviceName:            The gRPC service name. This is usually the first part of the path, eg. `/<serviceName>/<method>`.
    ///   - method:                 The gRPC method name. This is usually the second part of the path, eg. `/<serviceName>/<method>`.
    ///   - requestType:            The type of `SwiftProtobuf` `Message` we should expect to decode. Defaults to using type inference.
    ///   - responseType:           The type of `SwiftProtobuf` `Message` we should expect to return to the client. Defaults to using type inference.
    ///   - interceptors:           Optional gRPC `ServerInterceptor`s to apply to the request/response before calling the handler.
    ///   - handler:                An async closure to be called to handle the request and send responses to the client.
    ///                             It is passed two parameters: an async sequence of `Request` messages that were received from the client, and some call context.
    ///                             It is expected to return the `Response` to send to the client.
    ///
    @discardableResult
    func onClientStream<Request, Response>(
        _ serviceName: String,
        _ method: String,
        requestType: Request.Type = Request.self,
        responseType: Response.Type = Response.self,
        interceptors: [ServerInterceptor<Request, Response>] = [],
        handler: @Sendable @escaping (GRPCAsyncRequestStream<Request>, GRPCAsyncServerCallContext) async throws -> Response
    ) -> GRPCServerBuilder where Request: SwiftProtobuf.Message, Response: SwiftProtobuf.Message {
        let provider = HBCallHandlerProvider(serviceName: serviceName, method: method) { context in
            GRPCAsyncServerHandler(
                context: context,
                requestDeserializer: ProtobufDeserializer<Request>(),
                responseSerializer: ProtobufSerializer<Response>(),
                interceptors: interceptors,
                wrapping: handler
            )
        }
        addServiceProvider(provider)
        return self
    }

    /// Registers the supplied handler for the given bidirectional stream gRPC service and method name.
    ///
    /// This is an alternative to using grpc-swift's generated provider code, you just need the generated `SwiftProtobuf` `Message` types, though
    /// you could always use `Google_Protobuf_Any` to work with serialized messages directly.
    ///
    /// This overload supports Swift Concurrency. SwiftNIO `EventLoop` overrides are also available.
    ///
    /// ```swift
    /// let app = HBApplication()
    ///
    /// // Registers a bidirectional stream gRPC handler on `/echo.Echo/Update`
    /// app.gRPC.onBidirectionalStream("echo.Echo", "Update", requestType: Echo_EchoRequest.self) { requestStream, responseStream, context async in
    ///     var counter = 0
    ///     for try await request in requestStream {
    ///         let text = "Swift echo update (\(counter)): \(request.text)"
    ///         try await responseStream.send(Echo_EchoResponse.with { $0.text = text })
    ///         counter += 1
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - serviceName:            The gRPC service name. This is usually the first part of the path, eg. `/<serviceName>/<method>`.
    ///   - method:                 The gRPC method name. This is usually the second part of the path, eg. `/<serviceName>/<method>`.
    ///   - requestType:            The type of `SwiftProtobuf` `Message` we should expect to decode. Defaults to using type inference.
    ///   - responseType:           The type of `SwiftProtobuf` `Message` we should expect to return to the client. Defaults to using type inference.
    ///   - interceptors:           Optional gRPC `ServerInterceptor`s to apply to the request/response before calling the handler.
    ///   - handler:                An async closure to be called to handle the request and send responses to the client.
    ///                             It is passed three parameters: an async sequence of `Request` messages that were received from the client, a stream you
    ///                             can use to send messages back to the client, and some call context.
    ///
    @discardableResult
    func onBidirectionalStream<Request, Response>(
        _ serviceName: String,
        _ method: String,
        requestType: Request.Type = Request.self,
        responseType: Response.Type = Response.self,
        interceptors: [ServerInterceptor<Request, Response>] = [],
        handler: @Sendable @escaping (GRPCAsyncRequestStream<Request>, GRPCAsyncResponseStreamWriter<Response>, GRPCAsyncServerCallContext) async throws -> Void
    ) -> GRPCServerBuilder where Request: SwiftProtobuf.Message, Response: SwiftProtobuf.Message {
        let provider = HBCallHandlerProvider(serviceName: serviceName, method: method) { context in
            GRPCAsyncServerHandler(
                context: context,
                requestDeserializer: ProtobufDeserializer<Request>(),
                responseSerializer: ProtobufSerializer<Response>(),
                interceptors: interceptors,
                wrapping: handler
            )
        }
        addServiceProvider(provider)
        return self
    }

}

#endif // compiler(>=5.5.2) && canImport(_Concurrency)
