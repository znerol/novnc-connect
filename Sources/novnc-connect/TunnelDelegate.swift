protocol TunnelDelegate {
    func tunnel(opened tunnel: Tunnel, port: UInt16)
    func tunnel(failed tunnel: Tunnel, error: Error)
}
