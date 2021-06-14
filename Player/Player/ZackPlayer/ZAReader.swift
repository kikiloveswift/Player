//
//  ZAReader.swift
//  Player
//
//  Created by kong on 2021/6/13.
//

import UIKit
import AVFoundation

final class ZAReader: NSObject {

    let videoURL: URL

    var asset: AVAsset?

    var output: AVAssetReaderTrackOutput?

    var assetReader: AVAssetReader?

    var videoSize: CGSize = .zero

    var canStart: Bool = false

    var firstPts: Int64 = 0

    public weak var delegate: ReaderDelegate?

    init(pathURL: URL) {
        videoURL = pathURL
        super.init()
    }

    func prepareAsset() {
        let videoAsset = AVAsset(url: videoURL)
        guard let reader = try? AVAssetReader(asset: videoAsset),
              let videoTrack = videoAsset.tracks(withMediaType: .video).first else {
            return
        }
        self.videoSize = videoTrack.naturalSize
        let preSetting = [kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA,
                          kCVPixelBufferIOSurfacePropertiesKey as String : [:]] as [String : Any]

        let trackoutPut = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: preSetting)
        if reader.canAdd(trackoutPut) {
            reader.add(trackoutPut)
        }
        self.output = trackoutPut
        self.asset = videoAsset
        self.assetReader = reader
        canStart = true
    }
}

protocol ReaderDelegate: AnyObject {
    func processPixelBuffer(_ pixbuffer: CVPixelBuffer, size: CGSize)
}

protocol ReaderProtocol {
    /// start Read
    func startRead() -> Bool

    /// stop
    func stop()

    /// get duration ms
    func getDuration() -> Int64

    /// fetch next frame with timeOffSet
    func getNextFrameWithTimeOffSet(timeOffSet: Int64) -> Bool
}

extension ZAReader: ReaderProtocol {

    func startRead() -> Bool {
        if !canStart {
            return false
        }
        guard let reader = self.assetReader else {
            return false
        }
        reader.startReading()
        return true
    }

    func stop() {
        guard let reader = self.assetReader else {
            return
        }
        reader.cancelReading()
        self.assetReader = nil
        self.asset = nil
        self.output = nil
    }

    func getDuration() -> Int64 {
        guard let asset = self.asset else {
            return 0
        }
        return Int64(Int32(asset.duration.value) * 1000 / asset.duration.timescale)
    }

    func getNextFrameWithTimeOffSet(timeOffSet: Int64) -> Bool {
        guard let output = self.output,
              let sampleBuffer = output.copyNextSampleBuffer() else {
            return false
        }
        let presentTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let pts = presentTime.value * 1000000 / Int64(presentTime.timescale)
        if firstPts == 0 {
            firstPts = pts
        }
        let framePts = pts - firstPts
        let timeNow = Int64(mach_absolute_time()) * 1000000 - timeOffSet
        if framePts > timeNow {
            print("usleep for \(useconds_t(framePts - timeNow))")
            usleep(useconds_t(framePts - timeNow))
        }
        if let imgBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            self.delegate?.processPixelBuffer(imgBuffer, size: self.videoSize)
        }
        return true
    }


}
