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

let rgbled = RGBLED(red: gpios[redPin]!, green: gpios[greenPin]!, blue: gpios[bluePin]!)

// We need to share the same ChatHandler for all as it keeps track of all
// connected clients. For this ChatHandler MUST be thread-safe!
let piHandler = PiHandler()

let switchButtonGPIO = gpios[switchButtonPin]!

switchButtonGPIO.direction = .IN
switchButtonGPIO.bounceTime = 0.5
switchButtonGPIO.onRaising { (gpio) in
    piHandler.writeToAll(colorName: rgbled.switchToNextState().name)
}

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
            channel.pipeline.addHandler(piHandler)
//        }
    }

    // Enable SO_REUSEADDR for the accepted Channels
    .childChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
    .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 16)
    .childChannelOption(ChannelOptions.recvAllocator, value: AdaptiveRecvByteBufferAllocator())

defer {
    try! group.syncShutdownGracefully()
}

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
