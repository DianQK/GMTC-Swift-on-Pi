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
import RGBLED

let gpios = SwiftyGPIO.GPIOs(for:.RaspberryPi3)

let rgbLED = RGBLED(red: gpios[.P13]!, green: gpios[.P19]!, blue: gpios[.P26]!)

let piHandler = PiHandler()

let button = gpios[.P14]!

button.direction = .IN
button.bounceTime = 0.3
button.onRaising { (gpio) in
    piHandler.writeToAll(colorName: rgbLED.switchToNextState().name)
}

let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
let bootstrap = ServerBootstrap(group: group)
    .serverChannelOption(ChannelOptions.backlog, value: 256)
    .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
    .childChannelInitializer { channel in
        channel.pipeline.addHandler(piHandler)
    }
    .childChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
    .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 16)
    .childChannelOption(ChannelOptions.recvAllocator, value: AdaptiveRecvByteBufferAllocator())

defer {
    try! group.syncShutdownGracefully()
}

let host = "0.0.0.0"
let port = 9999

let channel = try bootstrap.bind(host: host, port: port).wait()

guard let localAddress = channel.localAddress else {
    fatalError("Address was unable to bind. Please check that the socket was not closed or that the address family was understood.")
}
print("Server started and listening on \(localAddress)")

// This will never unblock as we don't close the ServerChannel.
try channel.closeFuture.wait()

print("ChatServer closed")
