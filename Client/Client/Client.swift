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

class ClientHandler: ChannelInboundHandler {
    public typealias InboundIn = ByteBuffer
    public typealias OutboundOut = ByteBuffer

    var piChannel: Channel?
    
    func channelActive(context: ChannelHandlerContext) {
        let channel = context.channel
        self.piChannel = channel
    }

    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let byteBuffer = self.unwrapInboundIn(data)
        guard let colorName = byteBuffer.getString(at: byteBuffer.readerIndex, length: byteBuffer.readableBytes)
            , let color = RGBLEDColor(rawValue: colorName) else {
                return
        }
        DispatchQueue.main.async {
            RGBLEDModel.shared.state = color
        }
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
        context.close(promise: nil)
    }
}

let clientHandler = ClientHandler()

func startClient() throws {
    let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    let bootstrap = ClientBootstrap(group: group)
        .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
        .channelInitializer { channel in
            channel.pipeline.addHandler(clientHandler)
        }

    let host = "pi.local"
    let port = 9999

    _ = bootstrap.connect(host: host, port: port)
}
