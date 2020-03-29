import Foundation
import Logging
import NIO
import WebTunnel

struct Tunnel {
    private let url: URL
    private let group: EventLoopGroup

    init(url: URL, group: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)) {
        self.url = url
        self.group = group
    }

    func open(_ delegate: TunnelDelegate) {
        let bootstrap = ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .childChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .childChannelInitializer { channel in
                channel.pipeline.add(handler: WebTunnel(url: self.url))
            }

        let sock = bootstrap.bind(to: try! SocketAddress(ipAddress: "::1", port: 0))
        sock.whenSuccess { channel in
            let port = channel.localAddress!.port!
            DispatchQueue.main.async {
                delegate.tunnel(opened: self, port: port)
            }
        }
        sock.whenFailure { error in
            DispatchQueue.main.async {
                delegate.tunnel(failed: self, error: error)
            }
        }
    }
}
