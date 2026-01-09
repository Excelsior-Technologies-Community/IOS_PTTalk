import Foundation
import MultipeerConnectivity
import AVFoundation

final class CallManager: NSObject,
                         ObservableObject,
                         MCSessionDelegate,
                         MCNearbyServiceAdvertiserDelegate,
                         MCNearbyServiceBrowserDelegate {

    // MARK: - UI State
    @Published var isConnected = false
    @Published var peerName: String?

    @Published var nearbyPeers: [MCPeerID] = []

    @Published var hasIncomingCall = false
    @Published var incomingPeerName: String?

    // MARK: - Multipeer
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser!
    private var browser: MCNearbyServiceBrowser!

    private var pendingInvitationHandler: ((Bool, MCSession?) -> Void)?

    // MARK: - Audio
    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private var isTransmitting = false

    // MARK: - Init
    override init() {
        super.init()
        setupAudio()
        setupMultipeer()
        print("🚀 CallManager initialized")
    }

    // MARK: - Audio Setup (Push-to-Talk)
    private func setupAudio() {
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(
            .playAndRecord,
            mode: .voiceChat,
            options: [.defaultToSpeaker, .allowBluetooth]
        )
        try? audioSession.setActive(true)

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
    }

    func startTalking() {
        print("🎙️ START TALKING")
        isTransmitting = true
    }

    func stopTalking() {
        print("🔇 STOP TALKING")
        isTransmitting = false
    }

    private func sendAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard isConnected else { return }
        guard session.connectedPeers.count > 0 else { return }

        let audioBuffer = buffer.audioBufferList.pointee.mBuffers
        guard let mData = audioBuffer.mData else { return }

        let data = Data(bytes: mData, count: Int(audioBuffer.mDataByteSize))
        try? session.send(data, toPeers: session.connectedPeers, with: .unreliable)
    }

    // MARK: - Call Control
    func callPeer(_ peer: MCPeerID) {
        print("📤 Calling \(peer.displayName)")
        browser.invitePeer(peer, to: session, withContext: nil, timeout: 10)
    }

    func acceptCall() {
        print("✅ Call accepted")
        pendingInvitationHandler?(true, session)
        clearIncomingCall()
    }

    func rejectCall() {
        print("❌ Call rejected")
        pendingInvitationHandler?(false, nil)
        clearIncomingCall()
    }

    private func clearIncomingCall() {
        pendingInvitationHandler = nil
        incomingPeerName = nil
        hasIncomingCall = false
    }

    func endCall() {
        print("🔴 Ending call")
        audioEngine.stop()
        session.disconnect()
        isConnected = false
        peerName = nil
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

                // 🔑 START AUDIO ENGINE ONCE
                if !self.audioEngine.isRunning {
                    try? self.audioEngine.start()
                    self.playerNode.play()
                    print("🎧 Audio Engine Running")
                }
            case .notConnected:
                print("❌ DISCONNECTED from \(peerID.displayName)")
                self.isConnected = false
                self.peerName = nil

            case .connecting:
                print("⏳ CONNECTING to \(peerID.displayName)")

            @unknown default:
                break
            }
        }
    }

    func session(_ session: MCSession,
                 didReceive data: Data,
                 fromPeer peerID: MCPeerID) {

        let format = audioEngine.inputNode.outputFormat(forBus: 0)
        let frameCount = UInt32(data.count) /
            format.streamDescription.pointee.mBytesPerFrame

        data.withUnsafeBytes { ptr in
            guard let base = ptr.baseAddress else { return }

            let buffer = AVAudioPCMBuffer(
                pcmFormat: format,
                frameCapacity: frameCount
            )!
            buffer.frameLength = frameCount

            memcpy(
                buffer.audioBufferList.pointee.mBuffers.mData,
                base,
                data.count
            )

            playerNode.scheduleBuffer(buffer)
        }
    }

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

    // 🔑 THIS METHOD WAS MISSING (CAUSE OF YOUR ERROR)
    func session(_ session: MCSession,
                 didReceiveCertificate certificate: [Any]?,
                 fromPeer peerID: MCPeerID,
                 certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }

    // MARK: - Advertiser (Incoming Call)
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void) {

        DispatchQueue.main.async {
            print("📞 Incoming call from \(peerID.displayName)")
            self.incomingPeerName = peerID.displayName
            self.hasIncomingCall = true
            self.pendingInvitationHandler = invitationHandler
        }
    }

    // MARK: - Browser (Nearby Devices)
    func browser(_ browser: MCNearbyServiceBrowser,
                 foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String : String]?) {

        DispatchQueue.main.async {
            if !self.nearbyPeers.contains(peerID) {
                print("🔎 Found peer: \(peerID.displayName)")
                self.nearbyPeers.append(peerID)
            }
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser,
                 lostPeer peerID: MCPeerID) {

        DispatchQueue.main.async {
            self.nearbyPeers.removeAll { $0 == peerID }
            print("📴 Lost peer: \(peerID.displayName)")
        }
    }
}
