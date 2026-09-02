import ReplayKit
import Vision
import CoreImage

/// Broadcast Upload Extension: بيشتغل في عملية منفصلة عن التطبيق الرئيسي
/// وذاكرته محدودة جدًا (~50MB) — لازم يفضل خفيف قد الإمكان.
class SampleHandler: RPBroadcastSampleHandler {

    private var lastProcessTime: CFAbsoluteTime = 0
    /// لا تعمل OCR على كل فريم — سبتايتل بيتغير كل كام ثانية، فمرة كل ٠.٨ ثانية كفاية
    /// وبتوفر بطارية ومعالجة كتير.
    private let minInterval: CFAbsoluteTime = 0.8
    private var lastRecognizedText: String = ""

    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        guard sampleBufferType == .video else { return }

        let now = CFAbsoluteTimeGetCurrent()
        guard now - lastProcessTime >= minInterval else { return }
        lastProcessTime = now

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let croppedImage = cropToSubtitleRegion(pixelBuffer)

        let request = VNRecognizeTextRequest { [weak self] request, _ in
            guard let self else { return }
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }

            let text = observations
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: " ")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            guard !text.isEmpty, text != self.lastRecognizedText else { return }
            self.lastRecognizedText = text

            SharedTextStore.writeSourceText(text)
            DarwinNotification.post(DarwinNotification.newTextAvailable)
        }

        // .fast أسرع وأخف على المعالج، مناسب لسبتايتل عادي.
        // لو الدقة مش كفاية جرّب .accurate (أبطأ شوية).
        request.recognitionLevel = .fast
        request.usesLanguageCorrection = true
        // automaticallyDetectsLanguage متاح من iOS 16، بيساعد لو السبتايتل مش إنجليزي بس.
        if #available(iOS 16.0, *) {
            request.automaticallyDetectsLanguage = true
        }

        let handler = VNImageRequestHandler(ciImage: croppedImage, options: [:])
        try? handler.perform([request])
    }

    /// بيقص الجزء اللي غالبًا فيه السبتايتل (الثلث السفلي من الشاشة).
    /// ملحوظة مهمة: نظام إحداثيات CIImage الأصل بتاعه تحت-شمال، وممكن orientation
    /// الفريم يحتاج تدوير حسب اتجاه الشاشة وقت التسجيل — لازم تتأكد بالتجربة الفعلية
    /// على جهاز حقيقي وتظبط الـ cropRect لو الترجمة مش بتتقرا صح.
    private func cropToSubtitleRegion(_ pixelBuffer: CVPixelBuffer) -> CIImage {
        let fullImage = CIImage(cvPixelBuffer: pixelBuffer)
        let extent = fullImage.extent
        let cropRect = CGRect(
            x: extent.minX,
            y: extent.minY,
            width: extent.width,
            height: extent.height * 0.33
        )
        return fullImage.cropped(to: cropRect)
    }

    override func broadcastStarted(withSetupInfo setupInfo: [String: NSObject]?) {
        lastRecognizedText = ""
    }

    override func broadcastFinished() {
        // مفيش تنظيف إضافي مطلوب حاليًا.
    }
}
