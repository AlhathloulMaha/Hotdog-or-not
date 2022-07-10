import UIKit
import CoreML
import Vision

class ViewController: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera //photolibrary
        imagePicker.allowsEditing = false
        
        
    }
    
    //Tells the delegate that user picked a still image or movie
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not conver to CIImage")
            }
            
            detect(image: ciimage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }

    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading coreML Model Failed.")
        }
        
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as?  [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            print(results)
            
            
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog!"
                }
                else{
                    self.navigationItem.title = "Not Hotdog!"
                }
            }
        }
        
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform( [request] )
        }
        catch {
            print(error)
        }
    }

}

