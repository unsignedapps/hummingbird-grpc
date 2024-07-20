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

import GRPC
import Hummingbird
import NIOCore
import SwiftProtobuf

public extension GRPCServerBuilder {

    /// Registers the supplied handler for the given unary gRPC service and method name.
    ///
    /// This is an alternative to using grpc-swift's generated provider code, you just need the generated `SwiftProtobuf` `Message` types, though
    /// you could always use `Google_Protobuf_Any` to work with serialized messages directly.
    ///
    /// This overload supports SwiftNIO's `EventLoop`. Async overloads are also available.
    ///
    /// ```swift
    /// let app = Application()
    ///
    /// // Registers a unary gRPC handler on `/echo.Echo/Get`
    /// app.gRPC.onUnary("echo.Echo", "Get", requestType: Echo_EchoRequest.self) { request, context in
    ///     let response = Echo_EchoResponse.with {
    ///         $0.text = "Swift echo get: " + request.text
    ///     }
    ///     return context.eventLoop.makeSucceededFuture(response)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - serviceName:            The gRPC service name. This is usually the first part of the path, eg. `/<serviceName>/<method>`.
    ///   - method:                 The gRPC method name. This is usually the second part of the path, eg. `/<serviceName>/<method>`.
    ///   - requestType:            The type of `SwiftProtobuf` `Message` we should expect to decode. Defaults to using type inference.
    ///   - responseType:           The type of `SwiftProtobuf` `Message` we should expect to return to the client. Defaults to using type inference.
    ///   - interceptors:           Optional gRPC `ServerInterceptor`s to apply to the request/response before calling the handler.
    ///   - handler:                A closure to be called to handle the request and create the response to return to the client.
    ///                             It is passed two parameters: the `Request` payload and some call context. It is expected to return a future `Response` to send to the client.
    ///
    @discardableResult
    func onUnary<Request, Response>(
        _ serviceName: String,
        _ method: String,
        requestType: Request.Type = Request.self,
        responseType: Response.Type = Response.self,
        interceptors: [ServerInterceptor<Request, Response>] = [],
        handler: @escaping @Sendable (Request, StatusOnlyCallContext) -> EventLoopFuture<Response>
    ) -> GRPCServerBuilder where Request: SwiftProtobuf.Message, Response: SwiftProtobuf.Message {
        let provider = HBCallHandlerProvider(serviceName: serviceName, method: method) { context in
            UnaryServerHandler(
                context: context,
                requestDeserializer: ProtobufDeserializer<Request>(),
                responseSerializer: ProtobufSerializer<Response>(),
                interceptors: interceptors,
                userFunction: handler
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
    /// This overload supports SwiftNIO's `EventLoop`. Async overloads are also available.
    ///
    /// ```swift
    /// let app = HBApplication()
    ///
    /// // Registers a server stream gRPC handler on `/echo.Echo/Expand`
    /// app.gRPC.onServerStream("echo.Echo", "Expand", requestType: Echo_EchoRequest.self) { request, context in
    ///     let responses = request.text.components(separatedBy: " ").lazy.enumerated().map { i, part in
    ///       Echo_EchoResponse.with {
    ///         $0.text = "Swift echo expand (\(i)): \(part)"
    ///       }
    ///     }
    ///     context.sendResponses(responses, promise: nil)
    ///     return context.eventLoop.makeSucceededFuture(.ok)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - serviceName:            The gRPC service name. This is usually the first part of the path, eg. `/<serviceName>/<method>`.
    ///   - method:                 The gRPC method name. This is usually the second part of the path, eg. `/<serviceName>/<method>`.
    ///   - requestType:            The type of `SwiftProtobuf` `Message` we should expect to decode. Defaults to using type inference.
    ///   - responseType:           The type of `SwiftProtobuf` `Message` we should expect to return to the client. Defaults to using type inference.
    ///   - interceptors:           Optional gRPC `ServerInterceptor`s to apply to the request/response before calling the handler.
    ///   - handler:                A closure to be called to handle the request and create the response to return to the client.
    ///                             It is passed two parameters: the `Request` payload from the client, and a stream writer you can use to send messages back to the client.
    ///                             It is expected to return a future `GRPCStatus` to end the stream.
    ///
    @discardableResult
    func onServerStream<Request, Response>(
        _ serviceName: String,
        _ method: String,
        requestType: Request.Type = Request.self,
        responseType: Response.Type = Response.self,
        interceptors: [ServerInterceptor<Request, Response>] = [],
        handler: @escaping @Sendable (Request, StreamingResponseCallContext<Response>) -> EventLoopFuture<GRPCStatus>
    ) -> GRPCServerBuilder where Request: SwiftProtobuf.Message, Response: SwiftProtobuf.Message {
        let provider = HBCallHandlerProvider(serviceName: serviceName, method: method) { context in
            ServerStreamingServerHandler(
                context: context,
                requestDeserializer: ProtobufDeserializer<Request>(),
                responseSerializer: ProtobufSerializer<Response>(),
                interceptors: interceptors,
                userFunction: handler
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
    /// This overload supports SwiftNIO's `EventLoop`. Async overloads are also available.
    ///
    /// ```swift
    /// let app = HBApplication()
    ///
    /// // Registers a client stream gRPC handler on `/echo.Echo/Collect`
    /// app.gRPC.onClientStream("echo.Echo", "Collect", requestType: Echo_EchoRequest.self) { context in
    ///     var parts: [String] = []
    ///     return context.eventLoop.makeSucceededFuture({ event in
    ///         switch event {
    ///         case let .message(message):
    ///             parts.append(message.text)
    ///
    ///         case .end:
    ///             let response = Echo_EchoResponse.with {
    ///                 $0.text = "Swift echo collect: " + parts.joined(separator: " ")
    ///             }
    ///             context.responsePromise.succeed(response)
    ///         }
    ///     })
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - serviceName:            The gRPC service name. This is usually the first part of the path, eg. `/<serviceName>/<method>`.
    ///   - method:                 The gRPC method name. This is usually the second part of the path, eg. `/<serviceName>/<method>`.
    ///   - requestType:            The type of `SwiftProtobuf` `Message` we should expect to decode. Defaults to using type inference.
    ///   - responseType:           The type of `SwiftProtobuf` `Message` we should expect to return to the client. Defaults to using type inference.
    ///   - interceptors:           Optional gRPC `ServerInterceptor`s to apply to the request/response before calling the handler.
    ///   - handler:                A closure to be called to handle the request and create the response to return to the client.
    ///                             It is passed one parameter: a context object you can use to respond to the client. It is expected to return a future closure
    ///                             that can receive message events from the client.
    ///
    @discardableResult
    func onClientStream<Request, Response>(
        _ serviceName: String,
        _ method: String,
        requestType: Request.Type = Request.self,
        responseType: Response.Type = Response.self,
        interceptors: [ServerInterceptor<Request, Response>] = [],
        handler: @escaping @Sendable (UnaryResponseCallContext<Response>) -> EventLoopFuture<(StreamEvent<Request>) -> Void>
    ) -> GRPCServerBuilder where Request: SwiftProtobuf.Message, Response: SwiftProtobuf.Message {
        let provider = HBCallHandlerProvider(serviceName: serviceName, method: method) { context in
            ClientStreamingServerHandler(
                context: context,
                requestDeserializer: ProtobufDeserializer<Request>(),
                responseSerializer: ProtobufSerializer<Response>(),
                interceptors: interceptors,
                observerFactory: handler
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
    /// This overload supports SwiftNIO's `EventLoop`. Async overloads are also available.
    ///
    /// ```swift
    /// let app = HBApplication()
    ///
    /// // Registers a bidirectional stream gRPC handler on `/echo.Echo/Update`
    /// app.gRPC.onBidirectionalStream("echo.Echo", "Update", requestType: Echo_EchoRequest.self) { context async in
    ///     var count = 0
    ///     return context.eventLoop.makeSucceededFuture({ event in
    ///         switch event {
    ///         case let .message(message):
    ///             let response = Echo_EchoResponse.with {
    ///                 $0.text = "Swift echo update (\(count)): \(message.text)"
    ///             }
    ///             count += 1
    ///             context.sendResponse(response, promise: nil)
    ///
    ///         case .end:
    ///             context.statusPromise.succeed(.ok)
    ///         }
    ///     })
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - serviceName:            The gRPC service name. This is usually the first part of the path, eg. `/<serviceName>/<method>`.
    ///   - method:                 The gRPC method name. This is usually the second part of the path, eg. `/<serviceName>/<method>`.
    ///   - requestType:            The type of `SwiftProtobuf` `Message` we should expect to decode. Defaults to using type inference.
    ///   - responseType:           The type of `SwiftProtobuf` `Message` we should expect to return to the client. Defaults to using type inference.
    ///   - interceptors:           Optional gRPC `ServerInterceptor`s to apply to the request/response before calling the handler.
    ///   - handler:                A closure to be called to handle the request and create the response to return to the client.
    ///                             It is passed one parameter: a context object you can use to send response messages to the client. It is expected to return a future closure
    ///                             that can receive message events from the client.
    ///
    @discardableResult
    func onBidirectionalStream<Request, Response>(
        _ serviceName: String,
        _ method: String,
        requestType: Request.Type = Request.self,
        responseType: Response.Type = Response.self,
        interceptors: [ServerInterceptor<Request, Response>] = [],
        handler: @escaping @Sendable (StreamingResponseCallContext<Response>) -> EventLoopFuture<(StreamEvent<Request>) -> Void>
    ) -> GRPCServerBuilder where Request: SwiftProtobuf.Message, Response: SwiftProtobuf.Message {
        let provider = HBCallHandlerProvider(serviceName: serviceName, method: method) { context in
            BidirectionalStreamingServerHandler(
                context: context,
                requestDeserializer: ProtobufDeserializer<Request>(),
                responseSerializer: ProtobufSerializer<Response>(),
                interceptors: interceptors,
                observerFactory: handler
            )
        }
        addServiceProvider(provider)
        return self
    }

}
