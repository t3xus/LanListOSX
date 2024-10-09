import Foundation
import CocoaAsyncSocket

class NetworkScanner: NSObject, GCDAsyncUdpSocketDelegate {
    var socket: GCDAsyncUdpSocket!
    var foundDevices: [Device] = []
    var onCompletion: (([Device]) -> Void)?

    func scan(completion: @escaping ([Device]) -> Void) {
        self.onCompletion = completion
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)

        do {
            // Set up socket for broadcast
            try socket.enableBroadcast(true)
            try socket.bind(toPort: 0)
            try socket.beginReceiving()

            // Broadcast a message to the network to discover devices
            let message = "LAN_DISCOVERY"
            let data = message.data(using: .utf8)!
            socket.send(data, toHost: "255.255.255.255", port: 9000, withTimeout: -1, tag: 0)

            // Allow some time to gather responses
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.onCompletion?(self.foundDevices)
                self.socket.close()
            }
        } catch {
            print("Error setting up socket: \(error)")
        }
    }

    // This function is called when data is received
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        let host = GCDAsyncUdpSocket.host(fromAddress: address) ?? "Unknown"
        if let message = String(data: data, encoding: .utf8) {
            let device = Device(name: message, ip: host)
            foundDevices.append(device)
        }
    }
}
