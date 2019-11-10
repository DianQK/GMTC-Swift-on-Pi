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

private let newLine = "\n".utf8.first!

class ChatHandler: ChannelInboundHandler {
    public typealias InboundIn = ByteBuffer
    public typealias OutboundOut = ByteBuffer

    private func printByte(_ byte: UInt8) {
        #if os(Android)
        print(Character(UnicodeScalar(byte)),  terminator:"")
        #else
        fputc(Int32(byte), stdout)
        #endif
    }
    
    var piChannel: Channel?

    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        var byteBuffer = self.unwrapInboundIn(data)
        let colorName = byteBuffer.getString(at: byteBuffer.readerIndex, length: byteBuffer.readableBytes)
//        print(colorName ?? "")
        while let byte: UInt8 = byteBuffer.readInteger() {
            printByte(byte)
        }
        printByte(newLine)

//        buffer.getData(at: 0, length: buffer.readerIndex)
//        buffer.decod
//        JSONDecoder().dec
//        buffer.readJSONDecodable(<#T##type: Decodable.Protocol##Decodable.Protocol#>, decoder: <#T##JSONDecoder#>, length: <#T##Int#>)
//        JSONDecoder().decode(<#T##type: Decodable.Protocol##Decodable.Protocol#>, from: <#T##ByteBuffer#>)
        let channel = context.channel
        var sendBuffer = channel.allocator.buffer(capacity: 64)
        self.piChannel = channel
//        channel.writeAndFlush(<#T##data: NIOAny##NIOAny#>)
//        sendBuffer.writeString("(ChatClient) - Welcome to: \(context.localAddress!) \(count)\n")
//        context.writeAndFlush(self.wrapOutboundOut(sendBuffer), promise: nil)
    }
    
    func send(string: String) {
        guard let piChannel = self.piChannel else {
            return
        }
        var sendBuffer = piChannel.allocator.buffer(capacity: string.utf8.count)
        sendBuffer.writeString(string)
        piChannel.writeAndFlush(self.wrapOutboundOut(sendBuffer), promise: nil)
    }

    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("error: ", error)

        // As we are not really interested getting notified on success or failure we just pass nil as promise to
        // reduce allocations.
        context.close(promise: nil)
    }
}

let chatHandler = ChatHandler()

func startClient() throws {
    let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    let bootstrap = ClientBootstrap(group: group)
        // Enable SO_REUSEADDR.
        .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
        .channelInitializer { channel in
            channel.pipeline.addHandler(chatHandler)
        }
//    defer {
//        try! group.syncShutdownGracefully()
//    }

    let defaultHost = "pi.ssh.homekit.press"
    let defaultPort = 9999

    _ = bootstrap.connect(host: defaultHost, port: defaultPort)
}
