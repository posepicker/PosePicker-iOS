//
//  Network+.swift
//  posepicker
//
//  Created by 박경준 on 6/19/24.
//

import Network
import Foundation

func measureLatencyWithNWConnection(host: NWEndpoint.Host, port: NWEndpoint.Port) {
    let parameters = NWParameters.tcp
    let connection = NWConnection(host: host, port: port, using: parameters)

    connection.stateUpdateHandler = { state in
        switch state {
        case .ready:
            print("Connection ready")
            let startTime = CFAbsoluteTimeGetCurrent()
            
            connection.send(content: "Ping".data(using: .utf8), completion: .contentProcessed({ error in
                if let error = error {
                    print("Failed to send data: \(error)")
                    return
                }

                connection.receive(minimumIncompleteLength: 1, maximumLength: 1024) { data, context, isComplete, error in
                    let endTime = CFAbsoluteTimeGetCurrent()
                    guard error == nil else {
                        print("Failed to receive data: \(error!)")
                        return
                    }

                    let latency = endTime - startTime
                    print("Network latency: \(latency) seconds")

                    connection.cancel()
                }
            }))
        case .failed(let error):
            print("Connection failed: \(error)")
        default:
            break
        }
    }

    connection.start(queue: .global())
}
