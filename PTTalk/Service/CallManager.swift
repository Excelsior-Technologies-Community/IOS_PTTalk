import Foundation
import MultipeerConnectivity

final class CallManager: NSObject, ObservableObject,
                         MCSessionDelegate,
                         MCNearbyServiceAdvertiserDelegate,
                         MCNearbyServiceBrowserDelegate {

    // MARK: - Published State
    @Published var isConnected = false
    @Published var peerName: String?

    // MARK: - Multipeer Properties
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser!
    private var browser: MCNearbyServiceBrowser!

    // MARK: - Init
    override init() {
        super.init()
        print("🚀 CallManager initialized")
        setupMultipeer()
    }

    // MARK: - Multipeer Setup
    private func setupMultipeer() {

        session = MCSession(
            peer: myPeerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )
        session.delegate = self

        advertiser = MCNearbyServiceAdvertiser(
            peer: myPeerID,
            discoveryInfo: nil,
            serviceType: "pttalk"
        )
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()

        browser = MCNearbyServiceBrowser(
            peer: myPeerID,
            serviceType: "pttalk"
        )
        browser.delegate = self
        browser.startBrowsingForPeers()

        print("📡 Advertising & browsing started")
    }

    // MARK: - MCSessionDelegate (ALL REQUIRED METHODS)

    func session(_ session: MCSession,
                 peer peerID: MCPeerID,
                 didChange state: MCSessionState) {

        DispatchQueue.main.async {
            switch state {
            case .connected:
                print("✅ CONNECTED to \(peerID.displayName)")
                self.isConnected = true
                self.peerName = peerID.displayName

            case .connecting:
                print("⏳ CONNECTING to \(peerID.displayName)")

            case .notConnected:
                print("❌ DISCONNECTED from \(peerID.displayName)")
                self.isConnected = false
                self.peerName = nil

            @unknown default:
                break
            }
        }
    }

    func session(_ session: MCSession,
                 didReceive data: Data,
                 fromPeer peerID: MCPeerID) {
        // Not used
    }

    func session(_ session: MCSession,
                 didReceive stream: InputStream,
                 withName streamName: String,
                 fromPeer peerID: MCPeerID) {
        // Not used
    }

    func session(_ session: MCSession,
                 didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 with progress: Progress) {
        // Not used
    }

    func session(_ session: MCSession,
                 didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 at localURL: URL?,
                 withError error: Error?) {
        // Not used
    }

    // MARK: - MCNearbyServiceAdvertiserDelegate

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void) {

        print("📨 Invitation received from \(peerID.displayName)")
        invitationHandler(true, session)
    }

    // MARK: - MCNearbyServiceBrowserDelegate

    func browser(_ browser: MCNearbyServiceBrowser,
                 foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String : String]?) {

        print("🔎 Found peer: \(peerID.displayName)")
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }

    func browser(_ browser: MCNearbyServiceBrowser,
                 lostPeer peerID: MCPeerID) {

        print("📴 Lost peer: \(peerID.displayName)")
    }
}
