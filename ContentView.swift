import SwiftUI

struct ContentView: View {
    @State private var devices: [Device] = []
    
    var body: some View {
        VStack {
            Text("LAN Device List")
                .font(.largeTitle)
                .padding()

            List(devices) { device in
                HStack {
                    Text(device.name)
                    Spacer()
                    Text(device.ip)
                }
            }

            Button(action: scanNetwork) {
                Text("Scan Network")
            }
            .padding()
        }
        .frame(width: 400, height: 300)
    }

    func scanNetwork() {
        // Call the NetworkScanner to scan the local network
        let scanner = NetworkScanner()
        scanner.scan { foundDevices in
            self.devices = foundDevices
        }
    }
}

struct Device: Identifiable {
    let id = UUID()
    let name: String
    let ip: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
