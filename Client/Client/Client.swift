//
//  Client.swift
//  Client
//
//  Created by dianqk on 2019/11/7.
//  Copyright © 2019 Sankuai. All rights reserved.
//

import Foundation
import NIO
import NIOFoundationCompat

private final class ChatHandler: ChannelInboundHandler {
    public typealias InboundIn = ByteBuffer
    public typealias OutboundOut = ByteBuffer

    private func printByte(_ byte: UInt8) {
        #if os(Android)
        print(Character(UnicodeScalar(byte)),  terminator:"")
        #else
        fputc(Int32(byte), stdout)
        #endif
    }

    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        var buffer = self.unwrapInboundIn(data)
        while let byte: UInt8 = buffer.readInteger() {
            printByte(byte)
        }
//        buffer.getData(at: 0, length: buffer.readerIndex)
//        buffer.decod
//        JSONDecoder().dec
//        buffer.readJSONDecodable(<#T##type: Decodable.Protocol##Decodable.Protocol#>, decoder: <#T##JSONDecoder#>, length: <#T##Int#>)
//        JSONDecoder().decode(<#T##type: Decodable.Protocol##Decodable.Protocol#>, from: <#T##ByteBuffer#>)
        let channel = context.channel
        var sendBuffer = channel.allocator.buffer(capacity: 64)
        count += 1
        sendBuffer.writeString("(ChatClient) - Welcome to: \(context.localAddress!) \(count)\n")
        context.writeAndFlush(self.wrapOutboundOut(sendBuffer), promise: nil)
    }

    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("error: ", error)

        // As we are not really interested getting notified on success or failure we just pass nil as promise to
        // reduce allocations.
        context.close(promise: nil)
    }
}

var count = 1

func startClient() throws {
    let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    let bootstrap = ClientBootstrap(group: group)
        // Enable SO_REUSEADDR.
        .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
        .channelInitializer { channel in
            channel.pipeline.addHandler(ChatHandler())
        }
//    defer {
//        try! group.syncShutdownGracefully()
//    }

    let defaultHost = "localhost"
    let defaultPort = 9999

    _ = bootstrap.connect(host: defaultHost, port: defaultPort)
}
