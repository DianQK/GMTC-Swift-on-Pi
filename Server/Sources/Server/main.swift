import NIO
import NIOFoundationCompat
import Dispatch
#if os(Linux)
import Glibc
#else
import Darwin
#endif
import Foundation
import SwiftyGPIO

let switchButtonPin: GPIOName = .P24

let redPin: GPIOName = .P5
let greenPin: GPIOName = .P6
let bluePin: GPIOName = .P12

let gpios = SwiftyGPIO.GPIOs(for:.RaspberryPi3)

//private let newLine = "\n".utf8.first!

//final class LineDelimiterCodec: ByteToMessageDecoder {
//    public typealias InboundIn = ByteBuffer
//    public typealias InboundOut = ByteBuffer
//
//    public var cumulationBuffer: ByteBuffer?
//
//    public func decode(context: ChannelHandlerContext, buffer: inout ByteBuffer) throws -> DecodingState {
//        let readable = buffer.withUnsafeReadableBytes { $0.firstIndex(of: newLine) }
//        if let r = readable {
//            context.fireChannelRead(self.wrapInboundOut(buffer.readSlice(length: r + 1)!))
//            return .continue
//        }
//        return .needMoreData
//    }
//
//    public func decodeLast(context: ChannelHandlerContext, buffer: inout ByteBuffer, seenEOF: Bool) throws -> DecodingState {
//        return try self.decode(context: context, buffer: &buffer)
//    }
//}

let rgbled = RGBLED(redGPIO: gpios[redPin]!, greenGPIO: gpios[greenPin]!, blueGPIO: gpios[bluePin]!)

final class ChatHandler: ChannelInboundHandler {
    public typealias InboundIn = ByteBuffer
    public typealias OutboundOut = ByteBuffer

    // All access to channels is guarded by channelsSyncQueue.
    private let channelsSyncQueue = DispatchQueue(label: "channelsQueue")
    private var channels: [ObjectIdentifier: Channel] = [:]
    
    public func channelActive(context: ChannelHandlerContext) {
//        let remoteAddress = context.remoteAddress!
        let channel = context.channel
        self.channelsSyncQueue.async {
            // broadcast the message to all the connected clients except the one that just became active.
//            self.writeToAll(channels: self.channels, allocator: channel.allocator, message: "(ChatServer) - New client connected with address: \(remoteAddress)\n")
            
            self.channels[ObjectIdentifier(channel)] = channel
        }
        
        print("new channel")
        
        var buffer = channel.allocator.buffer(capacity: 64)
        buffer.writeString("(ChatServer) - Welcome to: \(context.localAddress!)\n")
        context.writeAndFlush(self.wrapOutboundOut(buffer), promise: nil)
    }
    
    public func channelInactive(context: ChannelHandlerContext) {
        let channel = context.channel
        self.channelsSyncQueue.async {
            if self.channels.removeValue(forKey: ObjectIdentifier(channel)) != nil {
                // Broadcast the message to all the connected clients except the one that just was disconnected.
//                self.writeToAll(channels: self.channels, allocator: channel.allocator, message: "(ChatServer) - Client disconnected\n")
            }
        }
    }

    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let channel = context.channel
        let byteBuffer = self.unwrapInboundIn(data)
//        print(byteBuffer.getsta)
        let rawValue = byteBuffer.getString(at: byteBuffer.readerIndex, length: byteBuffer.readableBytes)
//            var sendBuffer = channel.allocator.buffer(capacity: 64)
//            sendBuffer.writeString("OK: \(context.localAddress!)\n")
//            context.writeAndFlush(self.wrapOutboundOut(sendBuffer), promise: nil)
        if let rawValue = rawValue, let state = RGBLED.State(rawValue: rawValue) {
            rgbled.state = state
        }
    }

    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("error: ", error)

        // As we are not really interested getting notified on success or failure we just pass nil as promise to
        // reduce allocations.
        context.close(promise: nil)
    }

    private func writeToAll(channels: [ObjectIdentifier: Channel], allocator: ByteBufferAllocator, message: String) {
        var buffer =  allocator.buffer(capacity: message.utf8.count)
        buffer.writeString(message)
        self.writeToAll(channels: channels, buffer: buffer)
    }

    private func writeToAll(channels: [ObjectIdentifier: Channel], buffer: ByteBuffer) {
        channels.forEach { $0.value.writeAndFlush(buffer, promise: nil) }
    }
}

// We need to share the same ChatHandler for all as it keeps track of all
// connected clients. For this ChatHandler MUST be thread-safe!
let chatHandler = ChatHandler()

let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
let bootstrap = ServerBootstrap(group: group)
    // Specify backlog and enable SO_REUSEADDR for the server itself
    .serverChannelOption(ChannelOptions.backlog, value: 256)
    .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)

    // Set the handlers that are applied to the accepted Channels
    .childChannelInitializer { channel in
        // Add handler that will buffer data until a \n is received
//        channel.pipeline.addHandler(ByteToMessageHandler(LineDelimiterCodec())).flatMap { v in
            // It's important we use the same handler for all accepted channels. The ChatHandler is thread-safe!
            channel.pipeline.addHandler(chatHandler)
//        }
    }

    // Enable SO_REUSEADDR for the accepted Channels
    .childChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
    .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 16)
    .childChannelOption(ChannelOptions.recvAllocator, value: AdaptiveRecvByteBufferAllocator())

defer {
    try! group.syncShutdownGracefully()
}

// First argument is the program path
// let arguments = CommandLine.arguments
// let arg1 = arguments.dropFirst().first
// let arg2 = arguments.dropFirst(2).first

let defaultHost = "0.0.0.0"
let defaultPort = 9999

let host = defaultHost
let port = defaultPort

enum BindTo {
    case ip(host: String, port: Int)
    case unixDomainSocket(path: String)
}

let channel = try bootstrap.bind(host: host, port: port).wait()

guard let localAddress = channel.localAddress else {
    fatalError("Address was unable to bind. Please check that the socket was not closed or that the address family was understood.")
}
print("Server started and listening on \(localAddress)")

// This will never unblock as we don't close the ServerChannel.
try channel.closeFuture.wait()

print("ChatServer closed")
