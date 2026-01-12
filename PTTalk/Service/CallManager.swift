import Foundation
import MultipeerConnectivity
import AVFoundation

final class CallManager: NSObject, ObservableObject {

    // MARK: - Published UI State

    @Published var nearbyPeers: [MCPeerID] = []
    @Published var isConnected: Bool = false
    @Published var peerName: String?
    @Published var hasIncomingCall: Bool = false
    @Published var incomingPeerName: String?
    @Published var isTransmitting: Bool = false

    // MARK: - Multipeer Properties

    private let serviceType = "pttalk"
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)

    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser!
    private var browser: MCNearbyServiceBrowser!

    private var invitationHandler: ((Bool, MCSession?) -> Void)?

    // MARK: - Audio Properties

    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()

    // MARK: - Init

    override init() {
        super.init()
        setupSession()
        setupAdvertiser()
        setupBrowser()
        startServices()
        setupAudioEngine()
        print("🚀 CallManager initialized")
    }

    // MARK: - Setup Multipeer

    private func setupSession() {
        session = MCSession(
            peer: myPeerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )
        session.delegate = self
    }

    private func setupAdvertiser() {
        advertiser = MCNearbyServiceAdvertiser(
            peer: myPeerID,
            discoveryInfo: nil,
            serviceType: serviceType
        )
        advertiser.delegate = self
    }

    private func setupBrowser() {
        browser = MCNearbyServiceBrowser(
            peer: myPeerID,
            serviceType: serviceType
        )
        browser.delegate = self
    }

    private func startServices() {
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
        print("📡 Advertising & browsing started")
    }

    // MARK: - Call Control

    func callPeer(_ peer: MCPeerID) {
        print("📤 Calling \(peer.displayName)")
        browser.invitePeer(peer, to: session, withContext: nil, timeout: 30)
    }

    func acceptCall() {
        print("✅ Call accepted")
        hasIncomingCall = false
        invitationHandler?(true, session)
        invitationHandler = nil
    }

    func rejectCall() {
        print("❌ Call rejected")
        hasIncomingCall = false
        invitationHandler?(false, nil)
        invitationHandler = nil
    }

    func endCall() {
        print("🔴 Ending call")
        session.disconnect()
        isConnected = false
        peerName = nil
        stopTalking()
    }

    // MARK: - Audio Setup

    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(
                .playAndRecord,
                mode: .voiceChat,
                options: [
                    .allowBluetooth,
                    .allowBluetoothA2DP
                ]
            )

            try session.setActive(true)

            // 🔥 FORCE BOTTOM LOUDSPEAKER
            try session.overrideOutputAudioPort(.speaker)
            print("🔊 Audio routed to bottom loudspeaker")

        } catch {
            print("❌ Audio session error:", error)
        }
    }

    private func setupAudioEngine() {
        setupAudioSession()

        audioEngine.attach(playerNode)

        let format = audioEngine.inputNode.outputFormat(forBus: 0)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: format)

        audioEngine.inputNode.installTap(
            onBus: 0,
            bufferSize: 1024,
            format: format
        ) { buffer, _ in
            if self.isTransmitting {
                self.sendAudioBuffer(buffer)
            }
        }

        do {
            try audioEngine.start()
            print("🎧 Audio Engine Running")
        } catch {
            print("❌ Audio Engine error:", error)
        }
    }

    // MARK: - Push to Talk

    func startTalking() {
        isTransmitting = true
        forceSpeaker()
        print("🎙️ START TALKING")
    }

    func stopTalking() {
        isTransmitting = false
        print("🔇 STOP TALKING")
    }

    private func forceSpeaker() {
        do {
            try AVAudioSession.sharedInstance()
                .overrideOutputAudioPort(.speaker)
            print("🔊 Speaker forced")
        } catch {
            print("❌ Speaker override failed")
        }
    }

    // MARK: - Audio Send / Receive

    private func sendAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { return }

        let channelDataValue = channelData.pointee
        let data = Data(
            bytes: channelDataValue,
            count: Int(buffer.frameLength) * MemoryLayout<Float>.size
        )

        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("❌ Failed to send audio:", error)
        }
    }

    private func playAudioData(_ data: Data) {
        let format = audioEngine.inputNode.outputFormat(forBus: 0)

        let frameCount = UInt32(data.count) / format.streamDescription.pointee.mBytesPerFrame
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: frameCount
        ) else { return }

        buffer.frameLength = frameCount

        data.withUnsafeBytes {
            memcpy(buffer.floatChannelData![0], $0.baseAddress!, data.count)
        }

        if !playerNode.isPlaying {
            playerNode.play()
        }

        playerNode.scheduleBuffer(buffer, completionHandler: nil)
    }
}

// MARK: - MCSessionDelegate

extension CallManager: MCSessionDelegate {

    func session(
        _ session: MCSession,
        peer peerID: MCPeerID,
        didChange state: MCSessionState
    ) {
        DispatchQueue.main.async {
            switch state {

            case .connected:
                print("✅ CONNECTED to \(peerID.displayName)")
                self.isConnected = true
                self.peerName = peerID.displayName
                self.setupAudioSession()

            case .notConnected:
                print("❌ DISCONNECTED from \(peerID.displayName)")
                self.isConnected = false
                self.peerName = nil
                self.stopTalking()

            case .connecting:
                print("⏳ CONNECTING to \(peerID.displayName)")

            @unknown default:
                break
            }
        }
    }

    func session(
        _ session: MCSession,
        didReceive data: Data,
        fromPeer peerID: MCPeerID
    ) {
        playAudioData(data)
    }

    func session(
        _ session: MCSession,
        didReceive stream: InputStream,
        withName streamName: String,
        fromPeer peerID: MCPeerID
    ) {}

    func session(
        _ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        with progress: Progress
    ) {}

    func session(
        _ session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        at localURL: URL?,
        withError error: Error?
    ) {}
}

// MARK: - Advertiser Delegate

extension CallManager: MCNearbyServiceAdvertiserDelegate {

    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        DispatchQueue.main.async {
            print("📞 Incoming call from \(peerID.displayName)")
            self.incomingPeerName = peerID.displayName
            self.hasIncomingCall = true
            self.invitationHandler = invitationHandler
        }
    }
}

// MARK: - Browser Delegate

extension CallManager: MCNearbyServiceBrowserDelegate {

    func browser(
        _ browser: MCNearbyServiceBrowser,
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String : String]?
    ) {
        DispatchQueue.main.async {
            if !self.nearbyPeers.contains(peerID) {
                print("🔎 Found peer:", peerID.displayName)
                self.nearbyPeers.append(peerID)
            }
        }
    }

    func browser(
        _ browser: MCNearbyServiceBrowser,
        lostPeer peerID: MCPeerID
    ) {
        DispatchQueue.main.async {
            print("📴 Lost peer:", peerID.displayName)
            self.nearbyPeers.removeAll { $0 == peerID }
        }
    }
}
