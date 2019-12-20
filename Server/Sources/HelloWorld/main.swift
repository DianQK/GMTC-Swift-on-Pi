import NIO
import NIOHTTP1

class HelloWorldHTTPHandler: ChannelInboundHandler {
    
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let message = "Hello World".utf8
        var buffer = context.channel.allocator.buffer(capacity: message.count)
        buffer.writeBytes(message)

        let body = HTTPServerResponsePart.body(.byteBuffer(buffer))
        let head = HTTPResponseHead(version: .init(major: 1, minor: 1), status: .ok, headers: HTTPHeaders())

        _ = context.channel.writeAndFlush(HTTPServerResponsePart.head(head))
            .flatMap { context.channel.writeAndFlush(body) }
            .flatMap { context.channel.writeAndFlush(HTTPServerResponsePart.end(nil)) }
            .flatMap { context.channel.close() }
    }
    
}







let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
let bootstrap = ServerBootstrap(group: eventLoopGroup)
    .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
    .childChannelInitializer { channel in
        channel.pipeline.configureHTTPServerPipeline().flatMap {
            channel.pipeline.addHandler(HelloWorldHTTPHandler())
        }
    }

let serverChannel = try bootstrap.bind(host: "localhost", port: 8888).wait()
print("Server running on:", serverChannel.localAddress!)







defer {
    try! eventLoopGroup.syncShutdownGracefully()
}

try serverChannel.closeFuture.wait() // runs forever
