//
//  PeerConnectionService.swift
//  PTTalk
//
//  Created by Noman belim on 09/01/26.
//

import MultipeerConnectivity

class PeerConnectionService: NSObject, ObservableObject {

    @Published var connectedPeerName: String?

    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    private let session: MCSession
    private let advertiser: MCNearbyServiceAdvertiser
    private let browser: MCNearbyServiceBrowser

    override init() {
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        advertiser = MCNearbyServiceAdvertiser(
            peer: myPeerID,
            discoveryInfo: nil,
            serviceType: "pttalk"
        )
        browser = MCNearbyServiceBrowser(
            peer: myPeerID,
            serviceType: "pttalk"
        )

        super.init()

        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self

        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
    }
}

extension PeerConnectionService: MCSessionDelegate {

    func session(_ session: MCSession,
                 peer peerID: MCPeerID,
                 didChange state: MCSessionState) {

        DispatchQueue.main.async {
            if state == .connected {
                self.connectedPeerName = peerID.displayName
            }
        }
    }

    func session(_ session: MCSession,
                 didReceive data: Data,
                 fromPeer peerID: MCPeerID) {}

    func session(_ session: MCSession,
                 didReceive stream: InputStream,
                 withName streamName: String,
                 fromPeer peerID: MCPeerID) {}

    func session(_ session: MCSession,
                 didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 with progress: Progress) {}

    func session(_ session: MCSession,
                 didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 at localURL: URL?,
                 withError error: Error?) {}
}

extension PeerConnectionService: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void) {

        invitationHandler(true, session)
    }
}

extension PeerConnectionService: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser,
                 foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String : String]?) {

        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }

    func browser(_ browser: MCNearbyServiceBrowser,
                 lostPeer peerID: MCPeerID) {}
}
