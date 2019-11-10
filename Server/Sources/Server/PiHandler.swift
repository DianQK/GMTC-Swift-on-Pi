//
//  PiHandler.swift
//  Server
//
//  Created by qing on 2019/11/10.
//

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

class PiHandler: ChannelInboundHandler {
    public typealias InboundIn = ByteBuffer
    public typealias OutboundOut = ByteBuffer

    // All access to channels is guarded by channelsSyncQueue.
    private let channelsSyncQueue = DispatchQueue(label: "channelsQueue")
    private var channels: [ObjectIdentifier: Channel] = [:]
    
    public func channelActive(context: ChannelHandlerContext) {
        let channel = context.channel
        self.channelsSyncQueue.async {
            self.channels[ObjectIdentifier(channel)] = channel
        }
        var buffer = channel.allocator.buffer(capacity: 64)
        buffer.writeString(rgbLED.state.name)
        context.writeAndFlush(self.wrapOutboundOut(buffer), promise: nil)
    }
    
    public func channelInactive(context: ChannelHandlerContext) {
        let channel = context.channel
        self.channelsSyncQueue.async {
            self.channels.removeValue(forKey: ObjectIdentifier(channel))
        }
    }

    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let byteBuffer = self.unwrapInboundIn(data)
        let rawValue = byteBuffer.getString(at: byteBuffer.readerIndex, length: byteBuffer.readableBytes)
        if let rawValue = rawValue, let state = RGBLED.State(rawValue: rawValue) {
            rgbLED.state = state
            self.writeToAll(colorName: rawValue)
        }
    }

    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("error: ", error)
        context.close(promise: nil)
    }
    
    public func writeToAll(colorName: String) {
        guard let channel = self.channels.first?.value else { return }
        self.channelsSyncQueue.async {
            self.writeToAll(channels: self.channels, allocator: channel.allocator, message: colorName)
        }
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
